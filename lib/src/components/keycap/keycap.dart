import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';

/// Un tasto della tastiera, per mostrare le scorciatoie (⌘ K, Esc).
///
/// ```dart
/// const Row(spacing: 4, children: [KaamosKeycap('⌘'), KaamosKeycap('K')])
/// ```
class KaamosKeycap extends StatelessWidget {
  /// Crea un tasto con il testo [label].
  const KaamosKeycap(this.label, {super.key, this.semanticLabel});

  /// Il testo sul tasto.
  final String label;

  /// Come leggerlo a voce: "⌘" non dice niente a uno screen reader,
  /// "Command" sì.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Gradiente dall'alto in basso, come un tasto vero.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.keyBgStart, theme.keyBgEnd],
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(KaamosRadius.xs),
          ),
        ),
        // CSS: h-5 min-w-5 px-1.5 → alto 20, largo almeno 20.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          child: SizedBox(
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  maxLines: 1,
                  style: KaamosTypography.captionMd.copyWith(color: theme.body),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
