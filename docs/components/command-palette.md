# Command palette · `showKaamosCommandPalette`

La "palette dei comandi": si apre con ⌘K (Ctrl+K su Linux e Windows), scrivi per filtrare, ti muovi con le frecce e scegli con Invio. È il componente simbolo del DESIGN.md.

```dart
const commands = [
  KaamosCommand(value: 'new', label: 'Nuova email', trailing: KaamosKeycap('⌘ N'), keywords: ['scrivi']),
  KaamosCommand(value: 'search', label: 'Cerca nella posta'),
  KaamosCommand(value: 'settings', label: 'Impostazioni'),
];

// Con la scorciatoia ⌘K / Ctrl+K:
KaamosCommandPaletteShortcut<String>(
  commands: commands,
  onSelected: run,
  child: const HomePage(),
)

// Oppure da codice:
final cmd = await showKaamosCommandPalette<String>(context: context, commands: commands);
```

## Comandi · `KaamosCommand`

| Campo      | Note                                                  |
| ---------- | ----------------------------------------------------- |
| `value`    | Quello che ricevi quando il comando viene scelto      |
| `label`    | Il testo della riga, ed è quello in cui si cerca      |
| `leading`  | Icona a sinistra                                      |
| `trailing` | Di solito i keycap della scorciatoia                  |
| `keywords` | Altre parole che trovano il comando                   |

## Filtro

Di default (`kaamosContainsFilter`) un comando è trovato se il testo o una keyword **contiene** la ricerca, senza distinguere maiuscole e minuscole. Puoi passare il tuo:

```dart
showKaamosCommandPalette<String>(
  context: context,
  commands: commands,
  filter: (command, query) => command.label.toLowerCase().startsWith(query),
);
```

`query` arriva già in minuscolo, senza spazi ai bordi, e non è mai vuota.

## Accessibilità e performance

- Il focus resta sempre nel campo di ricerca (pattern ARIA combobox): puoi continuare a scrivere mentre ti muovi con ↑ ↓.
- È una route modale: Esc, il tasto indietro o un clic fuori la chiudono e restituiscono `null`.
- La lista usa `ListView.builder` con righe ad altezza fissa: costruisce solo le righe visibili, quindi resta veloce anche con migliaia di comandi.
