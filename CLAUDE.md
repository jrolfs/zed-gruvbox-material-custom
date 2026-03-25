# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Zed editor extension that bundles a custom Gruvbox Material dark theme with enhanced TypeScript/TSX tree-sitter highlights. Based on [tokiory/zed-gruvbox-material](https://github.com/tokiory/zed-gruvbox-material) with syntax color overrides baked directly into the theme JSON (eliminating the need for `theme_overrides` in Zed's `settings.json`).

## Development

Install as a dev extension: Zed command palette → `zed: install dev extension` → point to this directory. There is no build step, test suite, or linter — Zed compiles grammars and loads the extension directly from source.

The `grammars/tree-sitter-typescript` submodule is pinned to commit `e2c5359`. Zed fetches and compiles grammars from the remote URLs in `extension.toml`, so the submodule serves as a reference/pinned source — do not place compiled `.wasm` files or loose grammar directories (e.g. `grammars/tsx/`) alongside it.

## Architecture

**`extension.toml`** — Extension metadata and grammar declarations. Both `typescript` and `tsx` grammars point to the same `zed-industries/tree-sitter-typescript` repo with different `path` values.

**`themes/gruvbox-material-custom.json`** — Single dark theme. The `syntax` object contains all token colors including custom additions not in the upstream theme:
- `keyword.import`, `keyword.import.source`, `keyword.import.type` — granular import keyword coloring
- `keyword.declaration`, `keyword.control` — keyword subcategories
- `type.builtin` — predefined types like `string`, `number`, `boolean`
- `keyword` uses `font_style: "normal"` to override the base theme's italic

**`languages/TypeScript/highlights.scm`** and **`languages/TSX/highlights.scm`** — Custom tree-sitter highlight queries that override Zed's built-in TypeScript/TSX highlighting. Key customizations:
- **Keyword subcategories**: `@keyword.declaration` (const/let/var/function/class/enum/interface/type), `@keyword.control` (if/for/return/etc.), `@keyword.import` (import/export), `@keyword.import.source` (from), `@keyword.import.type` (the `type` keyword in type imports)
- **Type import awareness**: Inline (`import { type Foo }`) and full (`import type { Foo }`) type imports mark the imported name as `@type` instead of default
- **JSX components** (TSX only): PascalCase JSX elements use `@constructor` (maps to green `#89b482`), HTML tags use `@tag.jsx`
- **ts-pretty-errors** (TypeScript only): `statement_block` → `labeled_statement` pattern that highlights LSP error snippets as property/type pairs

The TSX highlights file includes all TypeScript patterns plus JSX-specific rules (components, HTML tags, attributes, JSX brackets, JSX text).

## Gruvbox Material Color Palette Reference

| Role | Hex |
|------|-----|
| red (keyword, control) | `#ea6962` |
| orange (declaration, operator, tag, variable.special) | `#e78a4e` |
| yellow (string, modified) | `#d8a657` |
| green (function, attribute, created) | `#a9b665` |
| aqua (constructor, variant) | `#89b482` |
| blue (type, type.builtin, hint) | `#7daea3` |
| purple (import, boolean, number, enum, predictive) | `#d3869b` |
| fg (text, property, constant, variable, embedded) | `#d4be98` |
| bg | `#292828` |
