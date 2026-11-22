# TYRlistr — specification

Structured restatement of `TYRlistr (a rank sorting app).md` (the origin document), updated with decisions made since. When the two disagree, this file wins; the origin document is kept as the author's original voice.

## 1. Concept

TYRlistr is an opinionated tier-list builder. Instead of a single best-to-worst ladder, it uses **12 archetypal tiers** arranged as **6 rows**, each row holding a **shine** tier and its **shade** opposite. A row displays one side at a time and can be flipped.

The tiers are a classifier, not a ranking. Each tier names a *kind* of thing (mastery, hype, study, menace, ...). A finished TYRlist is a set where all 12 archetypes have been noticed and recognized.

## 2. Principles

1. **Elegant minimalism.** One item per distinct thing at the list's level of detail. Variants fold into their parent unless the list is about that parent.
2. **Scope sets the point of view.** The list's topic decides granularity and what counts as a variant. In a list of egg dishes, Eggs Florentine is Benedict with spinach; in a list of Benedicts, it is its own item (and lands in C, because it solves a problem for vegetarians).
3. **Defensible, not correct.** A placement is valid when a reasonable story defends it. That story is the item's `explanation`. The same item can honestly belong in different tiers in different lists.
4. **Whole-set coherence.** A list succeeds when the complete set fits together and every archetype is recognized, not merely when each item is placed well. The 12 archetypes are the kinds of beings found in any universe we have conceived, so if something can't be found for every tier, the topic hasn't been considered at a high enough resolution. Coverage is the goal, not balance: some topics will crowd certain tiers, and that's expected.
5. **A boundary of 108.** Any domain of interest should fit within 108 items, because there's a limit to how many distinctions anyone can meaningfully keep track of. The app won't add a 109th item.
6. **Glyphs are placeholders, not portraits.** Every item is shown by a single emoji or a few letters, never an image. A wrong but useful token keeps the list honest about being a model: 🐸 is not Toad, but it points at him well enough. Equal-sized glyphs also give every item the same visual weight, so nothing ranks higher just for looking better.

## 3. The tiers

Rows are ordered top to bottom; within a row, shine is the default side.

| row | key | side | archetype | tier | definition | color |
| --- | --- | ----- | --------- | --------- | ---------- | ----- |
| 1 | G | shine | monk | god | Unsurpassed at one thing. Hard to execute and easy to miss, but reproducible with discipline. | `#F5B700` imperial yellow |
| 1 | S | shade | fighter | super | Most popular, most advertised as the best, highly hyped. Fights for ranked recognition; a trial by fire. | `#C8102E` crimson |
| 2 | A | shine | wizard | advanced | Really good at many things, with effort to study and learn. Feels like alchemy. | `#6E7F8D` steel |
| 2 | E | shade | warlock | evil | Sinister, terrible, frustrating. Maybe useful if mastered, but not recommended. | `#2A4BA0` navy blue |
| 3 | B | shine | paladin | basic | Solid performer, easy to learn and use, but maybe a stubborn rule follower. Keeps its oath; discipline and working with others. | `#4FB3E8` sky blue |
| 3 | D | shade | barbarian | disgust | Crude and hard to stomach: broken, unreliable, or just gross. | `#8A5A2E` brown |
| 4 | C | shine | cleric | cure | Has problems that can be worked around; forgiving when things go wrong. Keeps faith with life rather than with orders. | `#D1278F` magenta |
| 4 | R | shade | druid | root | Original source, raw foundation, the first way anyone learns it; the trunk others branch from, keeping their history. Not optimized or polished; may hide something. | `#2E7D32` forest green |
| 5 | F | shine | bard | funny | Parodies and jokes. | `#8BD43A` lime green |
| 5 | T | shade | sorcerer | trick | Works like a spell: get it exactly right or it fails badly. Possibly a one-trick pony. | `#7E44C0` purple |
| 6 | Q | shine | ranger | question | Unknown, or impossible to evaluate yet. Blank placeholders also live here. | `#1FB5A6` turquoise |
| 6 | K | shade | rogue | knockoff | A non-original variant that adds nothing important; functions like the real thing without being it. | `#EE7B22` orange |

Shine rows have a white background; shade rows have a black background. Label text is black or white, whichever reads better on the tier color.

### What users see

Archetypes and shine/shade are the design model; the app never shows them. Opening a row label shows the tier's letter and name, a headline, what belongs there, a question to ask yourself, a common misplacement where there is one, and the opposite tier on the same row.

| key | headline | ask yourself |
| --- | -------- | ------------ |
| G | Mastered one thing | Does it reward exact, patient practice at a single thing? |
| S | The famous one | Is it known mostly for being known? |
| A | Rewards study | Does it get better the more you learn about it? |
| E | Not recommended | Would you warn someone before they tried it? |
| B | Solid and dependable | Could you hand it to anyone and trust the result? |
| D | Hard to stomach | Is your first reaction to recoil? |
| C | Forgiving | If you mess it up, is it still fine? |
| R | Where it all starts | Is this where most people begin? |
| F | A joke | Does it exist mostly to make people smile? |
| T | All or nothing | Does it only work if everything goes right at once? |
| Q | Can't say yet | Do you actually know enough to place it? |
| K | A stand-in | Is it imitating something better? |

