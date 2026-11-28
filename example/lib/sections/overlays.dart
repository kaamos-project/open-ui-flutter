import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import 'section.dart';

class OverlaySection extends StatefulWidget {
  const OverlaySection({super.key});

  @override
  State<OverlaySection> createState() => _OverlaySectionState();
}

class _OverlaySectionState extends State<OverlaySection> {
  String _last = '';

  void _say(String s) => setState(() => _last = s);

  Future<void> _confirm() async {
    final ok = await showKaamosDialog<bool>(
      context: context,
      builder: (context) => KaamosDialog(
        title: 'Eliminare il file?',
        content: const Text('Potrai recuperarlo dal cestino per 30 giorni.'),
        actions: [
          KaamosButton(
            variant: KaamosButtonVariant.secondary,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          KaamosButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    _say(ok == null ? 'Dialog chiuso' : (ok ? 'Eliminato' : 'Annullato'));
  }

  Future<void> _drawer() async {
    final picked = await showKaamosDrawer<String>(
      context: context,
      barrierLabel: 'Chiudi cassetto',
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            for (final f in ['Posta in arrivo', 'Inviati', 'Cestino'])
              KaamosButton(
                variant: KaamosButtonVariant.tertiary,
                onPressed: () => Navigator.of(context).pop(f),
                child: Text(f),
              ),
          ],
        ),
      ),
    );
    _say(picked ?? 'Cassetto chiuso');
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Overlay',
      children: [
        GalleryRow(
          children: [
            KaamosButton(
              variant: KaamosButtonVariant.tertiary,
              onPressed: _confirm,
              child: const Text('Dialog'),
            ),
            KaamosButton(
              variant: KaamosButtonVariant.tertiary,
              onPressed: _drawer,
              child: const Text('Cassetto'),
            ),
            KaamosPopover(
              content: const Text(
                'Testo di aiuto vicino al bottone. Clicca fuori o premi Esc per chiudere.',
              ),
              builder: (context, overlay) => KaamosButton(
                variant: KaamosButtonVariant.tertiary,
                onPressed: overlay.toggle,
                child: const Text('Popover'),
              ),
            ),
            KaamosMenu(
              semanticLabel: 'Azioni sul file',
              items: [
                KaamosMenuItem(
                    label: 'Rinomina', onPressed: () => _say('Rinomina')),
                KaamosMenuItem(
                  label: 'Duplica',
                  onPressed: () => _say('Duplica'),
                  trailing: const KaamosKeycap('⌘ D'),
                ),
                const KaamosMenuItem(label: 'Sposta', onPressed: null),
                const KaamosMenuDivider(),
                KaamosMenuItem(
                    label: 'Elimina', onPressed: () => _say('Elimina')),
              ],
              builder: (context, overlay) => KaamosButton(
                variant: KaamosButtonVariant.tertiary,
                onPressed: overlay.toggle,
                trailing: const KaamosIcon(KaamosIcons.chevronDown),
                child: const Text('Menu'),
              ),
            ),
          ],
        ),
        if (_last.isNotEmpty) Text(_last),
      ],
    );
  }
}
