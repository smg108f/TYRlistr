import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct BarButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    init(_ title: String, _ systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage).font(.title3)
                Text(title).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TierLabel: View {
    let tier: TierKey
    var selected = false
    var showOpen = false

    var body: some View {
        VStack(spacing: 0) {
            Text(tier.rawValue).font(.system(size: 28, weight: .black, design: .rounded))
            Text(tier.tierName).font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(tier.textColor)
        .frame(width: 68, height: 68)
        .background(RoundedRectangle(cornerRadius: 10).fill(tier.color))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(tier.side == .shine ? Color.black : Color.white, lineWidth: selected ? 3 : 0)
        )
        .overlay(alignment: .bottom) {
            if showOpen { OpenBadge() }
        }
        .contentShape(Rectangle())
    }
}

struct ItemTile: View {
    let item: TierItem
    let tier: TierKey
    var selected = false
    var showOpen = false

    var body: some View {
        let shine = tier.side == .shine
        VStack(spacing: 2) {
            Text(item.displayGlyph).font(.system(size: 26)).lineLimit(1).minimumScaleFactor(0.5)
            Text(item.isBlank ? "blank" : item.title).font(.system(size: 10)).lineLimit(2).multilineTextAlignment(.center)
        }
        .opacity(item.isBlank ? 0.55 : 1)
        .foregroundStyle(shine ? Color.black : Color.white)
        .padding(4)
        .frame(width: 72, height: 68)
        .background(RoundedRectangle(cornerRadius: 10).fill(item.isBlank ? Color.clear : (shine ? Color(white: 0.92) : Color(white: 0.17))))
        .overlay {
            if item.isBlank {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .foregroundStyle(shine ? Color.black.opacity(0.35) : Color.white.opacity(0.4))
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tier.color, lineWidth: selected ? 3 : 0))
        .overlay(alignment: .topTrailing) {
            if item.locked {
                Image(systemName: "lock.fill").font(.system(size: 9)).padding(4)
                    .foregroundStyle(shine ? Color.black : Color.white)
            }
        }
        .overlay(alignment: .bottom) {
            if showOpen { OpenBadge() }
        }
        .contentShape(Rectangle())
    }
}

struct OpenBadge: View {
    var body: some View {
        Text("open")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(.regularMaterial, in: Capsule())
            .padding(3)
    }
}

struct TierChip: View {
    let tier: TierKey
    var body: some View {
        HStack(spacing: 6) {
            Text(tier.rawValue).font(.headline.weight(.black))
            Text(tier.archetype).font(.caption)
        }
        .foregroundStyle(tier.textColor)
        .padding(.horizontal, 10).padding(.vertical, 4)
        .frame(minWidth: 110)
        .background(tier.color, in: RoundedRectangle(cornerRadius: 6))
    }
}

struct TierPicker: View {
    @Binding var selection: TierKey
    var body: some View {
        Picker("Tier", selection: $selection) {
            ForEach(TierKey.allCases) { t in
                Text("\(t.rawValue) — \(t.fullName)").tag(t)
            }
        }
    }
}

struct DraggableIf: ViewModifier {
    let enabled: Bool
    let id: UUID

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content.draggable(id.uuidString)
        } else {
            content
        }
    }
}

/// A static render of the list used for PNG export.
struct SnapshotView: View {
    let list: TYRList
    let sides: [Side]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(list.thumbnail) \(list.name)")
                .font(.title2.bold()).foregroundStyle(.white).padding(10)
            ForEach(0..<6, id: \.self) { r in
                let t = TierKey.key(row: r, side: sides[r])
                HStack(spacing: 8) {
                    TierLabel(tier: t)
                    ForEach(list.items(in: t).filter { !$0.isBlank }) { item in
                        ItemTile(item: item, tier: t)
                    }
                    Spacer(minLength: 0)
                }
                .padding(6)
                .background(t.side == .shine ? Color.white : Color.black)
            }
        }
        .frame(width: 1100)
        .background(Color(white: 0.35))
    }
}

func copyToClipboard(_ s: String) {
    #if os(macOS)
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(s, forType: .string)
    #else
    UIPasteboard.general.string = s
    #endif
}

func pngData(from cg: CGImage) -> Data? {
    #if os(macOS)
    return NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])
    #else
    return UIImage(cgImage: cg).pngData()
    #endif
}

extension UTType {
    static var tyrMarkdown: UTType { UTType("net.daringfireball.markdown") ?? .plainText }
}

struct ExportFile: FileDocument {
    static var readableContentTypes: [UTType] { [.tyrMarkdown, .plainText, .html, .png] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

enum Links {
    static let donate = URL(string: "https://buymeacoffee.com/smg108f")!
    static let source = URL(string: "https://github.com/smg108f/TYRlistr")!
    static let examples = URL(string: "https://github.com/smg108f/TYRlistr/tree/HEAD/examples")!
    static let feedback = URL(string: "https://github.com/smg108f/TYRlistr/issues/new")!
}
