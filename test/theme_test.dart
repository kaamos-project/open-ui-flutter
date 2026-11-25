import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

void main() {
  testWidgets('senza KaamosTheme si usa il tema scuro', (tester) async {
    late KaamosThemeData read;
    await tester.pumpWidget(
      Builder(builder: (context) {
        read = KaamosTheme.of(context);
        return const SizedBox();
      }),
    );
    expect(read, same(KaamosThemeData.dark));
  });

  test('copyWith cambia solo quello che chiedi', () {
    const red = Color(0xFFFF0000);
    final t = KaamosThemeData.dark.copyWith(primary: red);
    expect(t.primary, red);
    expect(t.canvas, KaamosThemeData.dark.canvas);
    expect(t == KaamosThemeData.dark, isFalse);
    expect(KaamosThemeData.dark.copyWith() == KaamosThemeData.dark, isTrue);
  });
}
