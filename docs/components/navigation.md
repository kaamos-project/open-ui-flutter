# Navigazione: tab, pill tab, barra principale

## Pill tab o tab?

Usa le **pill tab** quando i bottoni **filtrano la stessa lista** ("All", "Most Popular"). Usa **`KaamosTabs`** quando ogni tab mostra un **pannello diverso**. Hanno lo stesso aspetto, ma per uno screen reader sono un interruttore "premuto" e una tab "selezionata".

## Pill tab · `KaamosPillTab`

```dart
for (final f in filters)
  KaamosPillTab(
    label: f.label,
    selected: current == f,
    onPressed: () => setState(() => current = f),
  ),
```

## Tab · `KaamosTabs`

```dart
KaamosTabs(
  semanticLabel: 'Impostazioni account',
  labels: const ['Generale', 'Account', 'Privacy'],
  panels: const [GeneralPanel(), AccountPanel(), PrivacyPanel()],
  onChanged: (i) => print('tab $i'),
)
```

- **Tastiera**: Tab entra nella tab attiva, il Tab successivo va nel pannello. ← → cambiano tab girando in tondo (attivazione immediata), Home e Fine vanno alla prima e all'ultima.
- **Trade-off**: si costruisce solo il pannello visibile, più leggero di un `IndexedStack`. Cambiando tab, però, lo stato del pannello lasciato (scroll, testo non salvato) si perde: se ti serve, tienilo fuori dal pannello.
- Su schermi stretti le tab scorrono in orizzontale.

## Barra principale · `KaamosNavBar`

```dart
KaamosNavBar(
  brand: const Text('Kaamos'),
  items: [
    KaamosNavItem(label: 'Home', onPressed: goHome, current: true),
    KaamosNavItem(label: 'Mail', onPressed: goMail),
  ],
  secondaryActions: [KaamosLink(label: 'Accedi', onPressed: login)],
  actions: [KaamosButton(onPressed: download, child: const Text('Download'))],
)
```

- Alta 56px, bordo `hairline` in basso. Mettila in cima a una `Column` per tenerla sempre visibile.
- **Sotto i 768px** (`kaamosNavBreakpoint`): il logo va al centro, compare il bottone hamburger, i link finiscono in un cassetto che entra da sinistra e le `secondaryActions` spariscono.
- Il cassetto è una route (`showKaamosNavDrawer`): si chiude con il tasto indietro, un clic sul velo o Esc.
- La larghezza si legge con `MediaQuery.sizeOf`: la barra si ricostruisce solo quando cambia la misura della finestra.
