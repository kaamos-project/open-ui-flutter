import 'package:flutter/widgets.dart';
import 'package:kaamos_ui/kaamos_ui.dart';

void main() => runApp(const GalleryApp());

/// L'app della gallery.
class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const KaamosApp(title: 'Kaamos UI Gallery', home: GalleryPage());
  }
}

/// Una pagina sola che scorre, con una sezione per componente.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SafeArea: su mobile evita notch e barra di stato.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(6 * KaamosSpacing.base),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12 * KaamosSpacing.base,
              children: [
                _Header(),
                _ButtonSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2 * KaamosSpacing.base,
      children: [
        Text(
          'Kaamos UI',
          style: KaamosTypography.displayLg.copyWith(color: theme.ink),
        ),
        const Text(
          'Il design system Kaamos per Flutter: stesso aspetto su desktop, '
          'mobile e web. Usa Tab per provare il focus da tastiera.',
        ),
      ],
    );
  }
}

/// Una sezione con titolo e un gruppo di esempi.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

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

class _ButtonSection extends StatefulWidget {
  const _ButtonSection();

  @override
  State<_ButtonSection> createState() => _ButtonSectionState();
}

class _ButtonSectionState extends State<_ButtonSection> {
  String _last = 'Nessun bottone premuto';

  void _pressed(String name) => setState(() => _last = 'Premuto: $name');

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Button',
      children: [
        // Wrap: su schermi stretti i bottoni vanno a capo invece di uscire.
        Wrap(
          spacing: 3 * KaamosSpacing.base,
          runSpacing: 3 * KaamosSpacing.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            KaamosButton(
              onPressed: () => _pressed('primary'),
              child: const Text('Download'),
            ),
            KaamosButton(
              onPressed: () => _pressed('secondary'),
              variant: KaamosButtonVariant.secondary,
              trailing: const Text('→'),
              child: const Text('Learn more'),
            ),
            KaamosButton(
              onPressed: () => _pressed('tertiary'),
              variant: KaamosButtonVariant.tertiary,
              child: const Text('Watch demo'),
            ),
            KaamosButton(
              onPressed: () => _pressed('install'),
              variant: KaamosButtonVariant.install,
              child: const Text('Install'),
            ),
          ],
        ),
        Wrap(
          spacing: 3 * KaamosSpacing.base,
          runSpacing: 3 * KaamosSpacing.base,
          children: [
            for (final v in KaamosButtonVariant.values)
              KaamosButton(onPressed: null, variant: v, child: Text(v.name)),
          ],
        ),
        Text(_last),
      ],
    );
  }
}
