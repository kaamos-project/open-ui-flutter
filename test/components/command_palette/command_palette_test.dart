import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

const _commands = [
  KaamosCommand(
    value: 'new',
    label: 'Nuova email',
    trailing: KaamosKeycap('⌘ N'),
    keywords: ['posta', 'scrivi'],
  ),
  KaamosCommand(value: 'search', label: 'Cerca nella posta'),
  KaamosCommand(value: 'settings', label: 'Impostazioni'),
];

Widget _app(List<String> selected) => KaamosApp(
      debugShowCheckedModeBanner: false,
      home: KaamosCommandPaletteShortcut<String>(
        commands: _commands,
        onSelected: selected.add,
        child: const Center(child: Text('Home')),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Ctrl+K apre, il filtro restringe, Invio sceglie',
      (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_app(selected));
    await _open(tester);
    expect(find.text('Impostazioni'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'imp');
    await tester.pump();
    expect(find.text('Nuova email'), findsNothing);
    expect(find.text('Impostazioni'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();
    expect(selected, ['settings']);
    expect(find.text('Impostazioni'), findsNothing);
  });

  testWidgets('le keyword trovano il comando', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_app(selected));
    await _open(tester);
    await tester.enterText(find.byType(EditableText), 'SCRIVI');
    await tester.pump();
    expect(find.text('Nuova email'), findsOneWidget);
    expect(find.text('Cerca nella posta'), findsNothing);
  });

  testWidgets('le frecce spostano la riga attiva', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_app(selected));
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();
    expect(selected, ['settings']);
  });

  testWidgets('nessun risultato', (tester) async {
    await tester.pumpWidget(_app([]));
    await _open(tester);
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pump();
    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('Esc chiude senza scegliere', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_app(selected));
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsNothing);
    expect(selected, isEmpty);
  });

  testWidgets('filtro personalizzato', (tester) async {
    String? picked;
    await tester.pumpWidget(
      KaamosApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) => KaamosButton(
            onPressed: () async {
              picked = await showKaamosCommandPalette<String>(
                context: context,
                commands: _commands,
                // Solo l'inizio del testo.
                filter: (c, q) => c.label.toLowerCase().startsWith(q),
              );
            },
            child: const Text('Apri'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'posta');
    await tester.pump();
    expect(find.text('Cerca nella posta'), findsNothing);
    await tester.enterText(find.byType(EditableText), 'cer');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();
    expect(picked, 'search');
  });

  testWidgets('golden: command palette', (tester) async {
    tester.view.physicalSize = const Size(640, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app([]));
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await expectLater(
      find.byType(KaamosApp),
      matchesGoldenFile('goldens/command_palette.png'),
    );
  });
}
