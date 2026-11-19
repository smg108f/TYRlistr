import SwiftUI

enum ActiveSheet: Identifiable {
    case newList, editList, addItem(TierKey), item(UUID), tier(TierKey)

    var id: String {
        switch self {
        case .newList: return "new"
        case .editList: return "edit"
        case .addItem(let t): return "add-\(t.rawValue)"
        case .item(let id): return "item-\(id)"
        case .tier(let t): return "tier-\(t.rawValue)"
        }
    }
}

// MARK: - Item

struct ItemDetailView: View {
    let store: ListStore
    let itemID: UUID
    @State private var draft: TierItem
    @State private var modifying = false
    @State private var confirmDelete = false
    @Environment(\.dismiss) private var dismiss

    init(store: ListStore, itemID: UUID) {
        self.store = store
        self.itemID = itemID
        _draft = State(initialValue: store.item(itemID) ?? TierItem(title: "missing", tier: .Q, rank: 0))
    }

    private var editable: Bool { !store.locked || modifying }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Back") { commit(); dismiss() }
                Spacer()
                Button("Copy") { copyToClipboard(draft.summary) }
                if store.locked {
                    Button(modifying ? "Done" : "Modify") {
                        if modifying { commit() }
                        modifying.toggle()
                    }
                } else {
                    Toggle("Lock item", isOn: $draft.locked)
                    Button("Delete", role: .destructive) { confirmDelete = true }
                }
            }

            HStack(spacing: 14) {
                Text(draft.displayGlyph).font(.system(size: 44))
                VStack(alignment: .leading, spacing: 2) {
                    Text(draft.isBlank ? "blank placeholder" : draft.title).font(.title2.bold())
                    Text("\(draft.tier.rawValue) · \(draft.tier.fullName) · rank \(draft.rank) · \(draft.edits) edits")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Form {
                TextField("Name", text: $draft.title)
                TextField("Graphic (emoji or letters)", text: $draft.glyph)
                TierPicker(selection: $draft.tier).disabled(draft.locked)
                TextField("Explanation (why this tier)", text: $draft.explanation, axis: .vertical)
                    .lineLimit(2...6)
                ForEach(store.list.schema, id: \.self) { key in
                    TextField(key, text: detailBinding(key), axis: .vertical).lineLimit(1...6)
                }
            }
            .formStyle(.grouped)
            .disabled(!editable)
        }
        .padding()
        .frame(minWidth: 480, minHeight: 480)
        .confirmationDialog("Delete \(draft.title)?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete([itemID])
                dismiss()
            }
        }
    }

    private func commit() {
        guard let original = store.item(itemID), original != draft else { return }
        store.update(draft)
    }

    private func detailBinding(_ key: String) -> Binding<String> {
        Binding(get: { draft.details[key] ?? "" }, set: { draft.details[key] = $0 })
    }
}

struct AddItemView: View {
    let store: ListStore
    @State var tier: TierKey
    @State private var title = ""
    @State private var glyph = ""
    @State private var explanation = ""
    @Environment(\.dismiss) private var dismiss

    private var atLimit: Bool { store.list.blankCount == 0 && store.list.items.count >= TYRList.maxItems }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Text("New item").font(.headline)
                Spacer()
                Button("Add") {
                    store.add(title: title.trimmingCharacters(in: .whitespaces),
                              glyph: glyph.trimmingCharacters(in: .whitespaces),
                              explanation: explanation, to: tier)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || atLimit)
            }
            if atLimit {
                Text("This list already has \(TYRList.maxItems) items. Any topic should fit within \(TYRList.maxItems) distinctions; merge or remove something first.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            Form {
                TextField("Name", text: $title)
                TextField("Graphic (emoji or letters)", text: $glyph)
                TierPicker(selection: $tier)
                TextField("Why this tier?", text: $explanation, axis: .vertical).lineLimit(2...6)
            }
            .formStyle(.grouped)
        }
        .padding()
        .frame(minWidth: 460, minHeight: 360)
    }
}

// MARK: - Tier

