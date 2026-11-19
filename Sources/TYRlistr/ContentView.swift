import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var store = ListStore()
    @State private var activeSheet: ActiveSheet?
    @State private var showStats = false
    @State private var showGenerate = false
    @State private var confirmDelete = false
    @State private var chooseExport = false
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var exportDoc: ExportFile?
    @State private var exportType: UTType = .tyrMarkdown
    @State private var exportName = "tyrlist"
    @State private var errorMessage: String?
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header
            Divider()
            if showStats {
                StatsView(store: store)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 2) {
                    ForEach(0..<6, id: \.self) { row in
                        TierRowView(store: store, row: row,
                                    openItem: { activeSheet = .item($0) },
                                    openTier: { activeSheet = .tier($0) })
                    }
                }
                .background(Color(white: 0.45))
            }
            Divider()
            bottomBar
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newList: ListSettingsView(store: store, isNew: true)
            case .editList: ListSettingsView(store: store, isNew: false)
            case .addItem(let tier): AddItemView(store: store, tier: tier)
            case .item(let id): ItemDetailView(store: store, itemID: id)
            case .tier(let tier): TierInfoView(tier: tier)
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.tyrMarkdown, .plainText]) { result in
            openFile(result)
        }
        .fileExporter(isPresented: $showExporter, document: exportDoc, contentType: exportType,
                      defaultFilename: exportName) { result in
            if case .failure(let error) = result { errorMessage = error.localizedDescription }
        }
        .alert("Generate", isPresented: $showGenerate) {
            Button("OK") {}
        } message: {
            Text("AI-assisted list building is planned for a later version. For now, add items with +.")
        }
        .alert("Something went wrong", isPresented: Binding(get: { errorMessage != nil },
                                                             set: { if !$0 { errorMessage = nil } })) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: Bars

    private var topBar: some View {
        HStack(spacing: 0) {
            BarButton(store.locked ? "locked" : "unlocked", store.locked ? "lock.fill" : "lock.open") {
                store.toggleLock()
            }
            BarButton("new", "doc.badge.plus") { activeSheet = .newList }
            BarButton("open", "folder") { showImporter = true }
            BarButton("edit", "slider.horizontal.3") { activeSheet = .editList }
            BarButton("save", "square.and.arrow.down") { save() }
            BarButton("export", "square.and.arrow.up") { chooseExport = true }
                .confirmationDialog("Export as", isPresented: $chooseExport) {
                    Button("Markdown (.md)") { exportMarkdown() }
                    Button("Web page (.html)") { exportHTML() }
                    Button("Image (.png)") { exportPNG() }
                }
            BarButton("stats", showStats ? "square.grid.3x2" : "chart.bar") { showStats.toggle() }
        }
        .padding(.horizontal, 4)
    }

    private var header: some View {
        HStack(spacing: 8) {
            if !store.list.thumbnail.isEmpty { Text(store.list.thumbnail) }
            Text(store.list.name).font(.headline)
            Text(store.locked
                 ? "· tap a tier letter to flip it · arrows scroll"
                 : "· drag items between rows · tap twice to open · arrows move the selected item")
                .font(.caption).foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            BarButton("add", "plus") { activeSheet = .addItem(addTarget) }
            BarButton("generate", "sparkles") { showGenerate = true }
            BarButton("donate", "cup.and.saucer") { openURL(Links.donate) }
            BarButton("examples", "books.vertical") { openURL(Links.examples) }
            BarButton("feedback", "bubble.left") { openURL(Links.feedback) }
            BarButton("source", "chevron.left.forwardslash.chevron.right") { openURL(Links.source) }
            BarButton("remove", "minus") { confirmDelete = true }
                .confirmationDialog(deleteTitle, isPresented: $confirmDelete, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) { performDelete() }
                    if store.selectedItem == nil && store.selectedRow == nil && !store.deletedStack.isEmpty {
                        Button("Undo last deletion") { store.undoDelete() }
                    }
                    Button("Cancel", role: .cancel) {}
                }
        }
        .padding(.horizontal, 4)
    }

    // MARK: Add / delete

    private var addTarget: TierKey {
        if let r = store.selectedRow { return store.tier(forRow: r) }
        if let id = store.selectedItem, let it = store.item(id) { return it.tier }
        return .Q
    }

    private var deleteTitle: String {
        if let id = store.selectedItem, let it = store.item(id) { return "Delete \(it.title)?" }
        if let r = store.selectedRow {
            let t = store.tier(forRow: r)
            return "Delete every item in \(t.rawValue) (\(t.fullName))?"
        }
        return "Delete every item in this TYRlist?"
    }

    private func performDelete() {
        if let id = store.selectedItem {
            store.delete([id])
        } else if let r = store.selectedRow {
            store.delete(Set(store.items(in: store.tier(forRow: r)).map(\.id)))
        } else {
            store.delete(Set(store.list.items.map(\.id)))
        }
    }

    // MARK: Files

    private func save() {
        do {
            store.touch()
            let text = try store.list.saveText()
            present(Data(text.utf8), type: .tyrMarkdown, name: store.list.fileStem)
        } catch {
            errorMessage = "Couldn't save: \(error.localizedDescription)"
        }
    }

    private func exportMarkdown() {
        present(Data(store.list.markdownDocument().utf8), type: .tyrMarkdown, name: store.list.fileStem + "-export")
    }

    private func exportHTML() {
        present(Data(store.list.html().utf8), type: .html, name: store.list.fileStem)
    }

    @MainActor
    private func exportPNG() {
        let renderer = ImageRenderer(content: SnapshotView(list: store.list, sides: store.rowSides))
        renderer.scale = 2
        guard let cg = renderer.cgImage, let data = pngData(from: cg) else {
            errorMessage = "Couldn't render the image."
            return
        }
        present(data, type: .png, name: store.list.fileStem)
    }

    private func present(_ data: Data, type: UTType, name: String) {
        exportDoc = ExportFile(data: data)
        exportType = type
        exportName = name
        // Let any open dialog finish dismissing before the save panel appears.
        DispatchQueue.main.async { showExporter = true }
    }

    private func openFile(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                store.replace(with: try TYRList.load(from: text))
                showStats = false
            } catch {
                errorMessage = "Couldn't open that file. Is it a saved TYRlist? (\(error.localizedDescription))"
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
