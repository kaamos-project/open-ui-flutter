import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';

/// Link testuale (link-inline del DESIGN.md): testo `onDark` in link-md,
/// sottolineato al passaggio del mouse.
///
/// Flutter non sa cosa sia un URL: [onPressed] decide cosa fare (navigare
/// a una pagina, aprire il browser con un pacchetto come url_launcher...).
class KaamosLink extends StatelessWidget {
  /// Crea un link. Se [onPressed] è null è disabilitato.
  const KaamosLink({
    super.key,
    required this.onPressed,
    required this.label,
    this.style,
  });

  /// Cosa fare al clic.
  final VoidCallback? onPressed;

  /// Il testo del link.
  final String label;

  /// Per usarlo dentro testo più piccolo (es. `KaamosTypography.bodySm`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return KaamosPressable(
      onPressed: onPressed,
      // Semantica di link, non di bottone: lo screen reader dice "link".
      isButton: false,
      isLink: true,
      builder: (context, states) {
        final disabled = states.contains(WidgetState.disabled);
        final hovered = states.contains(WidgetState.hovered);
        return KaamosFocusRing(
          visible: states.contains(WidgetState.focused),
          color: theme.focusRing,
          borderRadius: KaamosRadius.xs,
          child: Text(
            label,
            style: (style ?? KaamosTypography.linkMd).copyWith(
              color: disabled ? theme.disabledForeground : theme.onDark,
              decoration: hovered ? TextDecoration.underline : null,
              decorationColor: theme.onDark,
            ),
          ),
        );
      },
    );
  }
}
