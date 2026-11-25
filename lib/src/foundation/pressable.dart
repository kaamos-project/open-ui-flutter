import 'package:flutter/widgets.dart';

/// Costruisce l'aspetto di un controllo a partire dai suoi stati
/// (hover, premuto, focus, disabilitato).
typedef KaamosStateWidgetBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> states,
);

/// Il "cervello" condiviso da tutti i controlli cliccabili Kaamos.
///
/// Non disegna niente: gestisce mouse, tocco, tastiera, focus e semantica,
/// e passa al [builder] l'insieme degli stati attivi. Così ogni componente
/// (bottone, tab, voce di menu...) si occupa solo del suo aspetto.
///
/// Dentro c'è [FocusableActionDetector], che in un widget solo mette insieme
/// focus, scorciatoie da tastiera, azioni e hover del mouse.
///
/// Il focus ([WidgetState.focused]) viene segnalato solo quando l'utente usa
/// la tastiera, come `:focus-visible` sul web: chi clicca col mouse non vede
/// l'anello.
class KaamosPressable extends StatefulWidget {
  /// Crea un controllo cliccabile. Se [onPressed] è `null` è disabilitato.
  const KaamosPressable({
    super.key,
    required this.onPressed,
    required this.builder,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.isButton = true,
    this.isLink = false,
    this.canRequestFocus = true,
  });

  /// Chiamato al clic, al tocco, o con Invio/Spazio quando ha il focus.
  /// `null` = disabilitato (convenzione di Flutter).
  final VoidCallback? onPressed;

  /// Disegna il controllo a partire dagli stati.
  final KaamosStateWidgetBuilder builder;

  /// Per controllare il focus da fuori (es. `focusNode.requestFocus()`).
  final FocusNode? focusNode;

  /// Prende il focus appena compare.
  final bool autofocus;

  /// Testo letto dagli screen reader al posto del contenuto visibile.
  final String? semanticLabel;

  /// Annunciato come "pulsante" agli screen reader.
  final bool isButton;

  /// Annunciato come "link" agli screen reader.
  final bool isLink;

  /// `false` per controlli che non devono mai prendere il focus (es. le
  /// righe di una lista dove il focus resta sul campo di ricerca).
  final bool canRequestFocus;

  @override
  State<KaamosPressable> createState() => _KaamosPressableState();
}

class _KaamosPressableState extends State<KaamosPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusVisible = false;

  bool get _enabled => widget.onPressed != null;

  // Invio e Spazio arrivano come intent dalle scorciatoie di WidgetsApp:
  // ActivateIntent ovunque, ButtonActivateIntent per Invio sul web.
  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _activate),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: _activate,
    ),
  };

  Object? _activate(Intent intent) {
    widget.onPressed?.call();
    return null;
  }

  @override
  void didUpdateWidget(KaamosPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se diventa disabilitato mentre lo stai premendo, non deve restare
    // "incastrato" nello stato premuto.
    if (!_enabled) _pressed = false;
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _setFocusVisible(bool value) {
    if (_focusVisible != value) setState(() => _focusVisible = value);
  }

  Set<WidgetState> get _states => <WidgetState>{
        if (!_enabled) WidgetState.disabled,
        if (_enabled && _hovered) WidgetState.hovered,
        if (_enabled && _pressed) WidgetState.pressed,
        if (_enabled && _focusVisible) WidgetState.focused,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.isButton,
      link: widget.isLink,
      enabled: _enabled,
      label: widget.semanticLabel,
      // Con un'etichetta esplicita, il testo dentro non va letto due volte.
      excludeSemantics: widget.semanticLabel != null,
      child: ExcludeFocus(
        excluding: !widget.canRequestFocus,
        child: FocusableActionDetector(
          enabled: _enabled,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          actions: _actions,
          onShowFocusHighlight: _setFocusVisible,
          onShowHoverHighlight: _setHovered,
          mouseCursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: GestureDetector(
            // opaque: anche le parti trasparenti (bottone secondary) ricevono
            // il clic, non solo i pixel del testo.
            behavior: HitTestBehavior.opaque,
            onTapDown: _enabled ? (_) => _setPressed(true) : null,
            onTapUp: _enabled ? (_) => _setPressed(false) : null,
            onTapCancel: _enabled ? () => _setPressed(false) : null,
            onTap: widget.onPressed,
            child: widget.builder(context, _states),
          ),
        ),
      ),
    );
  }
}
