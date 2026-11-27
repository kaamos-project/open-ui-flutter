[Home](README.md) › Getting started

# Getting started

## Use it in an app

It isn't on pub.dev: use it as a git dependency, pinned to a tag (or to a commit until the first tag exists).

```yaml
dependencies:
  kaamos_project_ui:
    git:
      url: https://github.com/kaamos-project/open-ui-flutter
      ref: v0.1.0
```

```dart
import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

void main() => runApp(const KaamosApp(title: 'Kaamos', home: Home()));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: KaamosButton(onPressed: () {}, child: const Text('Download')),
    );
  }
}
```

`kaamos_project_ui` re-exports the tokens: `KaamosColors`, `KaamosTypography`, `KaamosSpacing`… are already available, no need to add `kaamos_design_tokens` yourself.

## Develop the library

Requires **Flutter 3.50.1**, the version pinned in CI (a new version can change the rendering by a few pixels and break the golden tests).

```sh
flutter pub get
flutter analyze
flutter test                      # widget tests + golden tests
flutter test --update-goldens     # regenerate the reference screenshots

cd example && flutter run -d linux   # the gallery (also: macos, windows, chrome)
```

## Repo layout

```
lib/
  kaamos_project_ui.dart    public API (exports only)
  src/foundation/           theme, app, pressable, focus ring, icons, scroll, overlays
  src/components/<name>/    one component per folder
test/                       same structure as lib/, golden files in goldens/
example/                    gallery app (lib/sections/ one file per group)
docs/                       this wiki
```

## Checks (the same as CI)

`.github/workflows/ci.yml` runs on Linux for every push to `main` and every pull request:

```sh
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
cd example && flutter pub get && flutter analyze && flutter build web --no-web-resources-cdn
```

If a golden test fails, CI uploads the `failures/` images as an artifact so you can see the difference.

### Golden files are generated on Linux

Golden tests compare screenshots pixel by pixel. Text rendering differs between operating systems, so the files in `test/**/goldens/` are generated **on Linux** with the Flutter version in CI. If you regenerate them on macOS or Windows, CI will fail. See [Architecture](architecture.md#tests-and-golden-files).

## Adding a component

1. `lib/src/components/<name>/<name>.dart`, built on `KaamosPressable` and the theme (see [Architecture](architecture.md#how-a-component-is-built)).
2. Export it from `lib/kaamos_project_ui.dart`.
3. Widget test and golden test in `test/components/<name>/`.
4. A section in the gallery (`example/lib/sections/`).
5. Its page in `docs/components/`, linked from the [Home](README.md#components), and a line in `CHANGELOG.md`.

## See also

- [Architecture](architecture.md)
- [Foundation](foundation.md)
