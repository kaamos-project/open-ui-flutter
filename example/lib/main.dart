import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import 'sections/buttons.dart';
import 'sections/forms.dart';
import 'sections/navigation.dart';
import 'sections/overlays.dart';
import 'sections/static.dart';

void main() => runApp(const GalleryApp());

/// L'app della gallery.
class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const KaamosApp(title: 'Kaamos UI Gallery', home: GalleryPage());
  }
}

/// I comandi della palette (⌘K / Ctrl+K): portano alle sezioni.
const _commands = [
  KaamosCommand(value: 0, label: 'Button', keywords: ['bottone']),
  KaamosCommand(
      value: 1,
      label: 'Componenti statici',
      keywords: ['badge', 'keycap', 'card']),
  KaamosCommand(
      value: 2,
      label: 'Form',
      keywords: ['input', 'checkbox', 'slider', 'select']),
  KaamosCommand(
      value: 3, label: 'Overlay', keywords: ['menu', 'dialog', 'popover']),
  KaamosCommand(value: 4, label: 'Navigazione', keywords: ['tab', 'pill']),
];

/// Una pagina che scorre, con la barra in alto e una sezione per gruppo.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  // Una chiave per sezione, per scorrere fino a lei dalla palette o dalla nav.
  final _keys = List.generate(5, (_) => GlobalKey());

  void _goTo(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: KaamosDuration.normal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      const ButtonSection(),
      const StaticSection(),
      const FormSection(),
      const OverlaySection(),
      const NavigationSection(),
    ];
    return KaamosCommandPaletteShortcut<int>(
      commands: _commands,
      onSelected: _goTo,
      child: SafeArea(
        child: Column(
          children: [
            KaamosNavBar(
              brand: const Text('Kaamos UI'),
              items: [
                KaamosNavItem(
                    label: 'Button', onPressed: () => _goTo(0), current: true),
                KaamosNavItem(label: 'Form', onPressed: () => _goTo(2)),
                KaamosNavItem(label: 'Overlay', onPressed: () => _goTo(3)),
              ],
              actions: [
                Builder(
                  builder: (context) => KaamosButton(
                    variant: KaamosButtonVariant.tertiary,
                    onPressed: () async {
                      final v = await showKaamosCommandPalette<int>(
                        context: context,
                        commands: _commands,
                      );
                      if (v != null) _goTo(v);
                    },
                    trailing: const KaamosKeycap('⌘K'),
                    child: const Text('Cerca'),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(6 * KaamosSpacing.base),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16 * KaamosSpacing.base,
                      children: [
                        const _Header(),
                        for (var i = 0; i < sections.length; i++)
                          KeyedSubtree(key: _keys[i], child: sections[i]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        Text('Kaamos UI',
            style: KaamosTypography.displayLg.copyWith(color: theme.ink)),
        const Text(
          'Il design system Kaamos per Flutter: stesso aspetto su desktop, '
          'mobile e web. Usa Tab per il focus da tastiera e ⌘K / Ctrl+K per '
          'la command palette.',
        ),
      ],
    );
  }
}
