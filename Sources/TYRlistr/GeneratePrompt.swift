import Foundation

// The generate button builds a prompt for any AI assistant and puts it on the clipboard.
// The assistant replies with a saved-TYRlist file, which the user opens with `open`.
// Connecting to a provider directly is still an open question (SPEC §7).

extension TYRList {
    func generatePrompt() -> String {
        let iso = ISO8601DateFormatter().string(from: Date())
        let filled = items.filter { !$0.isBlank }
        let topic = name.trimmingCharacters(in: .whitespaces).isEmpty ? "(choose a topic and say what it is)" : name
        func j(_ v: String) -> String {
            v.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        }
        let schemaJSON = schema.map { "\"" + j($0) + "\"" }.joined(separator: ", ")
        let detailsJSON = schema.map { "\"" + j($0) + "\": \"…\"" }.joined(separator: ", ")

        var s = """
        You are helping build a TYRlist: a tier list that sorts things by what *kind* of thing they are, not by best to worst. There are 12 tiers in 6 rows. Each row pairs two opposite tiers.

        Topic: \(topic)
        """
        if !description.isEmpty { s += "\nDescription: \(description)" }
        s += "\nTarget size: about \(placeholders) items (never more than \(TYRList.maxItems))."
        s += "\nExtra fields each item carries in `details`: \(schema.isEmpty ? "none" : schema.joined(separator: ", "))."

        if !filled.isEmpty {
            s += "\n\nItems already placed (keep them unless one clearly belongs in another tier, and say why if you move it):\n"
            for it in filled {
                s += "- \(it.displayGlyph) \(it.title) — \(it.tier.rawValue)"
                if !it.explanation.isEmpty { s += ": \(it.explanation)" }
                s += "\n"
            }
        }

        s += "\n\n## The tiers\n\nRows run top to bottom: G/S, A/E, B/D, C/R, F/T, Q/K.\n\n"
        for t in TierKey.allCases {
            s += "**\(t.rawValue) · \(t.tierName)** — \(t.headline). \(t.belongsHere) Ask: \(t.askYourself)"
            if let w = t.watchOut { s += " Watch out: \(w)" }
            s += "\n\n"
        }

        s += """
        ## How to build the list

        1. Fix the scope: the topic and the level of detail. One item per distinct thing at that level; fold variants into their parent unless the list is about that parent.
        2. Place each item with a one- or two-sentence explanation that matches the tier's description, not just its name. If the reason contradicts the tier, the reason or the tier is wrong.
        3. Judge each item on its own terms, not as the failed version of something else. Read its history and details, not its surface.
        4. Cover all 12 tiers with at least one item. An empty tier usually means the topic needs a closer look or an item is misplaced. Uneven counts are fine.
        5. Use Q honestly for things that can't be evaluated yet.
        6. Items on opposite sides of a row can mirror each other. When you pair them, mention the connection in both explanations.
        7. Give every item a glyph: one emoji or a few letters, never an image.
        8. For real products and companies, keep explanations sharp and factual, and aim criticism at products rather than people.

        ## Reply format

        Reply with a markdown file: a `# title` line, a one-paragraph description, then one fenced `json` block in exactly this shape (only the JSON is read):

        ```json
        {
          "format": "tyrlist/0.1",
          "name": "\(j(topic))",
          "description": "…",
          "creator": "\(j(creator))",
          "thumbnail": "\(j(thumbnail))",
          "placeholders": \(placeholders),
          "schema": [\(schemaJSON)],
          "created": "\(iso)",
          "modified": "\(iso)",
          "items": [
            {
              "id": "a fresh UUID such as 3F2504E0-4F89-11D3-9A0C-0305E82C3301",
              "title": "…",
              "glyph": "🥚",
              "tier": "G",
              "rank": 1,
              "explanation": "…",
              "details": {\(detailsJSON)},
              "locked": false,
              "edits": 0
            }
          ]
        }
        ```

        Rules for the JSON: every field is required; `tier` is one of G S A E B D C R F T Q K; `rank` starts at 1 within each tier; each `id` is a unique UUID; dates are ISO 8601 like the ones above. Add a short note after the JSON block listing any tier you struggled to fill.
        """
        return s
    }
}