struct TierInfoView: View {
    let tier: TierKey
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button("Back") { dismiss() }
                Spacer()
            }
            HStack(spacing: 14) {
                TierLabel(tier: tier)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.fullName).font(.title2.bold())
                    Text("\(tier.side.rawValue) · row \(tier.row + 1) · opposite of \(tier.inverse.rawValue) (\(tier.inverse.archetype))")
                        .foregroundStyle(.secondary)
                }
            }
            Text(tier.blurb)
            Text("Customizing tier names, colors and explanations comes in a later version.")
                .font(.footnote).foregroundStyle(.secondary)
            Spacer()
        }
        .padding(24)
        .frame(minWidth: 460, minHeight: 300)
    }
}

// MARK: - List settings (new / edit)

struct ListSettingsView: View {
    let store: ListStore
    let isNew: Bool
    @State private var name: String
    @State private var about: String
    @State private var creator: String
    @State private var thumbnail: String
    @State private var placeholders: Int
    @State private var schemaText: String
    @Environment(\.dismiss) private var dismiss

    init(store: ListStore, isNew: Bool) {
        self.store = store
        self.isNew = isNew
        let l = store.list
        _name = State(initialValue: isNew ? "" : l.name)
        _about = State(initialValue: isNew ? "" : l.description)
        _creator = State(initialValue: l.creator)
        _thumbnail = State(initialValue: isNew ? "" : l.thumbnail)
        _placeholders = State(initialValue: isNew ? 36 : (TYRList.placeholderOptions.contains(l.placeholders) ? l.placeholders : 36))
        _schemaText = State(initialValue: isNew ? "description" : l.schema.joined(separator: ", "))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Text(isNew ? "New TYRlist" : "List settings").font(.headline)
                Spacer()
                Button(isNew ? "Create" : "Save") { apply(); dismiss() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $about, axis: .vertical).lineLimit(2...5)
                TextField("Creator alias", text: $creator)
                TextField("Thumbnail (emoji)", text: $thumbnail)
                Picker("Placeholders", selection: $placeholders) {
                    ForEach(TYRList.placeholderOptions, id: \.self) { Text("\($0)").tag($0) }
                }
                TextField("Item attributes (comma separated)", text: $schemaText)
            }
            .formStyle(.grouped)
        }
        .padding()
        .frame(minWidth: 480, minHeight: 420)
    }

    private func apply() {
        let schema = schemaText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if isNew {
            store.replace(with: TYRList(name: name, description: about, creator: creator,
                                        thumbnail: thumbnail, placeholders: placeholders, schema: schema))
            store.locked = false
        } else {
            store.list.name = name
            store.list.description = about
            store.list.creator = creator
            store.list.thumbnail = thumbnail
            store.list.schema = schema
            store.list.resizePlaceholders(to: placeholders)
            for t in TierKey.allCases { store.renumber(t) }
            store.touch()
        }
    }
}

// MARK: - Stats

struct StatsView: View {
    let store: ListStore

    var body: some View {
        let l = store.list
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("\(l.thumbnail) \(l.name)").font(.largeTitle.bold())
                if !l.description.isEmpty { Text(l.description) }

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                    statRow("creator", l.creator.isEmpty ? "—" : l.creator)
                    statRow("firstseen", TYRList.displayDate(l.created))
                    statRow("last-mod", TYRList.displayDate(l.modified))
                    statRow("edits", "\(l.items.reduce(0) { $0 + $1.edits })")
                    statRow("archetypes", archetypeSummary(l))
                    statRow("items", "\(l.filledCount) filled · \(l.blankCount) blank · \(l.placeholders) placeholders")
                }

                Grid(horizontalSpacing: 10, verticalSpacing: 6) {
                    ForEach(0..<6, id: \.self) { r in
                        let a = TierKey.key(row: r, side: .shine)
                        let b = TierKey.key(row: r, side: .shade)
                        GridRow {
                            TierChip(tier: a)
                            Text("\(l.items(in: a).count)").font(.title3.monospacedDigit()).frame(width: 40)
                            Text("\(l.items(in: b).count)").font(.title3.monospacedDigit()).frame(width: 40)
                            TierChip(tier: b)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func archetypeSummary(_ l: TYRList) -> String {
        let found = l.recognizedTiers
        let missing = TierKey.allCases.filter { !found.contains($0) }
        var s = "\(found.count) of 12 recognized"
        if !missing.isEmpty { s += " · missing " + missing.map(\.rawValue).joined(separator: ", ") }
        return s
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        GridRow {
            Text(label).foregroundStyle(.secondary)
            Text(value)
        }
    }
}