### Anchor examples (list topic: egg dishes)

| key | items | the story |
| --- | ----- | --------- |
| G | Poached egg, Meringue | Hard and soft at once; a speck of yolk ruins it, but discipline makes it repeatable. |
| S | Shirred eggs, Shakshuka | Baked eggs are a trial by fire; shakshuka fights its way onto every ranking. |
| A | Custard, Quiche | Looks like alchemy; several skills that each take study. |
| E | Century egg, Powdered eggs | Sinister and divisive; undead protein with years of shelf life. |
| B | Tamago nigiri, Hard-boiled egg | Assembled from others' work; the hard-boiled detective. |
| D | Raw egg, Scotch egg | Not really a dish; looks like a dung-beetle ball. |
| C | Omelette, Egg drop soup | Forgiving: a botched fold still serves as a scramble. |
| R | Scrambled eggs, Deviled eggs | The first way anyone cooks an egg; a sinister name and room for poison. |
| F | Green eggs and ham, Sunny-side up, Egg-in-a-hole | A joke dish; how a jester feeds their kids. |
| T | Eggs Benedict, Fried egg, Eggnog | Get the spell right or be burned at the stake; sweet milk that can get you drunk. |
| Q | Dragon egg, Golden egg | Lore says stone, metal or magic; impossible to know. You can't eat gold. |
| K | Egg substitute, Easter egg | Not an egg, but functions like one. |

## 4. Classification procedure

For a person or an AI building a list (the *generate* feature):

1. **Fix the scope.** State the topic and the level of detail.
2. **Gather candidates** at that level. Merge variants into their parent (principle 1).
3. **Place each item** with a one- or two-sentence story. The story must match the tier's *definition*, not just the archetype's flavor.
4. **Check coverage.** Every tier should have at least one item. An empty tier means the topic hasn't been considered at a high enough resolution, or an item is misplaced. Uneven counts across tiers are fine.
5. **Use Q honestly.** Put things that can't be evaluated yet in Q, along with any blank placeholders.

Lessons from practice:
- Judge an item on its own terms, not as the failure state of something else. Scrambled eggs aren't D just because a botched omelette turns into them.
- If the reason given contradicts the tier's definition, the reason or the tier is wrong. Example: "fine enough if it misses" contradicts T.
- Read the item's lore, not its surface. The placement usually turns on a canon detail: who made it, what it was made for, what it did when its orders and its conscience disagreed. WALL-E looks like a monk at a glance; his mementos and his love of romance films make him a knight.

How to tell neighbouring tiers apart:
- **G is unsurpassed at its one thing.** Repeating one act perfectly but being beatable is T (Maillardet's Automaton). Doing one job faithfully for centuries is B (WALL-E). Being nearly invulnerable with one fatal weakness is S (Talos). Game masters (Deep Blue, AlphaGo) suit G better than would-be rulers, who rarely turn out to be the best players.
- **S wins on fame and timing, often on others' work.** Difficulty alone is not S. A champion with an Achilles heel, a marketing war or a race to the public are all S stories (ChatGPT, the Sega Genesis, Captain Marvel).
- **A is rare capability among peers**, and E is often the same capability turned dark. Twins and prototypes make natural A/E pairs (Data/Lore, KITT/KARR).
- **B keeps an oath; C keeps faith with life.** A paladin's loyalty is to the oath and can be ordered to do harm; a cleric sides with the injured against the oppressor and won't take an oath that would have it kill (R2-D2). Soldiers are paladins.
- **E sets the terms; D does the dirty work up close.** Patrons, systems and schemers are E (Mother, Skynet). Appetite without restraint, betrayal of people who trusted you, and protectors who become what they were meant to stop are D (Christine, the Golem, Ultron).
- **R is the trunk others branch from and keeps their history**, not merely the first. An oathbreaker who becomes the centre of a community is R (Roz). Druids keep languages and lineage (C-3PO).
- **F laughs; T charms.** Allure, seduction and overselling are a sorceress's magic and belong in T (Sophia, Samantha). The same machine-built-for-one-task story can split across the row: the one who escaped its program is F (Bender), the one the program kept is T.
- **Q is what can't be seen because it isn't here or can't be tested** (betas, the unreleased, Roko's Basilisk, the Simulator). **K is what can't be seen because it's disguised.** The rogue's identity is fluid (the Mechanical Turk, the Cylons).

Pairs:
- Items at the same rank on opposite sides of a row can be read as shine/shade mirrors. A list that has many pairs may turn out to be all pairs if examined from enough points of view.
- When pairing, write the connection into both explanations ("Ava's mirror"). If a pair is hard to guess, the explanation should say how they connect.
- Fixing one weak pair may mean replacing two items or shifting several. Balanced counts across each row are a sign the list is complete, not a requirement.

