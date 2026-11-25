import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/anchored_overlay.dart';
import '../../foundation/icons.dart';
import '../../foundation/menu_surface.dart';
import '../../foundation/theme.dart';

/// Un'opzione di [KaamosSelect].
class KaamosSelectOption<T> {
  /// Crea un'opzione.
  const KaamosSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.group,
  });

  /// Il valore che riceverai in `onChanged`.
  final T value;

  /// Il testo mostrato.
  final String label;

  /// Le opzioni disabilitate si vedono ma non si possono scegliere.
  final bool enabled;

  /// Titolo del gruppo (come `<optgroup>`). Opzioni consecutive con lo
  /// stesso gruppo stanno sotto un solo titolo.
  final String? group;
}

/// Menu di scelta con la lista disegnata da noi (kaamos-select): identica
/// su ogni piattaforma, niente "ruota" di iOS o lista di Android.
///
/// ```dart
/// KaamosSelect<String>(
///   value: lingua,
///   placeholder: 'Scegli una lingua',
///   semanticLabel: 'Lingua',
///   options: const [
///     KaamosSelectOption(value: 'fi', label: 'Suomi', group: 'Paesi nordici'),
///     KaamosSelectOption(value: 'sv', label: 'Svenska', group: 'Paesi nordici'),
///     KaamosSelectOption(value: 'it', label: 'Italiano'),
///   ],
///   onChanged: (v) => setState(() => lingua = v),
/// )
/// ```
///
/// Il focus resta sempre sul campo (pattern ARIA "select-only combobox"):
/// l'opzione attiva nella lista è solo evidenziata.
///
/// | Tasto            | Lista chiusa               | Lista aperta                         |
/// | ---------------- | -------------------------- | ------------------------------------ |
/// | ↓ ↑ Invio Spazio | apre                       | ↓ ↑ si muovono, Invio/Spazio scelgono |
/// | Home / Fine      | apre sulla prima / ultima  | prima / ultima opzione               |
/// | PagSu / PagGiù   |                            | salta di 10                          |
/// | Esc              |                            | chiude senza cambiare                |
/// | Tab              |                            | sceglie l'attiva e prosegue          |
/// | Lettere          | cambia subito valore       | sposta l'opzione attiva              |
class KaamosSelect<T> extends StatefulWidget {
  /// Crea una select. Se [onChanged] è null è disabilitata.
  const KaamosSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.semanticLabel,
    this.invalid = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Le opzioni, in ordine.
  final List<KaamosSelectOption<T>> options;

  /// Il valore scelto, o null se non c'è ancora una scelta.
  final T? value;

  /// Chiamata quando l'utente sceglie un'opzione. `null` = disabilitata.
  final ValueChanged<T>? onChanged;

  /// Testo grigio quando [value] è null.
  final String? placeholder;

  /// Etichetta per gli screen reader.
  final String? semanticLabel;

  /// Bordo rosso: il valore non è valido.
  final bool invalid;

  /// Per dare il focus da codice.
  final FocusNode? focusNode;

  /// Prende il focus appena compare.
  final bool autofocus;

  @override
  State<KaamosSelect<T>> createState() => _KaamosSelectState<T>();
}

class _KaamosSelectState<T> extends State<KaamosSelect<T>> {
  final OverlayPortalController _overlay = OverlayPortalController();
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  // Una chiave per riga, per far scorrere la lista fino all'opzione attiva.
  List<GlobalKey> _rowKeys = [];
  int _active = -1;
  bool _focusVisible = false;

  // Ricerca digitando.
  String _typed = '';
  Timer? _typeTimer;

  bool get _enabled => widget.onChanged != null;
  List<KaamosSelectOption<T>> get _options => widget.options;
  int get _selectedIndex => _options.indexWhere((o) => o.value == widget.value);

  @override
  void initState() {
    super.initState();
    // Come :focus-visible: il bordo si schiarisce solo se il focus arriva
    // dalla tastiera, non da un clic.
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
  }

  void _onHighlightMode(FocusHighlightMode _) => _updateFocusVisible();

