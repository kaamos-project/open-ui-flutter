# Controlli dei form

## Text field · `KaamosTextField`

```dart
final email = TextEditingController();

KaamosTextField(
  controller: email,
  placeholder: 'tu@esempio.org',
  semanticLabel: 'Email',
  keyboardType: TextInputType.emailAddress,
  autofillHints: const [AutofillHints.email],
  invalid: !isValidEmail(email.text),
)
```

| Parametro                         | Note                                                    |
| --------------------------------- | ------------------------------------------------------- |
| `controller`                      | Il testo. Se manca il campo ne crea uno suo             |
| `focusNode`                       | Per dare o togliere il focus da codice                  |
| `placeholder`                     | Sparisce quando scrivi: **non** è un'etichetta          |
| `semanticLabel`                   | Etichetta per gli screen reader                         |
| `enabled`, `readOnly`             | Disabilitato (grigio, niente focus) o solo lettura      |
| `obscureText`                     | Password                                                |
| `invalid`                         | Bordo rosso                                             |
| `keyboardType`, `textInputAction` | Tastiera e tasto azione su mobile                       |
| `onChanged`, `onSubmitted`        | A ogni modifica, e quando premi Invio                   |
| `maxLength`, `inputFormatters`    | Filtri sul testo                                        |
| `autofillHints`                   | Autofill del sistema                                    |

Alto 36px, sfondo `surfaceElevated`, bordo `hairline` che al focus diventa `hairlineStrong`.

**Come è fatto**: sotto c'è `EditableText`, il motore di testo di Flutter (cursore, tastiera di sistema, emoji, scorciatoie, accessibilità). I gesti (tap, doppio tap, trascinare per selezionare) arrivano da `TextSelectionGestureDetectorBuilder`. Le maniglie di selezione su touch e il menu Taglia/Copia/Incolla sono disegnati da noi, nello stile dei menu Kaamos. Le etichette del menu vengono da `WidgetsLocalizations`: aggiungi `flutter_localizations` alla tua app per averle tradotte.

**Eccezione sul web**: resta il menu del browser (tasto destro), perché il nostro "Incolla" dovrebbe chiedere il permesso di leggere gli appunti.

## Search bar · `KaamosSearchBar`

```dart
KaamosSearchBar(
  placeholder: 'Search...',
  semanticLabel: 'Cerca estensioni',
  onChanged: filterList,
  onSubmitted: search,
  trailing: const KaamosKeycap('/'),
)
```

Lente a sinistra, alta 44px, bordo trasparente che al focus diventa `hairlineStrong`. Esc svuota il campo, su mobile la tastiera mostra "Cerca". Dai sempre un `semanticLabel`.

## Checkbox · `KaamosCheckbox`

```dart
KaamosCheckbox(
  value: newsletter,
  onChanged: (v) => setState(() => newsletter = v!),
  label: const Text('Iscrivimi alla newsletter'),
)
```

- `onChanged: null` = disabilitata.
- `tristate: true` permette `value: null` ("in parte"). Il giro è false → true → null → false.
- La casella è 16×16, troppo piccola per un dito: passa una `label`, che diventa cliccabile anche lei.

## Slider · `KaamosSlider`

```dart
KaamosSlider(
  value: volume,
  onChanged: (v) => setState(() => volume = v),
  min: 0,
  max: 1,
  divisions: 10,          // facoltativo: salta a passi
  semanticLabel: 'Volume',
)
```

Tastiera: ← → ↑ ↓ un passo (una divisione, o l'1%), PagSu/PagGiù dieci passi, Home/Fine minimo e massimo. Gli screen reader possono aumentare e diminuire il valore.

## Select · `KaamosSelect`

```dart
KaamosSelect<String>(
  value: lingua,
  placeholder: 'Scegli una lingua',
  semanticLabel: 'Lingua',
  onChanged: (v) => setState(() => lingua = v),
  options: const [
    KaamosSelectOption(value: 'fi', label: 'Suomi', group: 'Paesi nordici'),
    KaamosSelectOption(value: 'sv', label: 'Svenska', group: 'Paesi nordici'),
    KaamosSelectOption(value: 'is', label: 'Íslenska', enabled: false),
    KaamosSelectOption(value: 'it', label: 'Italiano'),
  ],
)
```

La lista è disegnata da noi: identica ovunque, niente "ruota" di iOS. Si apre sotto il campo (sopra se manca spazio), larga almeno quanto il campo, alta al massimo 288px. Opzioni consecutive con lo stesso `group` stanno sotto un titolo, come `<optgroup>`.

**Tastiera** (il focus resta sempre sul campo):

| Tasto            | Lista chiusa              | Lista aperta                                     |
| ---------------- | ------------------------- | ------------------------------------------------ |
| ↓ ↑ Invio Spazio | apre                      | ↓ ↑ si muovono (saltando le disabilitate), Invio e Spazio scelgono |
| Home / Fine      | apre sulla prima / ultima | prima / ultima opzione                           |
| PagSu / PagGiù   |                           | salta di 10                                      |
| Esc              |                           | chiude senza cambiare                            |
| Tab              |                           | sceglie l'opzione attiva e prosegue              |
| Lettere          | cambia subito valore      | sposta l'opzione attiva                          |

Ricerca digitando: lettere diverse cercano l'inizio del testo ("sv" → Svenska), la stessa lettera ripetuta scorre le opzioni che iniziano con lei. Dopo mezzo secondo di pausa si ricomincia.
