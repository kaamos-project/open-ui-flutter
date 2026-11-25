import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import '../../helpers.dart';

const _langs = [
  KaamosSelectOption(value: 'fi', label: 'Suomi', group: 'Paesi nordici'),
  KaamosSelectOption(value: 'sv', label: 'Svenska', group: 'Paesi nordici'),
  KaamosSelectOption(value: 'is', label: 'Íslenska', enabled: false),
  KaamosSelectOption(value: 'it', label: 'Italiano'),
];

Widget _select(String? value, ValueChanged<String> onChanged,
    {FocusNode? focus}) {
  return wrap(
    SizedBox(
      width: 240,
      child: KaamosSelect<String>(
        value: value,
        focusNode: focus,
        placeholder: 'Scegli una lingua',
        options: _langs,
        onChanged: onChanged,
      ),
    ),
  );
}

void main() {
  group('KaamosPopover', () {
    testWidgets('si apre col bottone e si chiude con Esc', (tester) async {
      await tester.pumpWidget(
        wrap(
          KaamosPopover(
            content: const Text('Aiuto'),
            builder: (context, overlay) => KaamosButton(
              onPressed: overlay.toggle,
              child: const Text('Info'),
            ),
          ),
        ),
      );
      expect(find.text('Aiuto'), findsNothing);
      await tester.tap(find.text('Info'));
      await tester.pump();
      expect(find.text('Aiuto'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('Aiuto'), findsNothing);
    });

    testWidgets('si chiude cliccando fuori', (tester) async {
      await tester.pumpWidget(
        wrap(
          KaamosPopover(
            content: const Text('Aiuto'),
            builder: (context, overlay) => KaamosButton(
              onPressed: overlay.toggle,
              child: const Text('Info'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Info'));
      await tester.pump();
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.text('Aiuto'), findsNothing);
    });
  });

  group('KaamosMenu', () {
    Future<List<String>> openMenu(WidgetTester tester) async {
      final chosen = <String>[];
      await tester.pumpWidget(
        wrap(
          KaamosMenu(
            items: [
              KaamosMenuItem(
                  label: 'Rinomina', onPressed: () => chosen.add('r')),
              const KaamosMenuItem(label: 'Sposta', onPressed: null),
              const KaamosMenuDivider(),
              KaamosMenuItem(
                  label: 'Elimina', onPressed: () => chosen.add('e')),
            ],
            builder: (context, overlay) => KaamosButton(
              onPressed: overlay.toggle,
              child: const Text('Azioni'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Azioni'));
      await tester.pump();
      await tester.pump();
      return chosen;
    }

    testWidgets('frecce saltano le voci disabilitate, Invio sceglie',
        (tester) async {
      final chosen = await openMenu(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(chosen, ['e']);
      expect(find.text('Rinomina'), findsNothing);
    });

    testWidgets('le frecce girano in tondo', (tester) async {
      final chosen = await openMenu(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(chosen, ['e']);
    });

    testWidgets('Esc chiude senza scegliere', (tester) async {
      final chosen = await openMenu(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(chosen, isEmpty);
      expect(find.text('Rinomina'), findsNothing);
    });

    testWidgets('clic su una voce', (tester) async {
      final chosen = await openMenu(tester);
      await tester.tap(find.text('Rinomina'));
      await tester.pump();
      expect(chosen, ['r']);
    });
  });

  group('KaamosSelect', () {
    testWidgets('mostra il placeholder e sceglie col clic', (tester) async {
      String? value;
      await tester.pumpWidget(_select(null, (v) => value = v));
      expect(find.text('Scegli una lingua'), findsOneWidget);
      await tester.tap(find.byType(KaamosSelect<String>));
      await tester.pump();
      expect(find.text('Paesi nordici'), findsOneWidget);
      await tester.tap(find.text('Italiano'));
      await tester.pump();
      expect(value, 'it');
      expect(find.text('Paesi nordici'), findsNothing);
    });

    testWidgets('tastiera: apre, salta le disabilitate, Invio sceglie',
        (tester) async {
      String? value;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_select('sv', (v) => value = v, focus: focus));
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // apre su sv
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // salta is
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, 'it');
    });

    testWidgets('ricerca digitando a lista chiusa', (tester) async {
      String? value;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_select(null, (v) => value = v, focus: focus));
      focus.requestFocus();
      await tester.pump();
      // Nessuna scelta: "s" va alla prima che inizia con s.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      expect(value, 'fi');
      // Timer della ricerca: lasciamolo scadere per chiudere il test pulito.
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('disabilitata: non si apre', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 240,
            child: KaamosSelect<String>(
              value: 'fi',
              options: _langs,
              onChanged: null,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(KaamosSelect<String>));
      await tester.pump();
      expect(find.text('Paesi nordici'), findsNothing);
    });
  });

  group('KaamosDialog', () {
    testWidgets('restituisce la scelta', (tester) async {
      bool? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => KaamosButton(
              onPressed: () async {
                result = await showKaamosDialog<bool>(
                  context: context,
                  builder: (context) => KaamosDialog(
                    title: 'Eliminare il file?',
                    actions: [
                      KaamosButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Elimina'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Apri'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();
      expect(find.text('Eliminare il file?'), findsOneWidget);
      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(find.text('Eliminare il file?'), findsNothing);
    });

    testWidgets('Esc chiude con null', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => KaamosButton(
              onPressed: () async {
                final r = await showKaamosDialog<bool>(
                  context: context,
                  builder: (context) => const KaamosDialog(title: 'Titolo'),
                );
                closed = r == null;
              },
              child: const Text('Apri'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(closed, isTrue);
    });
  });

  testWidgets('golden: select e menu aperti', (tester) async {
    tester.view.physicalSize = const Size(560, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final menu = GlobalKey();
    await tester.pumpWidget(
      wrap(
        Align(
          alignment: const Alignment(0, -0.8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              SizedBox(
                width: 220,
                child: KaamosSelect<String>(
                  value: 'sv',
                  options: _langs,
                  onChanged: (_) {},
                ),
              ),
              KaamosMenu(
                key: menu,
                items: [
                  KaamosMenuItem(label: 'Rinomina', onPressed: () {}),
                  KaamosMenuItem(
                    label: 'Duplica',
                    onPressed: () {},
                    trailing: const KaamosKeycap('⌘ D'),
                  ),
                  const KaamosMenuItem(label: 'Sposta', onPressed: null),
                  const KaamosMenuDivider(),
                  KaamosMenuItem(label: 'Elimina', onPressed: () {}),
                ],
                builder: (context, overlay) => KaamosButton(
                  variant: KaamosButtonVariant.tertiary,
                  onPressed: overlay.toggle,
                  child: const Text('Azioni'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(KaamosSelect<String>));
    await tester.pump();
    await expectLater(
      find.byType(KaamosApp),
      matchesGoldenFile('goldens/select_open.png'),
    );
    // Aprendo il menu la select si chiude: un clic fuori.
    await tester.tap(find.text('Azioni'));
    await tester.pump();
    await tester.pump();
    await expectLater(
      find.byType(KaamosApp),
      matchesGoldenFile('goldens/menu_open.png'),
    );
  });
}
