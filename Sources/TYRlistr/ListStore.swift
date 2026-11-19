import Foundation
import Observation

@Observable
final class ListStore {
    var list: TYRList
    var locked = false
    /// Which side (shine/shade) each of the six rows is showing.
    var rowSides: [Side] = Array(repeating: .shine, count: 6)
    var selectedItem: UUID?
    var selectedRow: Int?
    var lastAdded: UUID?
    var deletedStack: [[TierItem]] = []

    init(list: TYRList = .sample) {
        self.list = list
    }

    // MARK: Queries

    func tier(forRow row: Int) -> TierKey { TierKey.key(row: row, side: rowSides[row]) }
    func items(in tier: TierKey) -> [TierItem] { list.items(in: tier) }
    func item(_ id: UUID) -> TierItem? { list.items.first { $0.id == id } }
    private func index(_ id: UUID) -> Int? { list.items.firstIndex { $0.id == id } }

    // MARK: Selection and view state

    func flip(row: Int) {
        rowSides[row] = rowSides[row].flipped
        if let id = selectedItem, let it = item(id), it.tier.row == row { selectedItem = nil }
    }

    func select(item id: UUID) { selectedItem = id; selectedRow = nil }
    func select(row: Int) { selectedRow = row; selectedItem = nil }
    func clearSelection() { selectedItem = nil; selectedRow = nil }

    func toggleLock() {
        locked.toggle()
        clearSelection()
    }

    // MARK: Editing

    func touch() { list.modified = Date() }

    /// Adds an item. If the list has a blank placeholder, the new item takes its slot.
    func add(title: String, glyph: String, explanation: String, to tier: TierKey) {
        if let blank = list.items.firstIndex(where: { $0.isBlank }) {
            let blankTier = list.items[blank].tier
            list.items.remove(at: blank)
            renumber(blankTier)
        }
        let item = TierItem(title: title, glyph: glyph, tier: tier,
                            rank: items(in: tier).count + 1, explanation: explanation)
        list.items.append(item)
        lastAdded = item.id
        rowSides[tier.row] = tier.side   // show the row the item landed in
        select(item: item.id)
        touch()
    }

    func update(_ updated: TierItem) {
        guard let i = index(updated.id) else { return }
        let oldTier = list.items[i].tier
        var u = updated
        u.edits += 1
        if u.tier != oldTier { u.rank = items(in: u.tier).count + 1 }
        list.items[i] = u
        if u.tier != oldTier { renumber(oldTier) }
        touch()
    }

    /// Move an item to the end of another tier (drag and drop).
    func move(_ id: UUID, to tier: TierKey) {
        guard let i = index(id), !list.items[i].locked, list.items[i].tier != tier else { return }
        let oldTier = list.items[i].tier
        let newRank = items(in: tier).count + 1
        list.items[i].tier = tier
        list.items[i].rank = newRank
        list.items[i].edits += 1
        renumber(oldTier)
        touch()
    }

    /// Shift an item left (-1, toward rank 1) or right (+1) inside its tier.
    func shift(_ id: UUID, by delta: Int) {
        guard let it = item(id), !it.locked else { return }
        var row = items(in: it.tier)
        guard let i = row.firstIndex(where: { $0.id == id }) else { return }
        let j = i + delta
        guard row.indices.contains(j), !row[j].locked else { return }
        row.swapAt(i, j)
        for (n, r) in row.enumerated() {
            if let k = index(r.id) { list.items[k].rank = n + 1 }
        }
        if let k = index(id) { list.items[k].edits += 1 }
        touch()
    }

    func renumber(_ tier: TierKey) {
        for (n, r) in items(in: tier).enumerated() {
            if let k = index(r.id) { list.items[k].rank = n + 1 }
        }
    }

    func delete(_ ids: Set<UUID>) {
        let removed = list.items.filter { ids.contains($0.id) }
        guard !removed.isEmpty else { return }
        deletedStack.append(removed)
        list.items.removeAll { ids.contains($0.id) }
        for t in Set(removed.map(\.tier)) { renumber(t) }
        clearSelection()
        touch()
    }

    func undoDelete() {
        guard let restored = deletedStack.popLast() else { return }
        list.items.append(contentsOf: restored)
        for t in Set(restored.map(\.tier)) { renumber(t) }
        touch()
    }

    // MARK: Whole lists

    func replace(with newList: TYRList) {
        list = newList
        rowSides = Array(repeating: .shine, count: 6)
        clearSelection()
        lastAdded = nil
        deletedStack = []
    }
}