Scope and purpose:
- A TYRlist is a recommender: each entry is shorthand meant to light up a constellation of sources, peers, clones and contrasts. One item can stand for its kin (Ava covers replicants and hosts) so slots go to distinct ideas.
- Decide the boundary of the kind of thing being listed and say so in the description (an AI-beings list leaves cyborgs and uploads for another list).
- Real products and companies read as opinion next to fictional characters. Keep their explanations especially sharp, aim criticism at products rather than people, and verify factual claims.

## 5. Data

A **TYRlist** has: `name`, `description`, `creator`, `thumbnail`, `placeholders`, `schema` (attribute names every item carries; default `description`), `created`, `modified`, `items`.

An **item** has: `id`, `title`, `glyph` (one emoji or a few letters; no images, see principle 6), `tier`, `rank` (1 = top within its tier), `explanation`, `details` (values for the schema attributes), `locked`, `edits`.

**Placeholders** are the list's total number of slots: 12, 18, 36, 54, 64, 88 or 108. Unfilled slots are blank items in Q. Adding an item fills a blank. Raising the count adds blanks; lowering it removes blanks only. A list may hold more items than its placeholder count (the egg sample is 26 items in 18 slots), up to a hard maximum of 108 items.

**Editing a saved list:** once a person has edited a list in the app, change the saved file in place (its JSON block) rather than regenerating it, so their ranks and edit counts survive. Reopen the file in the app before saving from the app again.

**File format:** markdown (title, description, and a readable tier table) followed by a fenced `json` block containing the full list. Only the JSON block is read back. Dates inside the JSON use ISO 8601.

**Display dates** use `1YYYY.MM.DD HH:MM` (for example, `12026.11.18 13:33`).

## 6. Interface

### Layout

```
| lock | new      | open   | edit     | save     | export | stats |
| <    | G/S      | items ...                            | >     |
| <    | A/E      | items ...                            | >     |
| <    | B/D      | items ...                            | >     |
| <    | C/R      | items ...                            | >     |
| <    | F/T      | items ...                            | >     |
| <    | Q/K      | items ...                            | >     |
| +    | generate | donate | examples | feedback | source | -     |
```

Row labels show the tier letter with the tier name underneath (god, advanced, basic, cure, funny, question / super, evil, disgust, root, trick, knockoff).

### Top bar
- **lock**: toggles locked mode (for browsing a finished list) and unlocked mode (for editing).
- **new**: creates a list (name, description, creator, thumbnail, placeholder count, schema).
- **open / save**: read and write the file format above.
- **edit**: changes the list's settings.
- **export**: `.md`, `.html` or `.png`. Blank placeholders are left out.
- **stats**: swaps the rows for a summary: creator, firstseen, last-mod, total edits, description, filled/blank/placeholder counts, tiers filled (out of 12), and item counts per tier laid out as shine | count | count | shade.

### Rows, locked mode
- `<` / `>` scroll the row.
- Tap a tier letter: flip the row to its inverse.
- Tap an item: select it (border in the tier color, "open" badge). Tap again: open it read-only, with **back**, **modify** and **copy**.

### Rows, unlocked mode
- Drag an item onto another row to move it into that row's visible tier.
- `<` / `>` move the selected item (or the last added item) one rank left or right.
- Tap a tier letter: select the row. Tap again: open the tier's settings. The ⇄ badge flips the row.
- Tap an item: select it. Tap again: open it for editing, with **back**, **lock** (pin its tier and rank) and **delete**.

### Bottom bar
- **+**: add an item to the selected row's tier, or to Q if nothing is selected.
- **generate**: build a list with an AI assistant using the procedure in section 4. In v0.2 it copies a prompt to the clipboard (the list's topic, size, schema and placed items, the tier guidance, this procedure and the file format); the person pastes it into any assistant, saves the reply as `.md` and opens it. Connecting to an assistant directly (Claude, ChatGPT, Gemini, local models) is unresolved.
- **donate**: https://buymeacoffee.com/smg108f
- **examples**: the repo's `examples` directory.
- **feedback**: GitHub issues.
- **source**: https://github.com/smg108f/TYRlistr
- **−**: delete the selected item, the selected row's items, or the whole list (with undo of the last deletion).

## 7. Status

**Built in v0.1:** everything in section 6 except generate and tier customization.

**v0.2:** generate copies a prompt to the clipboard; first installable macOS build (ad-hoc signed DMG from `scripts/package-macos.sh`); code licensed AGPL-3.0-or-later, writing and examples CC BY-NC-SA 4.0.

**Open questions:**
- How generate connects to an AI provider directly.
- Tier customization: name, description, explanation, colors, with a reset to default.
- Platform: v0.2 ships for macOS; iOS/iPadOS needs an app project.
