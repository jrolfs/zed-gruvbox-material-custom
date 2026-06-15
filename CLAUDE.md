# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Zed editor extension that bundles custom Gruvbox Material themes (dark + light) with enhanced TypeScript/TSX tree-sitter highlights. Based on [GaussianWonder/zed-gruvbox-material](https://github.com/GaussianWonder/zed-gruvbox-material) (v0.2.0 schema) with syntax color overrides on the dark variant baked directly into the theme JSON (eliminating the need for `theme_overrides` in Zed's `settings.json`). The light variant is included as-is from the upstream base.

## Development

Install as a dev extension: Zed command palette → `zed: install dev extension` → point to this directory. There is no build step, test suite, or linter — Zed compiles grammars and loads the extension directly from source.

The `grammars/tree-sitter-typescript` submodule is pinned to commit `e2c5359`. Zed fetches and compiles grammars from the remote URLs in `extension.toml`, so the submodule serves as a reference/pinned source — do not place compiled `.wasm` files or loose grammar directories (e.g. `grammars/tsx/`) alongside it.

## Architecture

**`extension.toml`** — Extension metadata and grammar declarations. Both `typescript` and `tsx` grammars point to the same `zed-industries/tree-sitter-typescript` repo with different `path` values.

**`themes/gruvbox-material-custom.json`** — Dark and light themes (schema v0.2.0). The dark variant's `syntax` object carries overrides on top of the GaussianWonder base plus custom additions:
- Overrides from base: `attribute` (`#a9b665`), `constant` (`#d4be98`), `constructor` (`#e78a4e`), `function` (`font_weight: 400`), `label` (`#000000`), `variable.special` (`#e78a4e`)
- `keyword.import`, `keyword.import.source`, `keyword.import.type` — granular import keyword coloring
- `keyword.declaration`, `keyword.control` — keyword subcategories
The light variant uses GaussianWonder defaults except for the same keyword subcategories as dark, mapped to the light palette so the custom `highlights.scm` captures match across both variants: `keyword.import` purple (`#945e80`), `keyword.declaration` orange (`#c35e0a`), and `keyword.control` / `keyword.import.source` / `keyword.import.type` red (`#c14a4a`). (Without these, Zed's prefix fallback resolved them all to the base `keyword` red.) The GaussianWonder base also provides tokens not in the old tokiory base: `function.builtin`, `function.method`, `variable.member`, `variable.parameter`, `namespace`, `selector`, `lifetime`, etc.

**UI surface layering** — Both variants separate the editor surface from the surrounding chrome (title/tab/status bars, panels, terminal dock) by a single very-low-contrast step, so surfaces aren't flat-uniform. The chrome recedes one tiny step darker than the editor. The **active** tab matches the chrome/toolbar it connects to (breadcrumb path bar, search bar) so the tab + toolbar read as one strip; **inactive** tabs sit at the editor color.
- Dark: editor `#343231` (bg0 soft, lifted one ~2/channel step from the original `#32302f`), chrome `#32302f` — a custom ~2/channel step below the editor (earlier `#292828`/`#2d2b2a` attempts read as too harsh); floats rise lighter (`surface` `#3c3836`, `elevated` `#45403d`).
- Light: editor `#ebdbb2` (the classic gruvbox light bg, a touch darker than the `#f2e5bc` soft base), chrome `#e7d6ad` one step darker. Both tiers were dropped by the same delta from the prior `#f2e5bc`/`#eee0b7` pairing to keep the gap constant. The popover/menu surface (`elevated_surface` `#eee0b7`) rises one step *above* the editor so the `#e0cfa9` selection/hover tints read against it (at `#e0cfa9` they composited to delta 0 — invisible); the panel overlay scrim stays `#e0cfa9`. The active-line highlight (`#e7d6ad70`) tracks the chrome tier so it stays a hair darker than the editor.

**`languages/TypeScript/highlights.scm`** and **`languages/TSX/highlights.scm`** — Custom tree-sitter highlight queries that override Zed's built-in TypeScript/TSX highlighting. Key customizations:
- **Keyword subcategories**: `@keyword.declaration` (const/let/var/function/class/enum/interface/type), `@keyword.control` (if/for/return/etc.), `@keyword.import` (import/export), `@keyword.import.source` (from), `@keyword.import.type` (the `type` keyword in type imports)
- **Type import awareness**: Inline (`import { type Foo }`) and full (`import type { Foo }`) type imports mark the imported name as `@type` instead of default
- **JSX components** (TSX only): PascalCase JSX elements use `@constructor` (orange — dark `#e78a4e`, light `#c35e0a`, matching VSCode/Cursor), HTML tags use `@tag.jsx`
- **ts-pretty-errors** (TypeScript only): `statement_block` → `labeled_statement` pattern that highlights LSP error snippets as property/type pairs

The TSX highlights file includes all TypeScript patterns plus JSX-specific rules (components, HTML tags, attributes, JSX brackets, JSX text).

## Gruvbox Material Color Palette Reference

| Role | Hex |
|------|-----|
| red (keyword, control) | `#ea6962` |
| orange (declaration, operator, tag, variable.special, constructor) | `#e78a4e` |
| yellow (string, modified) | `#d8a657` |
| green (function, attribute, created) | `#a9b665` |
| aqua (variant) | `#89b482` |
| blue (type, type.builtin, hint) | `#7daea3` |
| purple (import, boolean, number, enum, predictive) | `#d3869b` |
| fg (text, property, constant, variable, embedded) | `#d4be98` |
| bg | `#292828` |
