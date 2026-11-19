import SwiftUI

enum Side: String, Codable {
    case shine, shade
    var flipped: Side { self == .shine ? .shade : .shine }
}

/// The twelve TYR tiers: six shine/shade pairs, one pair per row.
enum TierKey: String, Codable, CaseIterable, Identifiable {
    case G, S, A, E, B, D, C, R, F, T, Q, K

    var id: String { rawValue }

    private static let pairs: [(TierKey, TierKey)] = [(.G, .S), (.A, .E), (.B, .D), (.C, .R), (.F, .T), (.Q, .K)]

    static func key(row: Int, side: Side) -> TierKey {
        side == .shine ? pairs[row].0 : pairs[row].1
    }

    var row: Int { Self.pairs.firstIndex { $0.0 == self || $0.1 == self } ?? 5 }
    var side: Side { Self.pairs[row].0 == self ? .shine : .shade }
    var inverse: TierKey { Self.key(row: row, side: side.flipped) }

    var archetype: String {
        switch self {
        case .G: return "monk"
        case .S: return "fighter"
        case .A: return "wizard"
        case .E: return "warlock"
        case .B: return "paladin"
        case .D: return "barbarian"
        case .C: return "cleric"
        case .R: return "druid"
        case .F: return "bard"
        case .T: return "sorcerer"
        case .Q: return "ranger"
        case .K: return "rogue"
        }
    }

    var tierName: String {
        switch self {
        case .G: return "god"
        case .S: return "super"
        case .A: return "advanced"
        case .E: return "evil"
        case .B: return "basic"
        case .D: return "disgust"
        case .C: return "cure"
        case .R: return "root"
        case .F: return "funny"
        case .T: return "trick"
        case .Q: return "question"
        case .K: return "knockoff"
        }
    }

    var fullName: String { "\(archetype)'s \(tierName)-tier" }

    /// Default explanation of what belongs here (from the design spec).
    var blurb: String {
        switch self {
        case .G: return "Perfected at one thing; probably challenging to get the most out of it."
        case .S: return "Most popular, most advertised as the best, highly hyped."
        case .A: return "Really good at many things, with effort to study and learn."
        case .E: return "Sinister, terrible, frustrating. Maybe useful if mastered, but not recommended."
        case .B: return "Solid performer, easy to learn and use, but maybe a stubborn rule follower."
        case .D: return "Crude and hard to stomach: broken, unreliable, or just gross."
        case .C: return "Has problems that can be worked around; forgiving when things go wrong."
        case .R: return "Original source, raw foundation, not optimized or polished."
        case .F: return "Parodies and jokes."
        case .T: return "Easy to use maybe, but a one-trick pony, and the trick might be a random result that often disappoints."
        case .Q: return "Unknown, to be determined."
        case .K: return "A non-original variant that doesn't add anything important."
        }
    }

    /// Palette: shine colors sit on white rows, shade colors on black rows.
    var hex: UInt32 {
        switch self {
        case .G: return 0xF5B700 // imperial yellow
        case .S: return 0xC8102E // crimson
        case .A: return 0x6E7F8D // steel
        case .E: return 0x2A4BA0 // navy blue (lifted so it reads on black)
        case .B: return 0x4FB3E8 // sky blue
        case .D: return 0x8A5A2E // brown
        case .C: return 0xD1278F // magenta
        case .R: return 0x2E7D32 // forest green
        case .F: return 0x8BD43A // lime green
        case .T: return 0x7E44C0 // purple
        case .Q: return 0x1FB5A6 // turquoise
        case .K: return 0xEE7B22 // orange
        }
    }

    var color: Color { Color(hex: hex) }
    var hexString: String { String(format: "#%06X", hex) }

    private var luminance: Double {
        let r = Double((hex >> 16) & 0xFF), g = Double((hex >> 8) & 0xFF), b = Double(hex & 0xFF)
        return (0.299 * r + 0.587 * g + 0.114 * b) / 255
    }

    /// Text color that stays readable on top of `color`.
    var textColor: Color { luminance > 0.6 ? .black : .white }
    var textHex: String { luminance > 0.6 ? "#000000" : "#FFFFFF" }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
