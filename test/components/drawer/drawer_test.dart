import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

void main() {
  group('showKaamosDrawer', () {
    // The panel aligns its box to the left: measure the box, not the Align.
    final panelBox = find
        .descendant(
          of: find.byType(KaamosDrawerPanel),
          matching: find.byType(DecoratedBox),
        )
        .first;

    Future<Future<String?>> open(WidgetTester tester, {Size? size}) async {
      tester.view.physicalSize = size ?? const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late BuildContext page;
      await tester.pumpWidget(
        KaamosApp(
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (context) {
              page = context;
              return const Center(child: Text('Page'));
            },
          ),
        ),
      );
      final result = showKaamosDrawer<String>(
        context: page,
        barrierLabel: 'Close folders',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaamosButton(
                onPressed: () => Navigator.of(context).pop('inbox'),
                child: const Text('Inbox'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('is 85% of a narrow phone, and the page shows beside it',
        (tester) async {
      await open(tester, size: const Size(320, 640));
      final panel = tester.getRect(panelBox);
      expect(panel.left, 0);
      expect(panel.width, closeTo(320 * 0.85, 0.01));
      expect(find.text('Page'), findsOneWidget);
    });

    testWidgets('is at most 288px wide on large screens', (tester) async {
      await open(tester, size: const Size(1280, 800));
      final panel = tester.getRect(panelBox);
      expect(panel.width, kaamosDrawerMaxWidth);
    });

    testWidgets('returns what the content pops', (tester) async {
      final result = await open(tester);
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(await result, 'inbox');
      expect(find.text('Inbox'), findsNothing);
    });

    testWidgets('a tap on the scrim closes it with null', (tester) async {
      final result = await open(tester);
      await tester.tapAt(const Offset(380, 400));
      await tester.pumpAndSettle();
      expect(await result, isNull);
      expect(find.byType(KaamosDrawerPanel), findsNothing);
    });

    testWidgets('Esc closes it', (tester) async {
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(KaamosDrawerPanel), findsNothing);
    });

    testWidgets('golden: drawer over the dimmed page', (tester) async {
      await open(tester);
      await expectLater(
        find.byType(KaamosApp),
        matchesGoldenFile('goldens/drawer_phone.png'),
      );
    });
  });
}
