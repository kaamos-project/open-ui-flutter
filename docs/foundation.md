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

## Icone: `KaamosIcon`

```dart
const KaamosIcon(KaamosIcons.search)
KaamosIcon(KaamosIcons.close, size: 20, semanticLabel: 'Chiudi')
```

Disponibili: `search`, `check`, `minus`, `chevronDown`, `chevronRight`, `close`, `menu`, `arrowRight`. Colore e misura arrivano da `IconTheme` (dentro un bottone prendono il colore del testo). Senza `semanticLabel` l'icona è decorativa e gli screen reader la saltano.

**Perché disegnate a mano con `CustomPaint`?** Per ora ne servono poche: zero dipendenze e zero parsing a runtime. Quando saranno decine passeremo a un font di icone generato dalla repo dei token.

## Scroll: `KaamosScrollBehavior`

`KaamosApp` la applica a tutta l'app: lo scroll si ferma al bordo su ogni piattaforma (niente rimbalzo iOS, niente bagliore Android) e la barra di scorrimento è sottile, nel colore `hairlineStrong`.

## Overlay ancorati: `KaamosAnchoredOverlay`

La base di popover, menu e select. Usa `OverlayPortal` (il pannello è disegnato sopra tutto ma resta nell'albero di chi lo apre) e `CompositedTransformFollower` (segue l'ancora quando la pagina scorre). Si apre sotto l'ancora, o sopra se sotto non c'è spazio; allineato a sinistra, o a destra se non ci sta. Un clic fuori lo chiude.

L'ancora riceve un `KaamosOverlayHandle` con `show()`, `hide()`, `toggle()` e `isShowing`.

## Liste: `KaamosPopoverSurface` e `KaamosListRow`

La superficie (`surface`, bordo `hairline`, raggio 10px) e la riga (command-palette-row) condivise da menu, select, command palette e dal menu copia/incolla. Usale per costruire liste tue con lo stesso aspetto.
