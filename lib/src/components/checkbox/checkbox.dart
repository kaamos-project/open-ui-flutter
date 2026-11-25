import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/icons.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';

/// Casella di spunta (kaamos-checkbox).
///
/// ```dart
/// KaamosCheckbox(
///   value: newsletter,
///   onChanged: (v) => setState(() => newsletter = v!),
///   label: const Text('Iscrivimi alla newsletter'),
/// )
/// ```
///
/// Con [tristate] il valore può essere anche `null` ("in parte", per una
/// casella che riassume altre caselle). Il giro è: false → true → null → false.
///
/// La casella è 16×16, troppo piccola per un dito: passa sempre una [label],
/// così anche il testo diventa cliccabile.
class KaamosCheckbox extends StatelessWidget {
  /// Crea una checkbox. Se [onChanged] è null è disabilitata.
  const KaamosCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.label,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(tristate || value != null);

  /// Spuntata (`true`), vuota (`false`) o in parte (`null`, solo con
  /// [tristate]).
  final bool? value;

  /// Chiamata con il nuovo valore. `null` = disabilitata.
  final ValueChanged<bool?>? onChanged;

  /// Permette il valore `null`.
  final bool tristate;

  /// Testo accanto alla casella, cliccabile anche lui.
  final Widget? label;

  /// Etichetta per gli screen reader, se non c'è una [label] testuale.
  final String? semanticLabel;

  /// Per dare il focus da codice.
  final FocusNode? focusNode;

  /// Prende il focus appena compare.
  final bool autofocus;

  bool? get _next => switch (value) {
        false => true,
        true => tristate ? null : false,
        null => false,
      };

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final enabled = onChanged != null;
    return Semantics(
      checked: value ?? false,
      mixed: tristate && value == null,
      child: KaamosPressable(
        onPressed: enabled ? () => onChanged!(_next) : null,
        isButton: false,
        focusNode: focusNode,
        autofocus: autofocus,
        semanticLabel: semanticLabel,
        builder: (context, states) {
          final on = value != false;
          // Disabilitata e spuntata: al 40% di opacità, come sul web.
          // Usiamo colori con l'alfa invece del widget Opacity, che
          // costringerebbe a disegnare su un livello separato.
          final fade = !enabled && on ? 0.4 : 1.0;
          final Color border;
          if (on) {
            border = theme.primary;
          } else if (!enabled) {
            border = theme.hairline;
          } else {
            border = theme.hairlineStrong;
          }
          final box = KaamosFocusRing(
            visible: states.contains(WidgetState.focused),
            color: theme.focusRing,
            borderRadius: KaamosRadius.xs,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: (on ? theme.primary : theme.surfaceElevated)
                    .withValues(alpha: fade),
                border: Border.all(color: border.withValues(alpha: fade)),
                borderRadius: const BorderRadius.all(
                  Radius.circular(KaamosRadius.xs),
                ),
              ),
              child: SizedBox.square(
                dimension: 16,
                child: on
                    ? Center(
                        child: KaamosIcon(
                          value == null ? KaamosIcons.minus : KaamosIcons.check,
                          size: 12,
                          color: theme.onPrimary.withValues(alpha: fade),
                        ),
                      )
                    : null,
              ),
            ),
          );
          if (label == null) return box;
          return Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              box,
              Flexible(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: enabled ? theme.body : theme.disabledForeground,
                  ),
                  child: label!,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
