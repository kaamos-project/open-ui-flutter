import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/icons.dart';
import '../../foundation/menu_surface.dart';
import '../../foundation/theme.dart';
import '../text_field/editable.dart';

/// Un comando della palette.
class KaamosCommand<T> {
  /// Crea un comando.
  const KaamosCommand({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.keywords = const [],
  });

  /// Quello che riceverai quando il comando viene scelto.
  final T value;

  /// Il testo della riga: è anche quello in cui si cerca.
  final String label;

  /// Icona a sinistra (un'icona o un `KaamosAppIconTile` piccolo).
  final Widget? leading;

  /// A destra: di solito i keycap della scorciatoia.
  final Widget? trailing;

  /// Altre parole che devono trovare il comando ("posta" per "Nuova email").
  final List<String> keywords;
}

/// Decide se un comando corrisponde a quello che hai scritto.
///
/// [query] arriva già in minuscolo e senza spazi ai bordi, e non è mai vuota.
typedef KaamosCommandFilter<T> = bool Function(
  KaamosCommand<T> command,
  String query,
);

/// Il filtro di default: il testo (o una keyword) *contiene* la ricerca,
/// senza distinguere maiuscole e minuscole. Come la versione web.
///
/// Costo: O(n · m) nel caso peggiore, con n comandi lunghi m caratteri.
/// Vuoi una ricerca "fuzzy" ("nwml" → "Nuova email")? Passa il tuo filtro
/// a [showKaamosCommandPalette]: è un ottimo esercizio di algoritmi.
bool kaamosContainsFilter<T>(KaamosCommand<T> command, String query) {
  if (command.label.toLowerCase().contains(query)) return true;
  for (final k in command.keywords) {
    if (k.toLowerCase().contains(query)) return true;
  }
  return false;
}

/// Apre la palette dei comandi e restituisce il valore scelto, o null se
/// l'utente chiude con Esc o cliccando fuori.
///
/// ```dart
/// final cmd = await showKaamosCommandPalette<String>(
///   context: context,
///   commands: const [
///     KaamosCommand(value: 'new', label: 'Nuova email', trailing: KaamosKeycap('⌘ N')),
///     KaamosCommand(value: 'search', label: 'Cerca nella posta'),
///     KaamosCommand(value: 'settings', label: 'Impostazioni'),
///   ],
/// );
/// ```
///
/// Il focus resta sempre nel campo di ricerca (pattern ARIA combobox): puoi
/// continuare a scrivere mentre ti muovi con ↑ ↓, e Invio sceglie la riga
/// evidenziata. Per aprirla con ⌘K / Ctrl+K usa
/// [KaamosCommandPaletteShortcut].
Future<T?> showKaamosCommandPalette<T>({
  required BuildContext context,
  required List<KaamosCommand<T>> commands,
  String placeholder = 'Search commands...',
  String semanticLabel = 'Commands',
  String emptyLabel = 'No results',
  KaamosCommandFilter<T>? filter,
}) {
  final theme = KaamosTheme.of(context);
  return Navigator.of(context).push<T>(
    RawDialogRoute<T>(
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: theme.scrim,
      transitionDuration: KaamosDuration.normal,
      pageBuilder: (context, animation, secondaryAnimation) => KaamosTheme(
        data: theme,
        child: _CommandPalette<T>(
          commands: commands,
          placeholder: placeholder,
          semanticLabel: semanticLabel,
          emptyLabel: emptyLabel,
          filter: filter ?? kaamosContainsFilter<T>,
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: KaamosEasing.out),
        child: child,
      ),
    ),
  );
}

class _CommandPalette<T> extends StatefulWidget {
  const _CommandPalette({
    required this.commands,
    required this.placeholder,
    required this.semanticLabel,
    required this.emptyLabel,
    required this.filter,
  });

  final List<KaamosCommand<T>> commands;
  final String placeholder;
  final String semanticLabel;
  final String emptyLabel;
  final KaamosCommandFilter<T> filter;

  @override
  State<_CommandPalette<T>> createState() => _CommandPaletteState<T>();
}

class _CommandPaletteState<T> extends State<_CommandPalette<T>> {
  // Altezza fissa delle righe: con itemExtent ListView non deve misurare
  // ogni riga, e sappiamo subito dove si trova la riga N per lo scroll.
  static const double _rowHeight = 38;
  static const double _maxListHeight = 320;

