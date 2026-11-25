import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';

/// Le maniglie di selezione Kaamos (solo su touch): un cerchietto bianco
/// sotto l'inizio e la fine della selezione, da trascinare col dito.
///
/// [TextSelectionHandleControls] è il modo moderno: le maniglie le
/// disegniamo noi, il menu passa da `contextMenuBuilder`.
class KaamosTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  static const double _size = 20;
  static const double _dot = 12;

  @override
  Size getHandleSize(double textLineHeight) => const Size(_size, _size);

  // Il punto della maniglia che coincide con la fine della riga di testo:
  // il centro in alto, così il cerchietto sta subito sotto il cursore.
  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      const Offset(_size / 2, 0);

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final theme = KaamosTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox.square(
        dimension: _size,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.cursor,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: _dot),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un'istanza condivisa: le maniglie non hanno stato.
final TextSelectionControls kaamosTextSelectionControls =
    KaamosTextSelectionControls();
