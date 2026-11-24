import 'package:flutter/widgets.dart';

/// Anello del focus da tastiera, come `outline` + `outline-offset` del CSS.
///
/// Viene disegnato *fuori* dai bordi del figlio senza cambiarne la misura:
/// quando compare non sposta niente nel layout (niente salto della pagina).
/// Funziona perché Flutter non ritaglia la pittura ai bordi del widget, a
/// meno che qualcuno sopra non usi un Clip.
class KaamosFocusRing extends StatelessWidget {
  /// Disegna l'anello attorno a [child] quando [visible] è vero.
  const KaamosFocusRing({
    super.key,
    required this.visible,
    required this.color,
    required this.borderRadius,
    required this.child,
    this.width = 2,
    this.offset = 2,
  });

  /// Se mostrare l'anello.
  final bool visible;

  /// Colore dell'anello.
  final Color color;

  /// Raggio degli angoli del figlio: l'anello lo segue, allargato di [offset].
  final double borderRadius;

  /// Spessore della linea (CSS: outline-width).
  final double width;

  /// Distanza dal bordo del figlio (CSS: outline-offset).
  final double offset;

  /// Il widget attorno a cui disegnare l'anello.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: visible
          ? _RingPainter(
              color: color,
              borderRadius: borderRadius,
              width: width,
              offset: offset,
            )
          : null,
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.color,
    required this.borderRadius,
    required this.width,
    required this.offset,
  });

  final Color color;
  final double borderRadius;
  final double width;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    // Il tratto è centrato sulla linea: per avere la linea che *inizia* a
    // [offset] dal bordo, la spostiamo fuori di altri width / 2.
    final grow = offset + width / 2;
    final rect = (Offset.zero & size).inflate(grow);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius + grow),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color ||
      old.borderRadius != borderRadius ||
      old.width != width ||
      old.offset != offset;
}
