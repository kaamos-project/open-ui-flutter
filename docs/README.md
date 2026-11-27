# Kaamos UI for Flutter: wiki

`kaamos_project_ui` is the Flutter library of the Kaamos design system. It is the Flutter version of [open-ui-web](https://github.com/kaamos-project/open-ui-web) and uses the same tokens from [open-design-tokens](https://github.com/kaamos-project/open-design-tokens).

- **No Material, no Cupertino**: only `package:flutter/widgets.dart`. Every control is drawn by us, so it looks the same on Linux, macOS, Windows, web, Android and iOS.
- **Versioned tokens**: colours, sizes, typography and the Inter font come from the `kaamos_design_tokens` package, pinned to a tag.
- **Performance first**: `const` constructors, no expensive `Opacity` or `BackdropFilter`, rebuilds only when the theme changes.

## Pages

| Page | What you will find |
|---|---|
| [Getting started](getting-started.md) | Install the library in an app, develop it, run the gallery and the tests |
| [Architecture](architecture.md) | Layers, how a component is built, overlays, tests and golden files |
| [Foundation](foundation.md) | `KaamosApp`, theme, `KaamosPressable`, focus, icons, scroll, anchored overlays, list rows |
| [Decisions](decisions.md) | The key choices and their trade-offs |

## Components

- [Button](components/button.md)
- [Static components](components/static.md): badge, keycap, app icon tile, card, link
- [Form controls](components/form-controls.md): text field, search bar, checkbox, slider, select
- [Overlays](components/overlays.md): popover, menu, dialog
- [Navigation](components/navigation.md): tabs, pill tabs, main bar with mobile drawer
- [Command palette](components/command-palette.md)

The screenshots on these pages are the golden files of the tests, so they always match the code.

## Writing these pages

- One page per topic, in English, linked with relative links only.
- Every page starts with a breadcrumb back to this Home and ends with "See also".
- A pull request that changes a component also updates its page.
