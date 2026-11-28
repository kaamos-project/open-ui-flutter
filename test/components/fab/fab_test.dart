import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

void main() {
  group('KaamosFab', () {
    const icon = KaamosIcon(KaamosIcons.menu);

    testWidgets('calls onPressed on tap, Enter and Space', (tester) async {
      var taps = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        wrap(
          KaamosFab(
            onPressed: () => taps++,
            icon: icon,
            label: 'Compose',
            focusNode: focus,
          ),
        ),
      );
      await tester.tap(find.text('Compose'));
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 3);
    });

    testWidgets('extended shows the label, collapsed is a 56px square',
        (tester) async {
      Widget fab(bool extended) => wrap(
            KaamosFab(
              onPressed: () {},
              icon: icon,
              label: 'Compose',
              extended: extended,
            ),
          );
      await tester.pumpWidget(fab(true));
      expect(find.text('Compose'), findsOneWidget);
      expect(tester.getSize(find.byType(KaamosFab)).width, greaterThan(56));

      await tester.pumpWidget(fab(false));
      await tester.pumpAndSettle();
      expect(find.text('Compose'), findsNothing);
      expect(tester.getSize(find.byType(KaamosFab)), const Size(56, 56));
    });

    testWidgets('the label stays the accessible name when collapsed',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          KaamosFab(
            onPressed: () {},
            icon: icon,
            label: 'Compose',
            extended: false,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Compose'), findsOneWidget);
    });

    testWidgets('with onPressed null it is disabled', (tester) async {
      await tester.pumpWidget(
        wrap(const KaamosFab(onPressed: null, icon: icon, label: 'Compose')),
      );
      expect(
        tester.getSemantics(find.byType(KaamosFab)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          label: 'Compose',
        ),
      );
    });

    testWidgets('golden: extended, collapsed, disabled', (tester) async {
      tester.view.physicalSize = const Size(420, 120);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              KaamosFab(onPressed: () {}, icon: icon, label: 'Compose'),
              KaamosFab(
                onPressed: () {},
                icon: icon,
                label: 'Compose',
                extended: false,
              ),
              const KaamosFab(onPressed: null, icon: icon, label: 'Compose'),
            ],
          ),
        ),
      );
      await expectLater(
        find.byType(KaamosApp),
        matchesGoldenFile('goldens/fab_states.png'),
      );
    });
  });
}
