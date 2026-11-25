import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';

/// Le varianti della card. Come sul web, una sola famiglia: la cornice è la
/// stessa, cambia il contenuto.
enum KaamosCardVariant {
  /// `surface`, padding 24, raggio 10 (feature-card-dark, pricing-tier-card).
  normal,

  /// Un gradino più chiara (feature-card-elevated, pricing-tier-card-featured).
  elevated,

  /// Padding 16, raggio 8: per contenuti in riga (store-extension-card).
  compact,
}

/// Contenitore con superficie e bordo sottile. Niente ombre: nel DESIGN.md
/// la profondità viene solo dalla scala delle superfici.
///
/// ```dart
/// KaamosCard(
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: [Text('Kaamos Mail', style: KaamosTypography.headingSm)],
///   ),
/// )
/// ```
class KaamosCard extends StatelessWidget {
  /// Crea una card attorno a [child].
  const KaamosCard({
    super.key,
    required this.child,
    this.variant = KaamosCardVariant.normal,
  });

  /// Il contenuto.
  final Widget child;

  /// L'aspetto della card.
  final KaamosCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final compact = variant == KaamosCardVariant.compact;
    final radius = compact ? KaamosRadius.md : KaamosRadius.lg;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: variant == KaamosCardVariant.elevated
            ? theme.surfaceElevated
            : theme.surface,
        border: Border.all(color: theme.hairline),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.onDark),
          child: child,
        ),
      ),
    );
  }
}
