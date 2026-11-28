import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

void main() {
  group('KaamosChip', () {
    testWidgets('without onRemove it has no X', (tester) async {
      await tester.pumpWidget(wrap(const KaamosChip('Lavoro')));
      expect(find.text('Lavoro'), findsOneWidget);
      expect(find.bySemanticsLabel('Remove Lavoro'), findsNothing);
      expect(tester.getSize(find.byType(KaamosChip)).height, 28);
    });

    testWidgets('the X calls onRemove and has its own name', (tester) async {
      var removed = 0;
      await tester.pumpWidget(
        wrap(
          KaamosChip(
            'Marta Rossi',
            semanticLabel: 'Marta Rossi, marta@example.org',
            onRemove: () => removed++,
            removeLabel: 'Togli Marta',
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Marta Rossi, marta@example.org'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Togli Marta'));
      expect(removed, 1);
    });

    testWidgets('small is 22px tall', (tester) async {
      await tester.pumpWidget(
        wrap(const KaamosChip('Lavoro', size: KaamosChipSize.small)),
      );
      expect(tester.getSize(find.byType(KaamosChip)).height, 22);
    });

    testWidgets('long text is cut at maxWidth', (tester) async {
      await tester.pumpWidget(
        wrap(KaamosChip('x' * 200, maxWidth: 100)),
      );
      expect(tester.getSize(find.byType(KaamosChip)).width, lessThan(130));
    });

    testWidgets('golden: sizes, with and without X, next to a badge',
        (tester) async {
      tester.view.physicalSize = const Size(520, 100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const KaamosChip('Action Items', size: KaamosChipSize.small),
              const KaamosChip('Lavoro'),
              KaamosChip('Marta Rossi', onRemove: () {}),
              const KaamosBadge('Pro'),
            ],
          ),
        ),
      );
      await expectLater(
        find.byType(KaamosApp),
        matchesGoldenFile('goldens/chip_variants.png'),
      );
    });
  });
}
