import 'package:flutter/widgets.dart';

/// Le icone disponibili. Disegnate a mano con linee su una griglia 16×16,
/// tratto 1.5px con estremi arrotondati (stesso stile delle SVG di
/// open-ui-web).
///
/// Perché non un pacchetto di icone o `flutter_svg`? Per ora ne servono
/// poche: disegnarle costa zero dipendenze e zero parsing a runtime. Quando
/// saranno decine, la strada giusta è un font di icone generato dalla repo
/// dei token (una lettera = un'icona, velocissimo da disegnare).
enum KaamosIcons {
  /// Lente: campi di ricerca.
  search,

  /// Spunta: checkbox, opzione selezionata.
  check,

  /// Trattino: checkbox "in parte".
  minus,

  /// Freccia in giù: select, menu a tendina.
  chevronDown,

  /// Freccia a destra: sottomenu, voci che portano altrove.
  chevronRight,

  /// X: chiudi dialog e cassetti.
  close,

  /// Hamburger: apre la navigazione su mobile.
  menu,

  /// Freccia: "Learn more →".
  arrowRight,
}

/// Disegna una [KaamosIcons].
///
/// Colore e misura arrivano da [IconTheme] (come per l'`Icon` di Flutter),
/// così dentro un `KaamosButton` l'icona prende da sola il colore del testo.
class KaamosIcon extends StatelessWidget {
  /// Crea un'icona. Se [semanticLabel] è null l'icona è decorativa e gli
  /// screen reader la saltano.
  const KaamosIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Quale icona.
  final KaamosIcons icon;

  /// Lato del quadrato. Default: `IconTheme.size`, altrimenti 16.
  final double? size;

  /// Colore del tratto. Default: `IconTheme.color`.
  final Color? color;

  /// Testo per gli screen reader, se l'icona ha un significato da sola.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 16;
    final paint = CustomPaint(
      size: Size.square(side),
      painter: _IconPainter(
        icon,
        color ?? theme.color ?? const Color(0xFFFFFFFF),
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: paint);
    return Semantics(label: semanticLabel, child: paint);
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.icon, this.color);

  final KaamosIcons icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Disegniamo su una griglia 16×16 e scaliamo: le coordinate restano
    // leggibili e l'icona è nitida a qualsiasi misura.
    final s = size.width / 16;
    canvas.scale(s);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path line(List<Offset> points) {
      final p = Path()..moveTo(points.first.dx, points.first.dy);
      for (final o in points.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    switch (icon) {
      case KaamosIcons.search:
        canvas.drawCircle(const Offset(7, 7), 4.5, paint);
        canvas.drawPath(
            line(const [Offset(10.5, 10.5), Offset(14, 14)]), paint);
      case KaamosIcons.check:
        canvas.drawPath(
          line(const [Offset(3.5, 8.5), Offset(6.5, 11.5), Offset(12.5, 4.5)]),
          paint,
        );
      case KaamosIcons.minus:
        canvas.drawPath(line(const [Offset(4, 8), Offset(12, 8)]), paint);
      case KaamosIcons.chevronDown:
        canvas.drawPath(
          line(const [Offset(4, 6), Offset(8, 10), Offset(12, 6)]),
          paint,
        );
      case KaamosIcons.chevronRight:
        canvas.drawPath(
          line(const [Offset(6, 4), Offset(10, 8), Offset(6, 12)]),
          paint,
        );
      case KaamosIcons.close:
        canvas.drawPath(line(const [Offset(4, 4), Offset(12, 12)]), paint);
        canvas.drawPath(line(const [Offset(12, 4), Offset(4, 12)]), paint);
      case KaamosIcons.menu:
        for (final y in const [4.0, 8.0, 12.0]) {
          canvas.drawPath(line([Offset(2.5, y), Offset(13.5, y)]), paint);
        }
      case KaamosIcons.arrowRight:
        canvas.drawPath(line(const [Offset(3, 8), Offset(13, 8)]), paint);
        canvas.drawPath(
          line(const [Offset(9, 4), Offset(13, 8), Offset(9, 12)]),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color;
}
