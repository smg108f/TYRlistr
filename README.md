# TYRlistr
a tier list sorting app

See `SPEC.md` for the current specification. `TYRlistr (a rank sorting app).md` is the original design document.

## Run v0.1 (macOS 14+)

From Terminal in this folder:

```
swift run
```

Or open `Package.swift` in Xcode and press Run.

## What v0.1 does

- Six rows, each flipping between its shine and shade tier (tap the tier letter when locked, or the ⇄ badge when unlocked).
- Unlocked: drag items between rows, tap once to select, tap again to open; the arrows move the selected item's rank.
- Locked: tap items to select and open them read-only (Modify to edit); the arrows scroll the row.
- new / edit / open / save (markdown with a JSON block), export to .md, .html or .png, stats view.
- + adds to the selected row (Q by default), − deletes the selection, a whole row, or the whole list (with undo).
- generate is a placeholder; donate, examples, feedback and source open links.