  final TextEditingController _query = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late List<KaamosCommand<T>> _visible = widget.commands;
  int _active = 0;

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onQueryChanged(String text) {
    final q = text.trim().toLowerCase();
    setState(() {
      _visible = q.isEmpty
          ? widget.commands
          : [
              for (final c in widget.commands)
                if (widget.filter(c, q)) c,
            ];
      _active = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _move(int delta) {
    if (_visible.isEmpty) return;
    setState(() => _active = (_active + delta) % _visible.length);
    _reveal();
  }

  // Scorre il minimo indispensabile per vedere la riga attiva.
  void _reveal() {
    if (!_scroll.hasClients) return;
    final top = _active * _rowHeight;
    final bottom = top + _rowHeight;
    final view = _scroll.position.viewportDimension;
    final offset = _scroll.offset;
    if (top < offset) {
      _scroll.jumpTo(top);
    } else if (bottom > offset + view) {
      _scroll.jumpTo(bottom - view);
    }
  }

  void _choose([int? index]) {
    final i = index ?? _active;
    if (i < 0 || i >= _visible.length) return;
    Navigator.of(context).pop(_visible[i].value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final screen = MediaQuery.sizeOf(context);

    final field = KaamosEditable(
      controller: _query,
      autofocus: true,
      placeholder: widget.placeholder,
      semanticLabel: widget.semanticLabel,
      textInputAction: TextInputAction.go,
      onChanged: _onQueryChanged,
      onSubmitted: (_) => _choose(),
      frameBuilder: (context, field, focused) => SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 12,
            children: [
              KaamosIcon(KaamosIcons.search, color: theme.mute),
              Expanded(child: field),
            ],
          ),
        ),
      ),
    );

    final list = _visible.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.emptyLabel,
              style: KaamosTypography.bodySm.copyWith(color: theme.mute),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.min(
                _maxListHeight,
                _visible.length * _rowHeight + 8,
              ),
            ),
            // ListView.builder costruisce solo le righe visibili: con
            // migliaia di comandi (o di bookmark) resta veloce.
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(4),
              itemExtent: _rowHeight,
              itemCount: _visible.length,
              itemBuilder: (context, i) {
                final c = _visible[i];
                return KaamosListRow(
                  canRequestFocus: false,
                  highlighted: i == _active,
                  selected: i == _active,
                  onPressed: () => _choose(i),
                  leading: c.leading,
                  trailing: c.trailing,
                  child: Text(c.label),
                );
              },
            ),
          );

    return Align(
      // mt-[15vh]: in alto, non al centro, così la lista ha spazio sotto.
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, screen.height * 0.15, 16, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 576),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _move(-1),
            },
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: widget.semanticLabel,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surface,
                  border: Border.all(color: theme.hairline),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(KaamosRadius.xl),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(KaamosRadius.xl),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      field,
                      SizedBox(
                        height: 1,
                        child: ColoredBox(color: theme.hairline),
                      ),
                      list,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Apre la command palette con ⌘K (macOS, iOS) o Ctrl+K (altrove), ovunque
/// sia il focus dentro [child]. Mettila in alto nell'albero, per esempio
/// attorno alla home della tua app.
///
/// ```dart
/// KaamosCommandPaletteShortcut<String>(
///   commands: commands,
///   onSelected: run,
///   child: const HomePage(),
/// )
/// ```
class KaamosCommandPaletteShortcut<T> extends StatefulWidget {
  /// Collega la scorciatoia alla palette.
  const KaamosCommandPaletteShortcut({
    super.key,
    required this.commands,
    required this.onSelected,
    required this.child,
    this.shortcutKey = LogicalKeyboardKey.keyK,
    this.placeholder = 'Search commands...',
    this.filter,
  });

  /// I comandi della palette.
  final List<KaamosCommand<T>> commands;

  /// Chiamata con il valore del comando scelto.
  final ValueChanged<T> onSelected;

  /// La parte dell'app in cui vale la scorciatoia.
  final Widget child;

  /// La lettera da premere con ⌘ o Ctrl. Default K.
  final LogicalKeyboardKey shortcutKey;

  /// Testo nel campo di ricerca.
  final String placeholder;

  /// Filtro personalizzato (vedi [kaamosContainsFilter]).
  final KaamosCommandFilter<T>? filter;

  @override
  State<KaamosCommandPaletteShortcut<T>> createState() =>
      _KaamosCommandPaletteShortcutState<T>();
}

class _KaamosCommandPaletteShortcutState<T>
    extends State<KaamosCommandPaletteShortcut<T>> {
  bool _open = false;

  Future<void> _show() async {
    // Già aperta: niente seconda palette sopra la prima. (Dentro la palette
    // il focus è nella sua route, quindi Esc la chiude.)
    if (_open) return;
    _open = true;
    final value = await showKaamosCommandPalette<T>(
      context: context,
      commands: widget.commands,
      placeholder: widget.placeholder,
      filter: widget.filter,
    );
    _open = false;
    if (value != null) widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    // Due scorciatoie: Ctrl e Meta (⌘). Su macOS l'utente si aspetta ⌘,
    // su Linux e Windows Ctrl; registrarle entrambe è più semplice che
    // indovinare la piattaforma (e sul web non la sappiamo con certezza).
    return CallbackShortcuts(
      bindings: {
        SingleActivator(widget.shortcutKey, control: true): _show,
        SingleActivator(widget.shortcutKey, meta: true): _show,
      },
      // Focus: senza un nodo col focus qui sotto, i tasti non arriverebbero.
      child: Focus(autofocus: true, child: widget.child),
    );
  }
}
