import SwiftUI

struct TierRowView: View {
    let store: ListStore
    let row: Int
    let openItem: (UUID) -> Void
    let openTier: (TierKey) -> Void

    @State private var scrollIndex = 0
    @State private var dropTargeted = false

    var body: some View {
        let tier = store.tier(forRow: row)
        let items = store.items(in: tier)
        let rowSelected = store.selectedRow == row
        let fg: Color = tier.side == .shine ? .black : .white

        ScrollViewReader { proxy in
            HStack(spacing: 8) {
                arrowButton("chevron.left", fg) { arrow(-1, items, proxy) }

                TierLabel(tier: tier, selected: rowSelected, showOpen: rowSelected && !store.locked)
                    .onTapGesture { labelTapped(tier) }
                    .overlay(alignment: .topTrailing) {
                        if !store.locked {
                            Button { store.flip(row: row) } label: {
                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(tier.textColor)
                            }
                            .buttonStyle(.plain)
                            .padding(3)
                            .help("Flip to \(tier.inverse.shortLabel)")
                        }
                    }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if items.isEmpty {
                            Text(store.locked ? "empty" : "drag items here")
                                .font(.caption)
                                .foregroundStyle(fg.opacity(0.45))
                                .padding(.leading, 6)
                        }
                        ForEach(items) { item in
                            ItemTile(item: item, tier: tier,
                                     selected: store.selectedItem == item.id || rowSelected,
                                     showOpen: store.selectedItem == item.id)
                                .id(item.id)
                                .onTapGesture { itemTapped(item) }
                                .modifier(DraggableIf(enabled: !store.locked && !item.locked, id: item.id))
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                arrowButton("chevron.right", fg) { arrow(1, items, proxy) }
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tier.side == .shine ? Color.white : Color.black)
            .overlay(Rectangle().strokeBorder(tier.color, lineWidth: dropTargeted ? 4 : 0))
            .dropDestination(for: String.self) { ids, _ in
                guard !store.locked else { return false }
                for s in ids {
                    if let id = UUID(uuidString: s) { store.move(id, to: tier) }
                }
                return true
            } isTargeted: { dropTargeted = $0 }
            .animation(.snappy(duration: 0.2), value: items.map(\.id))
        }
    }

    private func arrowButton(_ symbol: String, _ fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(fg.opacity(0.6))
                .frame(width: 24)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func arrow(_ delta: Int, _ items: [TierItem], _ proxy: ScrollViewProxy) {
        if store.locked {
            // Locked: arrows scroll the row.
            guard !items.isEmpty else { return }
            scrollIndex = min(max(scrollIndex + delta, 0), items.count - 1)
            withAnimation { proxy.scrollTo(items[scrollIndex].id, anchor: .leading) }
        } else {
            // Unlocked: arrows move the selected (or last added) item's rank.
            let ids = Set(items.map(\.id))
            let target = [store.selectedItem, store.lastAdded].compactMap { $0 }.first { ids.contains($0) }
            if let t = target {
                store.shift(t, by: delta)
                withAnimation { proxy.scrollTo(t) }
            }
        }
    }

    private func labelTapped(_ tier: TierKey) {
        if store.locked {
            store.flip(row: row)
        } else if store.selectedRow == row {
            openTier(tier)
        } else {
            store.select(row: row)
        }
    }

    private func itemTapped(_ item: TierItem) {
        if store.selectedItem == item.id {
            openItem(item.id)
        } else {
            store.select(item: item.id)
        }
    }
}
