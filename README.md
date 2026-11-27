# open-ui-flutter

The **Kaamos Project** design system for Flutter: the Dart package `kaamos_project_ui`.
It is the Flutter version of [open-ui-web](https://github.com/kaamos-project/open-ui-web) and uses the same tokens from [open-design-tokens](https://github.com/kaamos-project/open-design-tokens).

- **No Material, no Cupertino**: only `package:flutter/widgets.dart`. Every control is drawn by us, so it looks the same on Linux, macOS, Windows, web, Android and iOS. A test (`test/architecture_test.dart`) blocks forbidden imports.
- **Versioned tokens**: colours, sizes, typography and the Inter font come from the `kaamos_design_tokens` package, pinned to a tag.
- **Performance first**: `const` constructors, no expensive `Opacity` or `BackdropFilter`, rebuilds only when the theme changes.

## Installation

It isn't on pub.dev: use it as a git dependency, pinned to a tag.

```yaml
dependencies:
  kaamos_project_ui:
    git:
      url: https://github.com/kaamos-project/open-ui-flutter
      ref: v0.1.0
```

## Documentation

Everything lives in the wiki in [`docs/`](docs/README.md):

- [Getting started](docs/getting-started.md): install, develop, gallery, tests
- [Architecture](docs/architecture.md) and [Decisions](docs/decisions.md)
- [Foundation](docs/foundation.md): `KaamosApp`, theme, `KaamosPressable`, focus, icons, scroll, anchored overlays, list rows
- Components: [Button](docs/components/button.md), [Static](docs/components/static.md), [Form controls](docs/components/form-controls.md), [Overlays](docs/components/overlays.md), [Navigation](docs/components/navigation.md), [Command palette](docs/components/command-palette.md)

## Development

```sh
flutter pub get
flutter analyze
flutter test                      # widget tests + golden tests
flutter test --update-goldens     # regenerate the reference screenshots (on Linux only)

cd example && flutter run -d linux   # the gallery (also: macos, windows, chrome)
```

## License

GPL-3.0, see [LICENSE](LICENSE). The Inter font is under SIL OFL 1.1 (included in the tokens package).
