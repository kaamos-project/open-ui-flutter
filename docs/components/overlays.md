# Overlay: popover, menu, dialog

| Componente | Quando usarlo                                                  | Come è fatto                     |
| ---------- | -------------------------------------------------------------- | -------------------------------- |
| Popover    | Informazioni o contenuto leggero vicino a un bottone           | `OverlayPortal` ancorato         |
| Menu       | Lista di azioni che si apre da un bottone                      | `OverlayPortal` ancorato         |
| Dialog     | Serve una risposta prima di continuare ("Eliminare il file?")  | Route del Navigator              |

**Perché due tecniche?** Il dialog deve bloccare la pagina: una route ci dà gratis il tasto indietro di Android, la barriera che ferma i clic e il focus intrappolato dentro. Popover e menu invece sono leggeri: restano nell'albero di chi li apre (stesso tema, e spariscono se il bottone sparisce) e seguono il bottone quando la pagina scorre.

## Popover · `KaamosPopover`

```dart
KaamosPopover(
  content: const Text('Testo di aiuto vicino al bottone.'),
  builder: (context, overlay) => KaamosButton(
    variant: KaamosButtonVariant.tertiary,
    onPressed: overlay.toggle,
    child: const Text('Info'),
  ),
)
```

Si chiude con il bottone, cliccando fuori o con Esc. Largo al massimo 320px, padding 16px.

## Menu · `KaamosMenu`

```dart
KaamosMenu(
  semanticLabel: 'Azioni sul file',
  items: [
    KaamosMenuItem(label: 'Rinomina', onPressed: rename),
    KaamosMenuItem(label: 'Duplica', onPressed: duplicate, trailing: const KaamosKeycap('⌘ D')),
    const KaamosMenuItem(label: 'Sposta', onPressed: null), // disabilitata
    const KaamosMenuDivider(),
    KaamosMenuItem(label: 'Elimina', onPressed: delete),
  ],
  builder: (context, overlay) => KaamosButton(
    variant: KaamosButtonVariant.tertiary,
    onPressed: overlay.toggle,
    child: const Text('Azioni'),
  ),
)
```

- **Tastiera**: all'apertura il focus va sulla prima voce. ↑ ↓ si muovono girando in tondo e saltando le disabilitate, Home e Fine vanno a inizio e fine, Invio sceglie, Esc chiude e riporta il focus al bottone, Tab chiude e prosegue.
- Scegliendo una voce il menu si chiude e poi chiama `onPressed`.

## Dialog · `showKaamosDialog` + `KaamosDialog`

```dart
final ok = await showKaamosDialog<bool>(
  context: context,
  builder: (context) => KaamosDialog(
    title: 'Eliminare il file?',
    content: const Text('Potrai recuperarlo dal cestino per 30 giorni.'),
    actions: [
      KaamosButton(
        variant: KaamosButtonVariant.secondary,
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Annulla'),
      ),
      KaamosButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Elimina'),
      ),
    ],
  ),
);
if (ok ?? false) deleteFile();
```

- `await` restituisce quello che passi a `Navigator.pop`, come `dialog.returnValue` sul web. Esc, il tasto indietro o un clic sul velo restituiscono `null` (`barrierDismissible: false` per impedirlo).
- Il titolo è anche il nome del dialog per gli screen reader.
- **Un solo bottone primary**: l'azione principale.
- Largo al massimo 448px, 16px dai bordi dello schermo. Il velo è `canvas` al 70%.
