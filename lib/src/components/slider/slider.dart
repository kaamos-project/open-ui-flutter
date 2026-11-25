import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/theme.dart';

/// Cursore per scegliere un numero in un intervallo (kaamos-range).
///
/// ```dart
/// KaamosSlider(
///   value: volume,
///   onChanged: (v) => setState(() => volume = v),
///   semanticLabel: 'Volume',
/// )
/// ```
///
/// Tastiera: frecce per un passo, Pagina su/giù per dieci passi, Home/Fine
/// per il minimo e il massimo.
class KaamosSlider extends StatefulWidget {
  /// Crea uno slider. Se [onChanged] è null è disabilitato.
  const KaamosSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.semanticLabel,
    this.semanticFormatter,
    this.focusNode,
    this.autofocus = false,
  })  : assert(min < max),
        assert(value >= min && value <= max),
        assert(divisions == null || divisions > 0);

  /// Il valore attuale, tra [min] e [max].
  final double value;

  /// Chiamata mentre trascini o usi la tastiera. `null` = disabilitato.
  final ValueChanged<double>? onChanged;

  /// Il valore minimo.
  final double min;

  /// Il valore massimo.
  final double max;

  /// Se impostato, il valore salta in [divisions] passi uguali.
  final int? divisions;

  /// Etichetta per gli screen reader.
  final String? semanticLabel;

  /// Come leggere il valore a voce (default: percentuale).
  final String Function(double value)? semanticFormatter;

  /// Per dare il focus da codice.
  final FocusNode? focusNode;

  /// Prende il focus appena compare.
  final bool autofocus;

  @override
  State<KaamosSlider> createState() => _KaamosSliderState();
}

class _KaamosSliderState extends State<KaamosSlider> {
  static const double _thumb = 16;
  static const double _height = 20;
  bool _focusVisible = false;

  bool get _enabled => widget.onChanged != null;
  double get _range => widget.max - widget.min;

  // Un passo: una divisione, oppure l'1% dell'intervallo.
  double get _step =>
      widget.divisions != null ? _range / widget.divisions! : _range / 100;

  double _snap(double v) {
    final clamped = v.clamp(widget.min, widget.max);
    final d = widget.divisions;
    if (d == null) return clamped;
    final steps = ((clamped - widget.min) / _range * d).round();
    return widget.min + steps * _range / d;
  }

  void _set(double v) {
    final next = _snap(v);
    if (next != widget.value) widget.onChanged?.call(next);
  }

  // Da una posizione x (in pixel) al valore. Il centro del pollice va da
  // _thumb/2 a width - _thumb/2, così il pollice non esce mai dal binario.
  void _fromPosition(double dx, double width) {
    final usable = width - _thumb;
    if (usable <= 0) return;
    final t = ((dx - _thumb / 2) / usable).clamp(0.0, 1.0);
    _set(widget.min + t * _range);
  }

  String _format(double v) =>
      widget.semanticFormatter?.call(v) ??
      '${((v - widget.min) / _range * 100).round()}%';

  late final Map<ShortcutActivator, Intent> _shortcuts = {
    const SingleActivator(LogicalKeyboardKey.arrowRight): const _StepIntent(1),
    const SingleActivator(LogicalKeyboardKey.arrowUp): const _StepIntent(1),
    const SingleActivator(LogicalKeyboardKey.arrowLeft): const _StepIntent(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown): const _StepIntent(-1),
    const SingleActivator(LogicalKeyboardKey.pageUp): const _StepIntent(10),
    const SingleActivator(LogicalKeyboardKey.pageDown): const _StepIntent(-10),
    const SingleActivator(LogicalKeyboardKey.home): const _EdgeIntent(false),
    const SingleActivator(LogicalKeyboardKey.end): const _EdgeIntent(true),
  };

  late final Map<Type, Action<Intent>> _actions = {
    _StepIntent: CallbackAction<_StepIntent>(
      onInvoke: (i) => _set(widget.value + i.steps * _step),
    ),
    _EdgeIntent: CallbackAction<_EdgeIntent>(
      onInvoke: (i) => _set(i.toMax ? widget.max : widget.min),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final fraction = (widget.value - widget.min) / _range;
    final fade = _enabled ? 1.0 : 0.4;

    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      enabled: _enabled,
      value: _format(widget.value),
      increasedValue: _format(_snap(widget.value + _step)),
      decreasedValue: _format(_snap(widget.value - _step)),
      onIncrease: _enabled ? () => _set(widget.value + _step) : null,
      onDecrease: _enabled ? () => _set(widget.value - _step) : null,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        shortcuts: _shortcuts,
        actions: _actions,
        onShowFocusHighlight: (v) => setState(() => _focusVisible = v),
        mouseCursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _enabled
                  ? (d) => _fromPosition(d.localPosition.dx, width)
                  : null,
              onHorizontalDragUpdate: _enabled
                  ? (d) => _fromPosition(d.localPosition.dx, width)
                  : null,
              child: SizedBox(
                width: width,
                height: _height,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Il binario: 4px, bordi tondi.
                    Positioned(
                      left: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.hairlineStrong
                              .withValues(alpha: theme.hairlineStrong.a * fade),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(KaamosRadius.full),
                          ),
                        ),
                        child: const SizedBox(height: 4),
                      ),
                    ),
                    // Il pollice.
                    Positioned(
                      left: fraction * (width - _thumb),
                      child: KaamosFocusRing(
                        visible: _focusVisible,
                        color: theme.focusRing,
                        borderRadius: _thumb / 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: fade),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(dimension: _thumb),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepIntent extends Intent {
  const _StepIntent(this.steps);
  final int steps;
}

class _EdgeIntent extends Intent {
  const _EdgeIntent(this.toMax);
  final bool toMax;
}
