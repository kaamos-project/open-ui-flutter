# Fondamenta

## `KaamosApp`

La radice dell'app, al posto di `MaterialApp`. Sotto usa `WidgetsApp` (navigazione, localizzazioni di base, scorciatoie di sistema) e aggiunge:

- il tema (`KaamosTheme`)
- lo stile di testo di default (body-md, colore `body`)
- lo sfondo `canvas`

```dart
runApp(const KaamosApp(title: 'Kaamos Bookmarks', home: HomePage()));
```

| Parametro                    | Default               | Note                                              |
| ---------------------------- | --------------------- | ------------------------------------------------- |
| `home`                       | obbligatorio          | la prima schermata                                |
| `title`                      | `''`                  | titolo della finestra o della scheda del browser  |
| `theme`                      | `KaamosThemeData.dark`| unico tema per ora                                |
| `navigatorKey`               | `null`                |                                                   |
| `debugShowCheckedModeBanner` | `true`                |                                                   |

Le pagine cambiano senza animazione: le transizioni Kaamos arriveranno con un componente dedicato.

## Tema: `KaamosTheme` e `KaamosThemeData`

```dart
final theme = KaamosTheme.of(context);
Text('Titolo', style: KaamosTypography.headingLg.copyWith(color: theme.ink));
```

- `KaamosTheme.of(context)` restituisce il tema più vicino, o `KaamosThemeData.dark` se non c'è (comodo nei test).
- I campi sono **semantici** (`primary`, `onDark`, `focusRing`...), non una copia della palette. Per i colori senza un ruolo usa direttamente `KaamosColors`.
- Per cambiare un valore in una parte dell'app:

```dart
KaamosTheme(
  data: KaamosTheme.of(context).copyWith(primary: KaamosColors.accentBlue),
  child: ...,
)
```

**Perché non `ThemeExtension`?** Vive dentro `ThemeData` di Material, e questa libreria non dipende da Material.

## `KaamosPressable`

Il comportamento comune a tutti i controlli cliccabili: mouse, tocco, Invio/Spazio, focus, semantica per gli screen reader. Non disegna niente: passa al `builder` gli stati attivi (`WidgetState.hovered`, `pressed`, `focused`, `disabled`).

```dart
KaamosPressable(
  onPressed: () {},
  builder: (context, states) => ColoredBox(
    color: states.contains(WidgetState.pressed)
        ? KaamosColors.surfaceCard
        : KaamosColors.surface,
    child: const Text('Voce'),
  ),
)
```

- `onPressed: null` = disabilitato (cursore "vietato", niente focus).
- `focused` compare solo usando la tastiera, come `:focus-visible` sul web.

## `KaamosFocusRing`

L'anello del focus (CSS `outline: 2px` + `outline-offset: 2px`). È disegnato fuori dal widget senza cambiarne la misura, quindi quando compare non sposta il layout.
