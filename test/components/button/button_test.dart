import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

void main() {
  group('KaamosButton', () {
    testWidgets('chiama onPressed al tocco', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(KaamosButton(onPressed: () => taps++, child: const Text('Ok'))),
      );
      await tester.tap(find.text('Ok'));
      expect(taps, 1);
    });

    testWidgets('con onPressed null è disabilitato', (tester) async {
      await tester.pumpWidget(
        wrap(const KaamosButton(onPressed: null, child: Text('Ok'))),
      );
      // Il tap non deve lanciare errori né fare niente.
      await tester.tap(find.text('Ok'));
      expect(
        tester.getSemantics(find.byType(KaamosButton)),
        matchesSemantics(isButton: true, hasEnabledState: true, label: 'Ok'),
      );
    });

    testWidgets('Invio e Spazio lo attivano quando ha il focus',
        (tester) async {
      var taps = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        wrap(
          KaamosButton(
            onPressed: () => taps++,
            focusNode: focus,
            child: const Text('Ok'),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 2);
    });

    testWidgets("l'anello del focus compare solo usando la tastiera",
        (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        wrap(
          KaamosButton(
            onPressed: () {},
            focusNode: focus,
            child: const Text('Ok'),
          ),
        ),
      );
      bool ringVisible() =>
          tester.widget<KaamosFocusRing>(find.byType(KaamosFocusRing)).visible;

      // Un tocco: modalità "touch", niente anello anche se prende il focus.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      focus.requestFocus();
      await tester.pump();
      expect(ringVisible(), isFalse);

      // Tastiera: l'anello compare.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      await tester.pump();
      expect(ringVisible(), isTrue);

      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
    });

    testWidgets('altezze dal DESIGN.md: 36px, install 32px', (tester) async {
      await tester.pumpWidget(
        wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaamosButton(onPressed: () {}, child: const Text('Primary')),
              KaamosButton(
                onPressed: () {},
                variant: KaamosButtonVariant.install,
                child: const Text('Install'),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(KaamosButton).first).height, 36);
      expect(tester.getSize(find.byType(KaamosButton).last).height, 32);
    });

    testWidgets('golden: tutte le varianti e stati', (tester) async {
      tester.view.physicalSize = const Size(560, 220);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final focus = FocusNode();
      addTearDown(focus.dispose);
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);

      Widget row(bool enabled) => Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              for (final v in KaamosButtonVariant.values)
                KaamosButton(
                  onPressed: enabled ? () {} : null,
                  variant: v,
                  child: Text(v.name),
                ),
            ],
          );

      await tester.pumpWidget(
        wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              row(true),
              row(false),
              KaamosButton(
                onPressed: () {},
                focusNode: focus,
                trailing: const Text('→'),
                child: const Text('Focus'),
              ),
            ],
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await expectLater(
        find.byType(KaamosApp),
        matchesGoldenFile('goldens/button_variants.png'),
      );
    });
  });
}
