import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/icons.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';

/// The height of a [KaamosChip].
enum KaamosChipSize {
  /// 22px: inside dense rows, such as a mail list.
  small,

  /// 28px: in forms and detail views, where it may have a remove button.
  medium,
}

/// A chip: a short value the user has, or has picked (a label, a
/// recipient, an attached file), optionally with an X to remove it.
///
/// ```dart
/// KaamosChip('Lavoro')
/// KaamosChip(
///   'Marta Rossi',
///   semanticLabel: 'Marta Rossi, marta@example.org',
///   onRemove: () => remove(marta),
///   removeLabel: 'Remove Marta Rossi',
/// )
/// ```
///
/// Not a [KaamosBadge]: a badge is a tiny marker ("Pro", "Beta") that
/// barely stands out on purpose. A chip is content, so it needs to be seen
/// on the dark canvas: a white 8% fill, a 16% border and light text.
class KaamosChip extends StatelessWidget {
  /// Creates a chip.
  const KaamosChip(
    this.label, {
    super.key,
    this.size = KaamosChipSize.medium,
    this.onRemove,
    this.removeLabel,
    this.semanticLabel,
    this.maxWidth = 240,
  });

  /// The text. Long text is cut with an ellipsis at [maxWidth].
  final String label;

  /// The height.
  final KaamosChipSize size;

  /// Shows an X that calls this. Null = no X.
  final VoidCallback? onRemove;

  /// The X's name for screen readers. Default: "Remove [label]".
  final String? removeLabel;

  /// What screen readers say for the chip, when the text is not enough
  /// (for example a name, plus the address).
  final String? semanticLabel;

  /// The widest the text gets.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final small = size == KaamosChipSize.small;
    final height = small ? 22.0 : 28.0;
    final remove = onRemove;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.hairlineSoft,
        border: Border.all(color: theme.hairlineStrong),
        borderRadius: BorderRadius.all(Radius.circular(height / 2)),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.only(
            left: small ? 8 : 10,
            right: remove == null ? (small ? 8 : 10) : 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Semantics(
                  container: true,
                  label: semanticLabel ?? label,
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: (small
                              ? KaamosTypography.captionSm
                              : KaamosTypography.captionMd)
                          .copyWith(color: theme.ink),
                    ),
                  ),
                ),
              ),
              if (remove != null)
                // A node of its own: otherwise the screen reader merges the
                // chip's name and "Remove".
                Semantics(
                  container: true,
                  child: KaamosPressable(
                    onPressed: remove,
                    semanticLabel: removeLabel ?? 'Remove $label',
                    builder: (context, states) => SizedBox.square(
                      // 24px: the WCAG minimum target, inside a 28px chip.
                      dimension: small ? 20 : 24,
                      child: Center(
                        child: KaamosIcon(
                          KaamosIcons.close,
                          size: 12,
                          color: states.contains(WidgetState.hovered) ||
                                  states.contains(WidgetState.focused)
                              ? theme.ink
                              : theme.onDarkMute,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
