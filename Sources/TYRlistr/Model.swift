import Foundation

struct TierItem: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    /// The item's graphic for now: an emoji or a few letters.
    var glyph: String
    var tier: TierKey
    /// Position within its tier, 1 = top rank.
    var rank: Int
    /// Why the item sits in its current tier.
    var explanation: String
    /// Values for the list's schema attributes (e.g. "description").
    var details: [String: String]
    var locked: Bool
    var edits: Int

    init(title: String, glyph: String = "", tier: TierKey, rank: Int,
         explanation: String = "", details: [String: String] = [:]) {
        self.id = UUID()
        self.title = title
        self.glyph = glyph
        self.tier = tier
        self.rank = rank
        self.explanation = explanation
        self.details = details
        self.locked = false
        self.edits = 0
    }

    /// A placeholder slot waiting to be filled in.
    var isBlank: Bool { title.trimmingCharacters(in: .whitespaces).isEmpty }

    var displayGlyph: String {
        if !glyph.isEmpty { return glyph }
        return isBlank ? "+" : String(title.prefix(1)).uppercased()
    }

    static func blank(rank: Int) -> TierItem { TierItem(title: "", tier: .Q, rank: rank) }

    var summary: String {
        var s = "\(displayGlyph) \(title) — \(tier.shortLabel), rank \(rank)"
        if !explanation.isEmpty { s += "\n\(explanation)" }
        for (k, v) in details.sorted(by: { $0.key < $1.key }) where !v.isEmpty { s += "\n\(k): \(v)" }
        return s
    }
}

struct TYRList: Codable {
    var format: String
    var name: String
    var description: String
    var creator: String
    var thumbnail: String
    var placeholders: Int
    /// Attribute names every item carries.
    var schema: [String]
    var created: Date
    var modified: Date
    var items: [TierItem]

    init(name: String, description: String = "", creator: String = "", thumbnail: String = "",
         placeholders: Int = 36, schema: [String] = ["description"], items: [TierItem] = []) {
        self.format = "tyrlist/0.1"
        self.name = name
        self.description = description
        self.creator = creator
        self.thumbnail = thumbnail
        self.placeholders = placeholders
        self.schema = schema
        self.created = Date()
        self.modified = self.created
        self.items = items
        fillPlaceholders()
    }

    static let placeholderOptions = [12, 18, 36, 54, 64, 88, 108]
    /// Any domain should fit within 108 meaningful distinctions.
    static let maxItems = 108

    /// Top the list up with blank items in Q until it has `placeholders` slots.
    mutating func fillPlaceholders() {
        while items.count < placeholders {
            items.append(.blank(rank: items(in: .Q).count + 1))
        }
    }

    /// Change the slot count: add blanks to Q, or drop blanks (never filled items) to shrink.
    mutating func resizePlaceholders(to n: Int) {
        placeholders = n
        fillPlaceholders()
        while items.count > placeholders, let i = items.lastIndex(where: { $0.isBlank }) {
            items.remove(at: i)
        }
    }

    /// Tiers that hold at least one filled item.
    var recognizedTiers: [TierKey] { TierKey.allCases.filter { t in items.contains { $0.tier == t && !$0.isBlank } } }

    var filledCount: Int { items.filter { !$0.isBlank }.count }
    var blankCount: Int { items.count - filledCount }

    func items(in tier: TierKey) -> [TierItem] {
        items.filter { $0.tier == tier }.sorted { $0.rank < $1.rank }
    }

    var fileStem: String {
        let s = name.lowercased().map { $0.isLetter || $0.isNumber ? $0 : "-" }
        let stem = String(s).split(separator: "-").joined(separator: "-")
        return stem.isEmpty ? "tyrlist" : stem
    }

    /// Sean's preferred date style: 1YYYY.MM.DD (Holocene-style year), plus 24h time.
    static func displayDate(_ date: Date, withTime: Bool = true) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        var s = String(format: "1%04d.%02d.%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
        if withTime { s += String(format: " %02d:%02d", c.hour ?? 0, c.minute ?? 0) }
        return s
    }