  void _updateFocusVisible() {
    final visible = _focus.hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (visible != _focusVisible) setState(() => _focusVisible = visible);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    _typeTimer?.cancel();
    _ownFocus?.dispose();
    super.dispose();
  }

  // ---- apertura e chiusura ----

  void _open({int? active}) {
    if (!_enabled || _overlay.isShowing) return;
    _focus.requestFocus();
    setState(() {
      _active = active ?? _firstEnabledFrom(_selectedIndex, 1, wrap: false);
      if (_active < 0) _active = _firstEnabledFrom(0, 1, wrap: false);
    });
    _overlay.show();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealActive());
  }

  void _close() {
    if (_overlay.isShowing) setState(_overlay.hide);
  }

  void _choose(int index) {
    final option = _options[index];
    if (!option.enabled) return;
    _close();
    if (option.value != widget.value) widget.onChanged?.call(option.value);
  }

  // ---- movimento nella lista ----

  /// Prima opzione abilitata partendo da [start] nella direzione [dir].
  int _firstEnabledFrom(int start, int dir, {required bool wrap}) {
    final n = _options.length;
    if (n == 0 || start < 0) return -1;
    for (var step = 0; step < n; step++) {
      var i = start + step * dir;
      if (wrap) {
        i %= n;
      } else if (i < 0 || i >= n) {
        break;
      }
      if (_options[i].enabled) return i;
    }
    return -1;
  }

  void _setActive(int index) {
    if (index < 0 || index == _active) return;
    setState(() => _active = index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealActive());
  }

  void _moveBy(int delta) {
    final n = _options.length;
    final target = (_active + delta).clamp(0, n - 1);
    final dir = delta >= 0 ? 1 : -1;
    var i = _firstEnabledFrom(target, dir, wrap: false);
    if (i < 0) i = _firstEnabledFrom(target, -dir, wrap: false);
    _setActive(i);
  }

  void _revealActive() {
    if (_active < 0 || _active >= _rowKeys.length) return;
    final ctx = _rowKeys[_active].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
      Scrollable.ensureVisible(ctx,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    }
  }

  // ---- ricerca digitando ----
  //
  // Lettere diverse cercano l'inizio del testo ("sv" → Svenska); la stessa
  // lettera ripetuta scorre le opzioni che iniziano con lei ("s", "s" →
  // Svenska, poi Suomi). Dopo mezzo secondo di pausa si ricomincia.
  int _typeahead(String char) {
    _typeTimer?.cancel();
    _typeTimer = Timer(const Duration(milliseconds: 500), () => _typed = '');
    _typed += char.toLowerCase();

    final repeated = _typed.split('').every((c) => c == _typed[0]);
    final query = repeated ? _typed[0] : _typed;
    final from = _overlay.isShowing ? _active : _selectedIndex;
    // Con la lettera ripetuta si parte dall'opzione dopo quella attuale.
    final start = repeated || from < 0 ? from + 1 : from;
    final n = _options.length;
    for (var step = 0; step < n; step++) {
      final i = (start + step) % n;
      final o = _options[i];
      if (o.enabled && o.label.toLowerCase().startsWith(query)) return i;
    }
    return -1;
  }

  // ---- tastiera ----

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final open = _overlay.isShowing;
    final last = _options.length - 1;

    if (!open) {
      if (key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space) {
        _open();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.home) {
        _open(active: _firstEnabledFrom(0, 1, wrap: false));
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.end) {
        _open(active: _firstEnabledFrom(last, -1, wrap: false));
        return KeyEventResult.handled;
      }
    } else {
      var handled = true;
      switch (key) {
        case LogicalKeyboardKey.arrowDown:
          _moveBy(1);
        case LogicalKeyboardKey.arrowUp:
          _moveBy(-1);
        case LogicalKeyboardKey.pageDown:
          _moveBy(10);
        case LogicalKeyboardKey.pageUp:
          _moveBy(-10);
        case LogicalKeyboardKey.home:
          _setActive(_firstEnabledFrom(0, 1, wrap: false));
        case LogicalKeyboardKey.end:
          _setActive(_firstEnabledFrom(last, -1, wrap: false));
        case LogicalKeyboardKey.enter || LogicalKeyboardKey.space:
          if (_active >= 0) _choose(_active);
        case LogicalKeyboardKey.escape:
          _close();
        case LogicalKeyboardKey.tab:
          // Sceglie l'attiva e lascia che Tab sposti il focus.
          if (_active >= 0) _choose(_active);
          return KeyEventResult.ignored;
        default:
          handled = false;
      }
      if (handled) return KeyEventResult.handled;
    }

    // Una lettera (niente Ctrl/Cmd: quelle sono scorciatoie).
    final char = event.character;
    final keyboard = HardwareKeyboard.instance;
    if (char != null &&
        char.trim().isNotEmpty &&
        !keyboard.isControlPressed &&
        !keyboard.isMetaPressed) {
      final i = _typeahead(char);
      if (i >= 0) {
        if (open) {
          _setActive(i);
        } else if (_options[i].value != widget.value) {
          widget.onChanged?.call(_options[i].value);
        }
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ---- disegno ----

  Widget _buildList(BuildContext context) {
    final theme = KaamosTheme.of(context);
    _rowKeys = List.generate(_options.length, (_) => GlobalKey());
    final children = <Widget>[];
    String? group;
    for (var i = 0; i < _options.length; i++) {
      final o = _options[i];
      if (o.group != null && o.group != group) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              o.group!,
              style: KaamosTypography.captionSm.copyWith(color: theme.mute),
            ),
          ),
        );
      }
      group = o.group;
      final selected = o.value == widget.value;
      children.add(
        KaamosListRow(
          key: _rowKeys[i],
          // Il focus resta sul campo: le righe non lo prendono mai.
          canRequestFocus: false,
          highlighted: i == _active,
          selected: selected,
          onPressed: o.enabled ? () => _choose(i) : null,
          trailing: Visibility.maintain(
            visible: selected,
            child: KaamosIcon(KaamosIcons.check, color: theme.mute),
          ),
          child: Text(o.label),
        ),
      );
    }
    // IntrinsicWidth: larga quanto l'opzione più lunga (ma almeno quanto il
    // campo), invece di tutto lo spazio disponibile.
    return IntrinsicWidth(
      child: KaamosPopoverSurface(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final selected = _selectedIndex;
    final open = _overlay.isShowing;
    final label = selected >= 0 ? _options[selected].label : null;

    final Color border;
    if (widget.invalid) {
      border = theme.danger;
    } else if (open || _focusVisible) {
      border = theme.hairlineStrong;
    } else {
      border = theme.hairline;
    }

    final trigger = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceElevated,
        border: Border.all(color: border),
        borderRadius: const BorderRadius.all(Radius.circular(KaamosRadius.md)),
      ),
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  label ?? widget.placeholder ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KaamosTypography.bodyMd.copyWith(
                    color: !_enabled
                        ? theme.disabledForeground
                        : label == null
                            ? theme.mute
                            : theme.onDark,
                  ),
                ),
              ),
              KaamosIcon(KaamosIcons.chevronDown, color: theme.mute),
            ],
          ),
        ),
      ),
    );

    return KaamosAnchoredOverlay(
      controller: _overlay,
      matchAnchorWidth: true,
      onDismiss: _close,
      overlayBuilder: _buildList,
      child: Semantics(
        button: true,
        expanded: open,
        enabled: _enabled,
        label: widget.semanticLabel,
        value: label,
        onTap: _enabled ? (open ? _close : _open) : null,
        // Un Focus "vero" (non FocusableActionDetector) perché i tasti
        // arrivano al nodo con il focus: è lui che deve gestirli.
        child: Focus(
          focusNode: _focus,
          autofocus: widget.autofocus,
          canRequestFocus: _enabled,
          onKeyEvent: _onKey,
          onFocusChange: (_) => _updateFocusVisible(),
          child: MouseRegion(
            cursor: _enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _enabled ? (open ? _close : _open) : null,
              child: trigger,
            ),
          ),
        ),
      ),
    );
  }
}
