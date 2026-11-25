import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';

/// Le varianti del badge.
enum KaamosBadgeVariant {
  /// Piano o livello: "Pro", "Pro+", "Free".
  pro,

  /// Etichetta rara: "New", "Beta". Usa l'accento blu: tienila rara.
  info,
}

/// Piccola etichetta (badge-pro e badge-info-soft del DESIGN.md).
///
/// ```dart
/// const KaamosBadge('Pro')
/// const KaamosBadge('Beta', variant: KaamosBadgeVariant.info)
/// ```
class KaamosBadge extends StatelessWidget {
  /// Crea un badge con il testo [label].
  const KaamosBadge(
    this.label, {
    super.key,
    this.variant = KaamosBadgeVariant.pro,
  });

  /// Il testo del badge.
  final String label;

  /// L'aspetto del badge.
  final KaamosBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final (background, foreground, paddingX) = switch (variant) {
      KaamosBadgeVariant.pro => (theme.surfaceElevated, theme.onDarkMute, 6.0),
      KaamosBadgeVariant.info => (theme.accentSoft, theme.accent, 8.0),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(KaamosRadius.xs)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          style: KaamosTypography.captionSm.copyWith(color: foreground),
        ),
      ),
    );
  }
}
