# Button · `KaamosButton`

Bottone d'azione. Equivalente di `<kaamos-button>` in open-ui-web.

```dart
KaamosButton(onPressed: save, child: const Text('Download'))
KaamosButton(
  onPressed: openDocs,
  variant: KaamosButtonVariant.secondary,
  trailing: const Text('→'),
  child: const Text('Learn more'),
)
KaamosButton(onPressed: null, child: const Text('Download')) // disabilitato
```

![Varianti](../test/components/button/goldens/button_variants.png)

## Parametri

| Parametro       | Tipo                  | Default   | Note                                             |
| --------------- | --------------------- | --------- | ------------------------------------------------ |
| `onPressed`     | `VoidCallback?`       | obbligatorio | `null` = disabilitato                         |
| `child`         | `Widget`              | obbligatorio | di solito un `Text`                           |
| `variant`       | `KaamosButtonVariant` | `primary` | `primary`, `secondary`, `tertiary`, `install`    |
| `leading`       | `Widget?`             | `null`    | prima dell'etichetta, 8px di distanza            |
| `trailing`      | `Widget?`             | `null`    | dopo l'etichetta, 8px di distanza                |
| `focusNode`     | `FocusNode?`          | `null`    | per dare il focus da codice                      |
| `autofocus`     | `bool`                | `false`   |                                                  |
| `semanticLabel` | `String?`             | `null`    | per gli screen reader, utile con sole icone      |

Le icone dentro `leading`/`trailing` ricevono colore e misura (16px) da un `IconTheme`.

## Tastiera e accessibilità

- Tab sposta il focus, Invio o Spazio lo attivano.
- L'anello del focus compare solo usando la tastiera.
- Gli screen reader lo annunciano come pulsante, con lo stato abilitato/disabilitato.

## Linee guida (DESIGN.md)

- **Un solo `primary` per schermata**: il bianco è riservato all'azione principale.
- `secondary` per azioni leggere ("Learn more →"), `tertiary` per azioni medie dentro le card, `install` sulle card dello store.
- Altezza 36px (install 32px) su tutte le piattaforme: è già sopra la soglia WCAG AA (24px) per i bersagli touch, quindi una densità sola.
- Come sul web, non c'è uno stato hover: su touch non esisterebbe, e l'aspetto resta identico ovunque.
