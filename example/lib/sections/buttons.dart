import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import 'section.dart';

class ButtonSection extends StatefulWidget {
  const ButtonSection({super.key});

  @override
  State<ButtonSection> createState() => _ButtonSectionState();
}

class _ButtonSectionState extends State<ButtonSection> {
  String _last = 'Nessun bottone premuto';

  void _pressed(String name) => setState(() => _last = 'Premuto: $name');

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Button',
      children: [
        GalleryRow(
          children: [
            KaamosButton(
                onPressed: () => _pressed('primary'),
                child: const Text('Download')),
            KaamosButton(
              onPressed: () => _pressed('secondary'),
              variant: KaamosButtonVariant.secondary,
              trailing: const KaamosIcon(KaamosIcons.arrowRight),
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
        GalleryRow(
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
