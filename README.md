# TYRlistr
a tier list sorting app

See `SPEC.md` for the current specification. `TYRlistr (a rank sorting app).md` is the original design document.

## Install v0.2 (macOS 14+)

1. Download `TYRlistr-0.2.dmg` from the [Releases](https://github.com/smg108f/TYRlistr/releases) page. Its SHA-256 checksum is published next to it.
2. Open the DMG and drag TYRlistr into Applications.
3. The app is ad-hoc signed, not notarized by Apple, so the first launch is blocked. Open **System Settings → Privacy & Security**, find the message about TYRlistr, and choose **Open Anyway**.

Before installing any app, it's worth having someone, or an agent, read what it does. The whole source is here, and it's small.

## Build it yourself

From Terminal in this folder:

```
swift run                    # run from source
scripts/package-macos.sh     # build dist/TYRlistr.app and dist/TYRlistr-0.2.dmg
```

Or open `Package.swift` in Xcode and press Run. The packaging script builds a universal app when full Xcode is installed, and a build for your Mac's chip with just the Command Line Tools.

## What v0.2 does

- Six rows, each flipping between its shine and shade tier (tap the tier letter when locked, or the ⇄ badge when unlocked).
- Unlocked: drag items between rows, tap once to select, tap again to open; the arrows move the selected item's rank.
- Locked: tap items to select and open them read-only (Modify to edit); the arrows scroll the row.
- new / edit / open / save (markdown with a JSON block), export to .md, .html or .png, stats view.
- + adds to the selected row (Q by default), − deletes the selection, a whole row, or the whole list (with undo).
- generate copies a prompt for your AI assistant of choice. Paste it in, save the reply as a `.md` file, and open it in TYRlistr.
- donate, examples, feedback and source open links.

## License

- **Code** (`Sources/`, `Package.swift`, `scripts/`): [GNU Affero General Public License v3.0 or later](LICENSE). You can use, study, change and share it, and anything you build from it, including a hosted service, has to be shared under the same terms.
- **Writing and lists** (`SPEC.md`, the design document, `examples/`, `assets/`): [Creative Commons Attribution-NonCommercial-ShareAlike 4.0](LICENSE-CONTENT).

The author may also offer TYRlistr under other terms (for example, an App Store build). If you'd like to contribute code, open an issue first so we can talk about how contributions are licensed.
