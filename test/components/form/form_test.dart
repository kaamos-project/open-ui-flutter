import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

Widget _sized(Widget child) => wrap(SizedBox(width: 320, child: child));

void main() {
  group('KaamosTextField', () {
    testWidgets('scrive nel controller e chiama onChanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? changed;
      await tester.pumpWidget(
        _sized(
          KaamosTextField(
            controller: controller,
            onChanged: (v) => changed = v,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'ciao');
      expect(controller.text, 'ciao');
      expect(changed, 'ciao');
    });

    testWidgets('il placeholder sparisce quando scrivi', (tester) async {
      await tester.pumpWidget(
        _sized(const KaamosTextField(placeholder: 'tu@esempio.org')),
      );
      expect(find.text('tu@esempio.org'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();
      expect(find.text('tu@esempio.org'), findsNothing);
    });

    testWidgets('alto 36px', (tester) async {
      await tester.pumpWidget(_sized(const KaamosTextField()));
      expect(tester.getSize(find.byType(KaamosTextField)).height, 36);
    });

    testWidgets('disabilitato: non prende il focus', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _sized(KaamosTextField(focusNode: focus, enabled: false)),
      );
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isFalse);
    });

    testWidgets('maxLength taglia il testo', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _sized(KaamosTextField(controller: controller, maxLength: 3)),
      );
      await tester.enterText(find.byType(EditableText), 'abcdef');
      expect(controller.text, 'abc');
    });
  });

  group('KaamosSearchBar', () {
    testWidgets('Esc svuota il campo', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _sized(KaamosSearchBar(controller: controller)),
      );
      await tester.enterText(find.byType(EditableText), 'mail');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(controller.text, isEmpty);
    });

    testWidgets('alta 44px', (tester) async {
      await tester.pumpWidget(_sized(const KaamosSearchBar()));
      expect(tester.getSize(find.byType(KaamosSearchBar)).height, 44);
    });
  });

  group('KaamosCheckbox', () {
    testWidgets('false → true, anche cliccando la label', (tester) async {
      bool? value;
      await tester.pumpWidget(
        wrap(
          KaamosCheckbox(
            value: false,
            onChanged: (v) => value = v,
            label: const Text('Newsletter'),
          ),
        ),
      );
      await tester.tap(find.text('Newsletter'));
      expect(value, isTrue);
    });

    testWidgets('tristate: true → null', (tester) async {
      bool? value = true;
      await tester.pumpWidget(
        wrap(
          KaamosCheckbox(
            value: true,
            tristate: true,
            onChanged: (v) => value = v,
          ),
        ),
      );
      await tester.tap(find.byType(KaamosCheckbox));
      expect(value, isNull);
    });

    testWidgets('semantica: spuntata', (tester) async {
      await tester.pumpWidget(
        wrap(
          KaamosCheckbox(
            value: true,
            onChanged: (_) {},
            label: const Text('Ok'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(KaamosCheckbox)),
        isSemantics(
          hasCheckedState: true,
          isChecked: true,
          isEnabled: true,
          label: 'Ok',
        ),
      );
    });
  });

  group('KaamosSlider', () {
    testWidgets('le frecce spostano di un passo', (tester) async {
      var value = 0.5;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 200,
              child: KaamosSlider(
                value: value,
                divisions: 10,
                focusNode: focus,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, closeTo(0.6, 1e-9));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 0);
    });

    testWidgets('un tocco a destra porta al massimo', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 200,
            child: KaamosSlider(value: 0, onChanged: (v) => value = v),
          ),
        ),
      );
      final box = tester.getRect(find.byType(KaamosSlider));
      await tester.tapAt(Offset(box.right - 1, box.center.dy));
      expect(value, 1);
    });
  });

  testWidgets('golden: controlli dei form', (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final filled = TextEditingController(text: 'alessio@kaamos.dev');
    addTearDown(filled.dispose);

    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const KaamosTextField(placeholder: 'tu@esempio.org'),
              KaamosTextField(controller: filled, invalid: true),
              const KaamosSearchBar(
                placeholder: 'Search...',
                trailing: KaamosKeycap('/'),
              ),
              Row(
                spacing: 16,
                children: [
                  KaamosCheckbox(value: false, onChanged: (_) {}),
                  KaamosCheckbox(value: true, onChanged: (_) {}),
                  KaamosCheckbox(
                    value: null,
                    tristate: true,
                    onChanged: (_) {},
                  ),
                  const KaamosCheckbox(value: true, onChanged: null),
                  KaamosCheckbox(
                    value: true,
                    onChanged: (_) {},
                    label: const Text('Label'),
                  ),
                ],
              ),
              KaamosSlider(value: 0.3, onChanged: (_) {}),
              const KaamosSlider(value: 0.7, onChanged: null),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(KaamosApp),
      matchesGoldenFile('goldens/form.png'),
    );
  });
}
