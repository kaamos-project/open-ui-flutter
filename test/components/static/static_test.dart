import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

void main() {
  testWidgets('keycap: alto 20px e largo almeno 20px', (tester) async {
    await tester.pumpWidget(wrap(const KaamosKeycap('K')));
    final size = tester.getSize(find.byType(KaamosKeycap));
    expect(size.height, 20);
    expect(size.width, greaterThanOrEqualTo(20));
  });

  testWidgets('keycap: semanticLabel sostituisce il simbolo', (tester) async {
    await tester.pumpWidget(
      wrap(const KaamosKeycap('⌘', semanticLabel: 'Command')),
    );
    expect(find.bySemanticsLabel('Command'), findsOneWidget);
  });

  testWidgets('app icon tile: 48 e 64px', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KaamosAppIconTile(child: SizedBox(width: 10, height: 10)),
            KaamosAppIconTile(
              size: KaamosAppIconTileSize.large,
              child: SizedBox(width: 10, height: 10),
            ),
          ],
        ),
      ),
    );
    final tiles = find.byType(KaamosAppIconTile);
    expect(tester.getSize(tiles.first), const Size.square(48));
    expect(tester.getSize(tiles.last), const Size.square(64));
  });

  testWidgets('link: tap e semantica di link', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(KaamosLink(onPressed: () => taps++, label: 'Docs')),
    );
    await tester.tap(find.text('Docs'));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(KaamosLink)),
      matchesSemantics(
        isLink: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        label: 'Docs',
      ),
    );
  });

  testWidgets('icona decorativa: niente semantica', (tester) async {
    await tester.pumpWidget(wrap(const KaamosIcon(KaamosIcons.search)));
    expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
  });

  testWidgets('golden: componenti statici', (tester) async {
    tester.view.physicalSize = const Size(560, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  KaamosBadge('Pro'),
                  KaamosBadge('Beta', variant: KaamosBadgeVariant.info),
                  KaamosKeycap('⌘'),
                  KaamosKeycap('K'),
                  KaamosKeycap('Esc'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  for (final icon in KaamosIcons.values)
                    KaamosIcon(icon, color: KaamosColors.onDark),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  const KaamosCard(child: Text('Card')),
                  const KaamosCard(
                    variant: KaamosCardVariant.elevated,
                    child: Text('Elevated'),
                  ),
                  KaamosCard(
                    variant: KaamosCardVariant.compact,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        const KaamosAppIconTile(
                          child: ColoredBox(
                            color: KaamosColors.accentGreen,
                            child: SizedBox.square(dimension: 48),
                          ),
                        ),
                        KaamosLink(onPressed: () {}, label: 'Link'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(KaamosApp),
      matchesGoldenFile('goldens/static.png'),
    );
  });
}
