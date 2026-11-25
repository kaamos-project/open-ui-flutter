import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';

/// Le misure del riquadro.
enum KaamosAppIconTileSize {
  /// 48×48.
  medium(48),

  /// 64×64.
  large(64);

  const KaamosAppIconTileSize(this.side);

  /// Lato del quadrato in pixel logici.
  final double side;
}

/// Riquadro per l'icona di un'app o integrazione. L'icona riempie tutto il
/// riquadro, con gli angoli arrotondati.
///
/// ```dart
/// KaamosAppIconTile(child: Image.asset('assets/mail.png'))
/// ```
class KaamosAppIconTile extends StatelessWidget {
  /// Crea un riquadro attorno a [child].
  const KaamosAppIconTile({
    super.key,
    required this.child,
    this.size = KaamosAppIconTileSize.medium,
  });

  /// L'icona: di solito un'`Image`.
  final Widget child;

  /// La misura del riquadro.
  final KaamosAppIconTileSize size;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    // ClipRRect serve per tagliare l'immagine agli angoli. Il clip ha un
    // costo, ma qui è piccolo e senza antialias "saveLayer" (il default
    // Clip.antiAlias non crea un livello separato).
    return SizedBox.square(
      dimension: size.side,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(KaamosRadius.md)),
        child: ColoredBox(
          color: theme.surfaceCard,
          child: SizedBox.expand(
            child: FittedBox(fit: BoxFit.cover, child: child),
          ),
        ),
      ),
    );
  }
}