    static var sample: TYRList {
        let entries: [(TierKey, String, String, String)] = [
            (.G, "🥚", "Poached egg", "Hard and soft at once, the chaos egg. A true god could poach any animal's egg to perfect texture. Good luck with fish eggs."),
            (.G, "☁️", "Meringue", "One technique, perfected. A speck of yolk ruins it, but follow the discipline and it comes out the same every time."),
            (.S, "🔥", "Shirred eggs", "Baked eggs: a trial by fire."),
            (.S, "🍅", "Shakshuka", "Fights its way into every ranking it can find."),
            (.A, "🍮", "Custard", "Looks like alchemy."),
            (.A, "🥧", "Quiche", "Pastry, custard and fillings: several skills that each take study."),
            (.E, "🖤", "Century egg", "Looks sinister and divides people. Maybe rewarding once you acquire the taste, but not a first recommendation."),
            (.E, "🧟", "Powdered eggs", "Undead protein with years of shelf life."),
            (.B, "🍣", "Tamago nigiri", "Discipline and working with others: assembled from three parts that can come from others' work."),
            (.B, "🕵️", "Hard-boiled egg", "The hard-boiled detective."),
            (.D, "🥄", "Raw egg", "Not really a dish, and the riskiest way to eat one."),
            (.D, "🪲", "Scotch egg", "Cooks up looking like a dung-beetle ball."),
            (.C, "🫕", "Omelette", "Forgiving: clears out leftovers, and a botched fold still looks like a scramble once it's cut up."),
            (.C, "🥣", "Egg drop soup", "Forgiving and restorative."),
            (.R, "🍲", "Scrambled eggs", "The root of learning to cook: the first way anyone learns to prepare an egg."),
            (.R, "😈", "Deviled eggs", "Sinister name, real effort, and a chance to slip in some poison if needs be."),
            (.F, "🟢", "Green eggs and ham", "A joke dish."),
            (.F, "🌞", "Sunny-side up", "How a jester feeds their kids."),
            (.F, "🍞", "Egg-in-a-hole", "How a jester feeds their kids."),
            (.T, "🍽️", "Eggs Benedict", "Get the spell right or be burned at the stake: the priciest egg dish on the menu and rarely worth it."),
            (.T, "🍳", "Fried egg", "Same result whenever you can pull off the spell."),
            (.T, "🥛", "Eggnog", "Sweet milk that can get you drunk."),
            (.Q, "🐉", "Dragon egg", "Impossible to evaluate. Lore says stone, metal or non-terran materials, hatched by magic."),
            (.Q, "🪙", "Golden egg", "Mythic, and you can't eat gold."),
            (.K, "🧴", "Egg substitute", "Not really an egg, but sort of functions like one."),
            (.K, "🐣", "Easter egg", "Plastic, chocolate or dyed: a stand-in for the real thing."),
        ]
        let descriptions: [String: String] = [
            "Poached egg": "An egg cracked into barely simmering water and cooked out of its shell until the white sets around a runny yolk.",
            "Meringue": "Egg whites whipped with sugar into stiff peaks, then baked dry or used as a topping.",
            "Shirred eggs": "Eggs baked in a shallow dish, usually with butter or cream, until the whites set.",
            "Shakshuka": "Eggs poached in a spiced tomato and pepper sauce and served in the pan. North African in origin.",
            "Custard": "Eggs and milk or cream cooked gently until thick. The base of flan, crème brûlée and pastry cream.",
            "Quiche": "A savory open tart of eggs and cream baked in pastry with fillings such as cheese, bacon or vegetables.",
            "Century egg": "A duck, chicken or quail egg preserved for weeks or months in clay, ash, salt and lime until the white turns to dark jelly and the yolk turns creamy. Chinese.",
            "Powdered eggs": "Whole eggs dried into a powder and mixed back with water. Used in camping, military and emergency food.",
            "Tamago nigiri": "Sushi of sweet, layered rolled omelette (tamagoyaki) on pressed vinegared rice, often tied with a band of nori.",
            "Hard-boiled egg": "An egg boiled in its shell until the white and yolk are fully set.",
            "Raw egg": "An uncooked egg, eaten as is, mixed into drinks, or stirred into hot rice as tamago kake gohan.",
            "Scotch egg": "A boiled egg wrapped in sausage meat, coated in breadcrumbs and fried or baked. British.",
            "Omelette": "Beaten eggs cooked flat in a pan and folded around fillings.",
            "Egg drop soup": "Hot broth with beaten egg poured in so it sets into thin ribbons. Chinese.",
            "Scrambled eggs": "Beaten eggs stirred in a pan as they cook into soft curds.",
            "Deviled eggs": "Hard-boiled egg halves whose yolks are mashed with mayonnaise, mustard and seasoning and piped back in.",
            "Green eggs and ham": "From Dr. Seuss's 1960 book. In real kitchens, eggs tinted green with herbs or food coloring and served with ham.",
            "Sunny-side up": "An egg fried on one side only, with the yolk up and runny.",
            "Egg-in-a-hole": "An egg fried inside a hole cut in a slice of bread.",
            "Eggs Benedict": "An English muffin topped with ham or Canadian bacon, a poached egg and hollandaise sauce.",
            "Fried egg": "An egg cooked in hot fat in a pan, flipped or not.",
            "Eggnog": "A chilled drink of milk, cream, sugar and beaten eggs spiced with nutmeg, often spiked with rum, brandy or bourbon.",
            "Dragon egg": "A mythical egg. In legend and fiction it is often stone- or metal-like and hatched by fire or magic.",
            "Golden egg": "The egg of solid gold laid by the goose in Aesop's fable.",
            "Egg substitute": "Products that stand in for eggs in cooking: liquid egg whites, plant-based blends, or binders like flax and aquafaba.",
            "Easter egg": "A decorated egg given at Easter: dyed and hard-boiled, made of chocolate, or plastic and filled with candy.",
        ]
        var items: [TierItem] = []
        for (tier, glyph, title, why) in entries {
            let rank = items.filter { $0.tier == tier }.count + 1
            let about = descriptions[title].map { ["description": $0] } ?? [:]
            items.append(TierItem(title: title, glyph: glyph, tier: tier, rank: rank, explanation: why, details: about))
        }
        return TYRList(name: "Sample: egg dishes",
                       description: "A demo list to poke at. Unlock it, drag things around, flip rows, then start your own with new.",
                       creator: "smg108f", thumbnail: "🥚", placeholders: 18, items: items)
    }
}

