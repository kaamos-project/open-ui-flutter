# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/). Versioni: [SemVer](https://semver.org/lang/it/).

## [Unreleased]

### Added

- Fondamenta: `KaamosApp`, `KaamosTheme`/`KaamosThemeData`, `KaamosPressable`, `KaamosFocusRing`.
- `KaamosButton` con le varianti `primary`, `secondary`, `tertiary`, `install`.
- Gallery app in `example/` (desktop, mobile, web).
- Dipendenza da `kaamos_design_tokens` v0.2.0.
- Icone: `KaamosIcon` con il set completo di Lucide (`KaamosIcons`, riesportato da `kaamos_design_tokens`), al posto delle 8 icone disegnate con `CustomPaint`. `KaamosIcons.close` ora si chiama `KaamosIcons.x`.
- `KaamosScrollBehavior`, `KaamosAnchoredOverlay`, `KaamosPopoverSurface`, `KaamosListRow`.
- Componenti statici: `KaamosBadge`, `KaamosKeycap`, `KaamosAppIconTile`, `KaamosCard`, `KaamosLink`.
- Form: `KaamosTextField`, `KaamosSearchBar`, `KaamosCheckbox`, `KaamosSlider`, `KaamosSelect`.
- Overlay: `KaamosPopover`, `KaamosMenu`, `showKaamosDialog` + `KaamosDialog`.
- Navigazione: `KaamosTabs`, `KaamosPillTab`, `KaamosNavBar` con cassetto mobile.
- Command palette: `showKaamosCommandPalette`, `KaamosCommandPaletteShortcut`.
- `KaamosFab`: floating action button, extended (icon + label) or collapsed to the icon.
- `KaamosChip`: a visible chip for labels, recipients and files, with an optional X; `KaamosThemeData.hairlineSoft`.
- `showKaamosDrawer` + `KaamosDrawerPanel`: a generic modal drawer from the left; `showKaamosNavDrawer` now uses it.

### Changed

- Il pacchetto si chiama `kaamos_project_ui` (prima `kaamos_ui`).
