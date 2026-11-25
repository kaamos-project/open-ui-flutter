import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';

/// Chip di filtro a forma di pillola (pill-tab del DESIGN.md).
///
/// Da usare per **filtri** che si accendono e spengono sulla stessa lista
/// ("All", "Most Popular"). Per sezioni con contenuti diversi usa
/// [KaamosTabs], che usa lo stesso aspetto ma per uno screen reader è
/// un'altra cosa.
///
/// ```dart
/// KaamosPillTab(
///   label: 'Most Popular',
///   selected: filter == Filter.popular,
///   onPressed: () => setState(() => filter = Filter.popular),
/// )
/// ```
class KaamosPillTab extends StatelessWidget {
  /// Crea una pill tab. Se [onPressed] è null è disabilitata.
  const KaamosPillTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.focusNode,
    this.asTab = false,
  });

  /// Il testo.
  final String label;

  /// Accesa o spenta.
  final bool selected;

  /// Cosa fare al clic.
  final VoidCallback? onPressed;

  /// Per dare il focus da codice.
  final FocusNode? focusNode;

  /// Usata da [KaamosTabs]: per gli screen reader è una tab "selezionata"
  /// invece di un interruttore "premuto".
  final bool asTab;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Semantics(
      // aria-pressed per i filtri, aria-selected dentro un gruppo di tab.
      toggled: asTab ? null : selected,
      selected: asTab ? selected : null,
      child: KaamosPressable(
        onPressed: onPressed,
        focusNode: focusNode,
        isButton: !asTab,
        builder: (context, states) {
          final disabled = states.contains(WidgetState.disabled);
          final Color foreground;
          if (disabled) {
            foreground = theme.disabledForeground;
          } else if (selected) {
            foreground = theme.onDark;
          } else {
            foreground = theme.body;
          }
          return KaamosFocusRing(
            visible: states.contains(WidgetState.focused),
            color: theme.focusRing,
            borderRadius: KaamosRadius.full,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? theme.surfaceElevated : null,
                borderRadius: const BorderRadius.all(
                  Radius.circular(KaamosRadius.full),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: KaamosTypography.bodySm.copyWith(color: foreground),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
