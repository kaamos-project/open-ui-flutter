import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import 'section.dart';

class StaticSection extends StatelessWidget {
  const StaticSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return GallerySection(
      title: 'Componenti statici',
      children: [
        const GalleryLabel('Badge e keycap'),
        const GalleryRow(
          children: [
            KaamosBadge('Pro'),
            KaamosBadge('Beta', variant: KaamosBadgeVariant.info),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                KaamosKeycap('⌘', semanticLabel: 'Command'),
                KaamosKeycap('K'),
              ],
            ),
            KaamosKeycap('Esc'),
          ],
        ),
        const GalleryLabel('Chip'),
        GalleryRow(
          children: [
            const KaamosChip('Lavoro', size: KaamosChipSize.small),
            const KaamosChip('Viaggi'),
            KaamosChip(
              'Marta Rossi',
              onRemove: () {},
              removeLabel: 'Togli Marta Rossi',
            ),
          ],
        ),
        const GalleryLabel('Icone'),
        GalleryRow(
          children: [
            for (final icon in KaamosIcons.values)
              KaamosIcon(icon, size: 20, color: theme.onDark),
          ],
        ),
        const GalleryLabel('Card'),
        GalleryRow(
          children: [
            SizedBox(
              width: 280,
              child: KaamosCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text('Kaamos Mail',
                        style: KaamosTypography.headingSm
                            .copyWith(color: theme.ink)),
                    Text(
                      'Un client email libero e veloce.',
                      style:
                          KaamosTypography.bodySm.copyWith(color: theme.mute),
                    ),
                    KaamosLink(label: 'Learn more →', onPressed: () {}),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 280,
              child: KaamosCard(
                variant: KaamosCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Text('Pro',
                            style: KaamosTypography.headingXl
                                .copyWith(color: theme.ink)),
                        const KaamosBadge('Consigliato',
                            variant: KaamosBadgeVariant.info),
                      ],
                    ),
                    Text('€0',
                        style: KaamosTypography.displayLg
                            .copyWith(color: theme.ink)),
                    const Text('È software libero.'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: KaamosCard(
                variant: KaamosCardVariant.compact,
                child: Row(
                  spacing: 16,
                  children: [
                    const KaamosAppIconTile(
                      child: ColoredBox(
                        color: KaamosColors.accentGreen,
                        child: SizedBox.square(dimension: 48),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mail Sorter',
                              style: KaamosTypography.bodyStrong
                                  .copyWith(color: theme.ink)),
                          Text(
                            'di Kaamos · Ordina la posta con regole locali',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: KaamosTypography.captionMd
                                .copyWith(color: theme.mute),
                          ),
                        ],
                      ),
                    ),
                    KaamosButton(
                      variant: KaamosButtonVariant.install,
                      onPressed: () {},
                      child: const Text('Install'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
