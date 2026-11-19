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

    /// "G · god": how a tier is named anywhere a user sees it.
    var shortLabel: String { "\(rawValue) · \(tierName)" }

    // Plain-language guidance shown when a row label is opened.
    // Archetypes and shine/shade stay in SPEC.md; users see only these.

    var headline: String {
        switch self {
        case .G: return "Mastered one thing"
        case .S: return "The famous one"
        case .A: return "Rewards study"
        case .E: return "Not recommended"
        case .B: return "Solid and dependable"
        case .D: return "Hard to stomach"
        case .C: return "Forgiving"
        case .R: return "Where it all starts"
        case .F: return "A joke"
        case .T: return "All or nothing"
        case .Q: return "Can't say yet"
        case .K: return "A stand-in"
        }
    }

    var belongsHere: String {
        switch self {
        case .G: return "Hard to get right and easy to miss, but repeatable by anyone with the discipline to do it exactly the same way every time."
        case .S: return "The most popular, most advertised, most hyped choice. It has to keep fighting to prove it deserves the attention."
        case .A: return "Good at many things once you've learned how. It combines several skills, and from the outside it can look like alchemy."
        case .E: return "Sinister, frustrating or off-putting. It might pay off for someone who masters it, but you wouldn't suggest it to a friend."
        case .B: return "Easy to learn, does what it says and works well with others. It may be a bit of a stickler for the rules."
        case .D: return "Crude, broken, unreliable or just gross."
        case .C: return "It has flaws, but they can be worked around, and it holds up when things go wrong."
        case .R: return "The original, or the first version everyone learns. Raw and unpolished, and sometimes there's more to it than it seems."
        case .F: return "Parodies, gags and things nobody takes seriously."
        case .T: return "Works like a spell: when everything goes exactly right it's impressive, and when anything misses it falls apart. Sometimes a one-trick pony."
        case .Q: return "Unknown, untried or impossible to judge. New blank slots wait here until they're filled in."
        case .K: return "A copy or variant that doesn't add anything important. It works like the real thing without being it."
        }
    }

    var askYourself: String {
        switch self {
        case .G: return "Does it reward exact, patient practice at a single thing?"
        case .S: return "Is it known mostly for being known?"
        case .A: return "Does it get better the more you learn about it?"
        case .E: return "Would you warn someone before they tried it?"
        case .B: return "Could you hand it to anyone and trust the result?"
        case .D: return "Is your first reaction to recoil?"
        case .C: return "If you mess it up, is it still fine?"
        case .R: return "Is this where most people begin?"
        case .F: return "Does it exist mostly to make people smile?"
        case .T: return "Does it only work if everything goes right at once?"
        case .Q: return "Do you actually know enough to place it?"
        case .K: return "Is it imitating something better?"
        }
    }

    /// Common misplacements, when there is a known one.
    var watchOut: String? {
        switch self {
        case .G: return "Hard and hyped is super. Hard because it combines many skills is advanced."
        case .S: return "Being difficult doesn't make something super. Popularity does."
        case .D: return "Judge a thing on its own terms, not as the failed version of something else."
        case .T: return "If it's still fine when it misses, it belongs in cure."
        case .K: return "If the list isn't about the original, fold the variant into it instead of listing both."
        default: return nil
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
