import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Come si comportano tutte le aree che scorrono in un'app Kaamos.
///
/// Flutter di default imita il sistema: su Android lo scroll si ferma al
/// bordo con un bagliore, su iOS e macOS "rimbalza", e la barra di scorrimento
/// cambia aspetto. Qui scegliamo un comportamento solo, uguale ovunque:
///
/// - [ClampingScrollPhysics]: lo scroll si ferma al bordo, senza rimbalzo
///   (come sul web). Da riconfermare con Alessio: vedi domanda nel thread.
/// - nessun effetto di overscroll (niente bagliore di Android);
/// - barra sottile nel colore `hairlineStrong`, che compare mentre scorri.
///
/// `KaamosApp` la applica già a tutta l'app.
class KaamosScrollBehavior extends ScrollBehavior {
  /// Il comportamento di scroll Kaamos.
  const KaamosScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final theme = KaamosTheme.of(context);
    return RawScrollbar(
      controller: details.controller,
      thumbColor: theme.hairlineStrong,
      thickness: 6,
      radius: const Radius.circular(3),
      // Un po' di spazio dal bordo, così il pollice non tocca la cornice.
      crossAxisMargin: 2,
      mainAxisMargin: 2,
      child: child,
    );
  }
}