// MARK: - Saving and exporting

extension TYRList {
    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// Save format: readable markdown on top, the full list as a JSON block underneath.
    func saveText() throws -> String {
        let json = String(decoding: try Self.encoder.encode(self), as: UTF8.self)
        return markdownDocument() + "\n```json\n" + json + "\n```\n"
    }

    static func load(from text: String) throws -> TYRList {
        var jsonText = text
        if let start = text.range(of: "```json"),
           let end = text.range(of: "```", range: start.upperBound..<text.endIndex) {
            jsonText = String(text[start.upperBound..<end.lowerBound])
        }
        return try decoder.decode(TYRList.self, from: Data(jsonText.utf8))
    }

    func markdownDocument() -> String {
        var s = "# \(thumbnail.isEmpty ? "" : thumbnail + " ")\(name)\n\n"
        if !description.isEmpty { s += description + "\n\n" }
        s += "| TYR | tier | items |\n| --- | --- | --- |\n"
        for tier in TierKey.allCases {
            let names = items(in: tier).filter { !$0.isBlank }.map { "\($0.displayGlyph) \($0.title)".replacingOccurrences(of: "|", with: "\\|") }
            s += "| \(tier.rawValue) | \(tier.tierName) | \(names.joined(separator: ", ")) |\n"
        }
        return s
    }

    func html() -> String {
        func esc(_ s: String) -> String {
            s.replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
        }
        func label(_ t: TierKey) -> String {
            "<th style=\"background:\(t.hexString);color:\(t.textHex)\">\(t.rawValue)<small>\(t.tierName)</small></th>"
        }
        func cell(_ t: TierKey) -> String {
            let tiles = items(in: t).filter { !$0.isBlank }.map { "<span class=\"tile\"><b>\(esc($0.displayGlyph))</b>\(esc($0.title))</span>" }
            return "<td class=\"\(t.side.rawValue)\">\(tiles.joined())</td>"
        }
        var rows = ""
        for r in 0..<6 {
            let a = TierKey.key(row: r, side: .shine), b = TierKey.key(row: r, side: .shade)
            rows += "<tr>\(label(a))\(cell(a))\(cell(b))\(label(b))</tr>\n"
        }
        return """
        <!DOCTYPE html>
        <html><head><meta charset="utf-8"><title>\(esc(name))</title>
        <style>
        body{font-family:-apple-system,system-ui,sans-serif;margin:24px;background:#888}
        h1{margin:0 0 4px}p{margin:0 0 16px}
        table{border-collapse:separate;border-spacing:2px;width:100%}
        th{width:64px;font-size:28px;border-radius:8px;padding:6px}
        th small{display:block;font-size:11px;font-weight:600}
                td{padding:6px;vertical-align:middle}
        td.shine{background:#fff;color:#000}td.shade{background:#000;color:#fff}
        .tile{display:inline-flex;flex-direction:column;align-items:center;width:72px;margin:3px;padding:6px 2px;border-radius:8px;font-size:11px;text-align:center}
        td.shine .tile{background:#eee}td.shade .tile{background:#292929}
        .tile b{font-size:26px}
        </style></head><body>
        <h1>\(esc(thumbnail)) \(esc(name))</h1><p>\(esc(description))</p>
        <table>
        \(rows)</table></body></html>
        """
    }
}
