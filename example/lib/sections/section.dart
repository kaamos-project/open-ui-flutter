import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

/// Una sezione della gallery: titolo e un gruppo di esempi.
class GallerySection extends StatelessWidget {
  const GallerySection(
      {super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4 * KaamosSpacing.base,
      children: [
        Text(title,
            style: KaamosTypography.headingLg.copyWith(color: theme.ink)),
        ...children,
      ],
    );
  }
}

/// Sottotitolo dentro una sezione.
class GalleryLabel extends StatelessWidget {
  const GalleryLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text,
          style: KaamosTypography.captionMd.copyWith(color: theme.mute)),
    );
  }
}

/// Riga di esempi che va a capo sugli schermi stretti.
class GalleryRow extends StatelessWidget {
  const GalleryRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3 * KaamosSpacing.base,
      runSpacing: 3 * KaamosSpacing.base,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
