import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import 'section.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Navigazione',
      children: [
        const GalleryLabel('Pill tab (filtri)'),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final f in const ['All', 'Recently Added', 'Most Popular'])
              KaamosPillTab(
                label: f,
                selected: _filter == f,
                onPressed: () => setState(() => _filter = f),
              ),
          ],
        ),
        const GalleryLabel('Tab (sezioni)'),
        const KaamosTabs(
          semanticLabel: 'Impostazioni account',
          labels: ['Generale', 'Account', 'Privacy'],
          panels: [
            Text('Lingua, tema e scorciatoie.'),
            Text('Nome, email e password.'),
            Text('Impostazioni della privacy.'),
          ],
        ),
        const GalleryLabel(
            'La barra in alto è KaamosNavBar: restringi la finestra sotto 768px per vedere il cassetto.'),
      ],
    );
  }
}
