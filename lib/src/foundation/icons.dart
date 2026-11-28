import 'package:flutter/widgets.dart';

// The Lucide icons live in the tokens package; we re-export them so components
// and apps get both KaamosIcon and KaamosIcons from one import.
export 'package:kaamos_design_tokens/kaamos_icons.dart' show KaamosIcons;

/// Shows an icon, usually one of the Lucide [KaamosIcons] from
/// `kaamos_design_tokens` (re-exported by this library).
///
/// ```dart
/// const KaamosIcon(KaamosIcons.search)
/// ```
///
/// Colour and size come from [IconTheme], like Flutter's [Icon], so inside a
/// `KaamosButton` the icon takes the text colour by itself. The default size
/// is 16, not 24: it's the size of the icons in the design system.
///
/// Always pass a `const` [IconData] (a `KaamosIcons.*` constant): release
/// builds keep only the glyphs used in the code (icon tree-shaking).
class KaamosIcon extends StatelessWidget {
  /// Creates an icon. If [semanticLabel] is null the icon is decorative and
  /// screen readers skip it.
  const KaamosIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Which icon, e.g. `KaamosIcons.mail`.
  final IconData icon;

  /// Side of the square. Default: `IconTheme.size`, otherwise 16.
  final double? size;

  /// Stroke colour. Default: `IconTheme.color`.
  final Color? color;

  /// Text for screen readers, if the icon means something on its own.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final glyph = Icon(
      icon,
      size: size ?? theme.size ?? 16,
      color: color ?? theme.color ?? const Color(0xFFFFFFFF),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: glyph);
    return Semantics(label: semanticLabel, child: glyph);
  }
}
