# open-ui-flutter

Il design system **Kaamos** per Flutter: pacchetto Dart `kaamos_ui`.
È la versione Flutter di [open-ui-web](https://github.com/kaamos-project/open-ui-web) e usa gli stessi token di [open-design-tokens](https://github.com/kaamos-project/open-design-tokens).

- **Niente Material, niente Cupertino**: solo `package:flutter/widgets.dart`. Ogni controllo è disegnato da noi, quindi ha lo stesso aspetto su Linux, macOS, Windows, web, Android e iOS. Un test (`test/architecture_test.dart`) blocca gli import vietati.
- **Token versionati**: colori, misure, tipografia e il font Inter arrivano dal pacchetto `kaamos_design_tokens`, fissato a un tag.
- **Performance prima di tutto**: costruttori `const`, niente `Opacity` o `BackdropFilter` costosi, ricostruzioni solo quando cambia il tema.

## Installazione

Non è su pub.dev: si usa come dipendenza git, fissata a un tag.

```yaml
dependencies:
  kaamos_ui:
    git:
      url: https://github.com/kaamos-project/open-ui-flutter
      ref: v0.1.0
```

```dart
import 'package:flutter/widgets.dart';
import 'package:kaamos_ui/kaamos_ui.dart';

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

`kaamos_ui` riesporta i token: `KaamosColors`, `KaamosTypography`, `KaamosSpacing`... sono già disponibili.

## Documentazione

- [Fondamenta](docs/foundation.md): `KaamosApp`, tema, `KaamosPressable`, anello del focus
- [Button](docs/components/button.md)

## Sviluppo

```sh
flutter pub get
flutter analyze
flutter test                      # widget test + golden test
flutter test --update-goldens     # rigenera gli screenshot di riferimento

cd example && flutter run -d linux   # la gallery (anche: macos, windows, chrome)
```

I golden test confrontano screenshot pixel per pixel. Il rendering del testo cambia tra sistemi operativi, quindi i file in `test/**/goldens/` sono generati **su Linux** con la versione di Flutter indicata in `.github/workflows/ci.yml`. Se li rigeneri su macOS o Windows la CI fallirà.

## Struttura

```
lib/
  kaamos_ui.dart            API pubblica (solo export)
  src/foundation/           tema, app, pressable, focus ring
  src/components/<nome>/    un componente per cartella
test/                       stessa struttura di lib/
example/                    gallery app
docs/                       documentazione d'uso
```

## Licenza

GPL-3.0, vedi [LICENSE](LICENSE). Il font Inter è sotto SIL OFL 1.1 (incluso nel pacchetto dei token).
