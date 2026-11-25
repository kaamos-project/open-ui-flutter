import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

void main() {
  group('KaamosTabs', () {
    Widget tabs({ValueChanged<int>? onChanged}) => wrap(
          KaamosTabs(
            labels: const ['Generale', 'Account', 'Privacy'],
            panels: const [Text('P0'), Text('P1'), Text('P2')],
            onChanged: onChanged,
          ),
        );

    testWidgets('mostra solo il pannello attivo e cambia col clic',
        (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(tabs(onChanged: changes.add));
      expect(find.text('P0'), findsOneWidget);
      expect(find.text('P1'), findsNothing);
      await tester.tap(find.text('Privacy'));
      await tester.pump();
      expect(find.text('P2'), findsOneWidget);
      expect(changes, [2]);
    });

    testWidgets('frecce girano in tondo, Home/Fine', (tester) async {
      await tester.pumpWidget(tabs());
      // Tab: il focus entra nella tab attiva.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(find.text('P2'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('P0'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(find.text('P2'), findsOneWidget);
    });
  });

  group('KaamosPillTab', () {
    testWidgets('semantica di interruttore', (tester) async {
      await tester.pumpWidget(
        wrap(KaamosPillTab(label: 'All', selected: true, onPressed: () {})),
      );
      expect(
        tester.getSemantics(find.byType(KaamosPillTab)),
        isSemantics(hasToggledState: true, isToggled: true, label: 'All'),
      );
    });
  });

  group('KaamosNavBar', () {
    Widget nav(Size size, List<String> visited) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: KaamosApp(
          debugShowCheckedModeBanner: false,
          home: Align(
            alignment: Alignment.topCenter,
            child: KaamosNavBar(
              brand: const Text('Kaamos'),
              items: [
                KaamosNavItem(
                  label: 'Home',
                  current: true,
                  onPressed: () => visited.add('home'),
                ),
                KaamosNavItem(
                    label: 'Mail', onPressed: () => visited.add('mail')),
              ],
              secondaryActions: const [Text('Accedi')],
              actions: [
                KaamosButton(onPressed: () {}, child: const Text('Download')),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('desktop: link visibili, niente hamburger', (tester) async {
      tester.view.physicalSize = const Size(1024, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(nav(const Size(1024, 400), []));
      expect(find.text('Mail'), findsOneWidget);
      expect(find.text('Accedi'), findsOneWidget);
      expect(find.bySemanticsLabel('Open menu'), findsNothing);
      expect(tester.getSize(find.byType(KaamosNavBar)).height, 56);
    });

    testWidgets('mobile: cassetto con i link', (tester) async {
      tester.view.physicalSize = const Size(390, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final visited = <String>[];
      await tester.pumpWidget(nav(const Size(390, 700), visited));
      expect(find.text('Mail'), findsNothing);
      expect(find.text('Accedi'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mail'));
      await tester.pumpAndSettle();
      expect(visited, ['mail']);
      expect(find.text('Mail'), findsNothing);
    });
  });

  testWidgets('golden: tab, pill tab e nav', (tester) async {
    tester.view.physicalSize = const Size(800, 260);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      KaamosApp(
        debugShowCheckedModeBanner: false,
        home: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KaamosNavBar(
              brand: const Text('Kaamos'),
              items: [
                KaamosNavItem(label: 'Home', current: true, onPressed: () {}),
                KaamosNavItem(label: 'Mail', onPressed: () {}),
                KaamosNavItem(label: 'Drive', onPressed: () {}),
              ],
              secondaryActions: [KaamosLink(label: 'Accedi', onPressed: () {})],
              actions: [
                KaamosButton(onPressed: () {}, child: const Text('Download')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      KaamosPillTab(
                          label: 'All', selected: true, onPressed: () {}),
                      KaamosPillTab(
                        label: 'Recently Added',
                        selected: false,
                        onPressed: () {},
                      ),
                      const KaamosPillTab(
                        label: 'Disabled',
                        selected: false,
                        onPressed: null,
                      ),
                    ],
                  ),
                  const KaamosTabs(
                    labels: ['Generale', 'Account', 'Privacy'],
                    panels: [
                      Text('Lingua, tema e scorciatoie.'),
                      Text('Nome, email e password.'),
                      Text('Impostazioni della privacy.'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(KaamosApp),
      matchesGoldenFile('goldens/navigation.png'),
    );
  });
}
