# Componenti statici

Widget senza comportamento (o quasi): solo aspetto. Equivalgono alle classi statiche di open-ui-web.

## Badge · `KaamosBadge`

```dart
const KaamosBadge('Pro')
const KaamosBadge('Beta', variant: KaamosBadgeVariant.info)
```

| Variante | Uso                                                          |
| -------- | ------------------------------------------------------------ |
| `pro`    | Piano o livello: "Pro", "Pro+", "Free"                       |
| `info`   | Etichetta rara: "New", "Beta". Usa l'accento blu: tienila rara |

## Keycap · `KaamosKeycap`

```dart
const Row(spacing: 4, children: [
  KaamosKeycap('⌘', semanticLabel: 'Command'),
  KaamosKeycap('K'),
])
```

Alto 20px, largo almeno 20px. Dai un `semanticLabel` ai simboli: "⌘" non dice niente a uno screen reader.

## App icon tile · `KaamosAppIconTile`

```dart
KaamosAppIconTile(child: Image.asset('assets/mail.png'))
KaamosAppIconTile(size: KaamosAppIconTileSize.large, child: ...)
```

48×48 (`medium`) o 64×64 (`large`). L'icona riempie il riquadro, tagliata agli angoli.

## Card · `KaamosCard`

```dart
KaamosCard(child: ...)                                     // feature-card-dark, pricing-tier-card
KaamosCard(variant: KaamosCardVariant.elevated, child: ...) // feature-card-elevated, piano in evidenza
KaamosCard(variant: KaamosCardVariant.compact, child: Row(...)) // store-extension-card
```

Una sola cornice, cambia il contenuto. Niente ombre: la profondità viene dalla scala delle superfici e dal bordo `hairline`.

## Link · `KaamosLink`

```dart
KaamosLink(label: 'Leggi la documentazione', onPressed: openDocs)
```

Testo `onDark` in link-md, sottolineato al passaggio del mouse. Per gli screen reader è un "link". Flutter non conosce gli URL: cosa succede al clic lo decide `onPressed` (una pagina della tua app, o il browser con un pacchetto come `url_launcher`).
