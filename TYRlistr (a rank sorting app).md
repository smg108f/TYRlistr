TYRlistr is an opinionated tier list builder app. it's interface consists of 6-rows that can be flipped between a shine and shade version. objects within the list should default to a graphic that expands into a list of details when double clicked. single click and drag should allow for moving them between rows.

#### target interface
---
SwiftUI app that saves a structured text file into a directory such as a GitHub repo.

##### layout
| lock | new      | open   | edit     | save     | export | stats |
| ---- | -------- | ------ | -------- | -------- | ------ | ----- |
| <    | G/S      |        |          |          |        | >     |
| <    | A/E      |        |          |          |        | >     |
| <    | B/D      |        |          |          |        | >     |
| <    | C/R      |        |          |          |        | >     |
| <    | F/T      |        |          |          |        | >     |
| <    | Q/K      |        |          |          |        | >     |
| +    | generate | donate | examples | feedback | source | -     |

##### default-palette
| shine       | colors                   | colors              | shade         |
| ----------- | ------------------------ | ------------------- | ------------- |
| MONK (G)    | imperial yellow on white | crimson on black    | fighter (S)   |
| WIZARD (A)  | steel on white           | navy-blue on black  | warlock (E)   |
| PALADIN (B) | sky-blue on white        | brown on black      | barbarian (D) |
| CLERIC (C)  | magenta on white         | lime-green on black | druid (R)     |
| BARD (F)    | forest-green on black    | purple on black     | sorcerer (T)  |
| RANGER (Q)  | turquoise on white       | orange on black     | rogue (K)     |

#### reasoning
---

| TYR | listR                                                                                                                              | pov   | order |
| --- | ---------------------------------------------------------------------------------------------------------------------------------- | ----- | ----- |
| G   | monk's god-tier (perfected at one thing, probably challenging to get the most out of it)                                           | shine | 1     |
| S   | fighter's super-tier (most popular, most advertised as the best, highly hyped)                                                     | shade | 1     |
| A   | wizard's advanced-tier (really good at many things with effort to study and learn)                                                 | shine | 2     |
| E   | warlock's evil tier (sinister, terrible, frustrating, maybe useful if mastered, but not recommended)                               | shade | 2     |
| B   | paladin basic tier (solid performer, easy to learn/use, but )                                                                      | shine | 3     |
| D   | barbarian's defective-tier (broken, unreliable, inconsistent)                                                                      | shade | 3     |
| C   | cleric's curable-tier (has problems that can be worked around)                                                                     | shine | 4     |
| R   | druid's root-tier (original source, raw foundation, not optimized or polished)                                                     | shade | 4     |
| F   | bard's folly-tier (parodies, jokes)                                                                                                | shine | 5     |
| T   | sorcerer's trick-tier (easy to use maybe, but kind of a one-trick pony, trick might also be a random result that sucks frequently) | shade | 5     |
| Q   | ranger's Quest-tier (unknown, TBD)                                                                                                 | shine | 6     |
| K   | rogue's knockoff-tier (non-original variant that doesn't really add anything important)                                            | shade | 6     |

#### controls
---
##### top
lock
a button to lock/unlock the list for ease of finger scrolling through a completed TYRlist

new
creates a new TYRlist with a name, description, thumbnail, set number of placeholders (12,18, 36, 54, 64, 108), schema for list (i.e. attributes that each of the placeholders will have)

open
opens an existing TYRlist saved file

edit
allows for changing the settings for an existing TYRlist

save
allows for the saving of a TYRlist to a local directory into an efficient file type. (.md with JSON maybe?)

export
allows for exporting a completed TYRlist to png, html or md.

stats
swaps the interface to a summary about the TYRlist including : creator alias, firstseen (created date), last-mod (modified date), edits (total count across all items), description, item count in following format:

| -   | #   | #   | -   |
| --- | --- | --- | --- |
| G   |     |     | S   |
| A   |     |     | E   |
| B   |     |     | D   |
| C   |     |     | R   |
| F   |     |     | T   |
| K   |     |     | Q   |

##### middle (when UI is locked)
<-
scrolls the members of a row to the left (backward). stops at first row item.

click a row-label
swaps that row to it's inverse shine/shade

click a selected row-label
- unselects it turning off the palette color boarder
- returns the full height visual of item list

click an item
- selects it adding a palette color boarder
- adds "open" over the existing item visual

click a selected item
- replaces the UI with a form to review the contents of the list item
- the schema of the TYRlist determines what's available (ex. tier, rank, edits (total count for item), thumbnail, creator-alias, description (of what it is), explanation (for current tier placement), etc.
- secondary top navigation buttons: back (to TYRlist UI), modify (opened item), copy (existing item contents to the clipboard for pasting into something else)

->
scrolls the members of a row to the right (forward). stops at last row item.

##### middle (when UI is unlocked)
<-
moves a selected item to the left (decreasing rank order by one). defaults to moving the last added item. row-order is a required attribute of all list items. 1 being the top rank.

click a row-label
- selects all members of that row adding a palette color boarder around them.
- adds an "open" button over the row-label

click a selected row-label
- replaces the UI with a form to review the intent and settings of the tier 
- secondary top navigation buttons: back (to TYRlist UI), modify (opened tier), default (resets user modifications to the tier)
- potential modifications : thumbnail, tier name, description (of what it is), explanation (for what belongs in it), background color, accent color

click an item
- selects it adding a palette color boarder
- adds "open" over the existing item visual

click a selected item
- opens the item's form in modify-mode
- secondary top navigation buttons : back (to TYRlist UI), lock (item settings so that it can't be accidentally moved into other tiers or have it's rank changed), delete (confirmation dialog to delete item)

->
moves a selected item to the right (increasing rank order by one). defaults to selecting the last added item.

##### bottom
+
adds an item to the selected row defaulting to Q if none is active

generate (when UI is locked)
triggers an agent to help build a TYRlist on a given topic after some clarifying questions by using it's internal definition of what should be in each row/side.

generate (when UI is unlocked or on first-run)
changes the UI to a settings form for configuring a preferred AI assistant (Gemini, ChatGPT, Claude, local models, etc.). i'm not sure how to implement this as i think it would take an agent that can write longer files that a free-prompt might not be able to handle. 

donate
goes to https://buymeacoffee.com/smg108f

examples
goes to a Github directory where i've saved interesting TYRlists

feedback
goes to an input form of some sort. buglist in Github maybe? email seems lame, but could work.

source
directs to the github repo that that app can be installed from

-
triggers a yes/no confirmation to delete all the items in a row or a specific selected item. default without anything selected asks if you want to delete all the items in the TYRlist or undo the last deletion event
