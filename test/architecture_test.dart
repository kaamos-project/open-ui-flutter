import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// La regola più importante della libreria: niente Material, niente Cupertino.
/// Se un import scappa dentro lib/, questo test lo blocca in CI.
void main() {
  test('lib/ non importa Material né Cupertino', () {
    final forbidden = RegExp(
      r'''import\s+['"]package:flutter/(material|cupertino)\.dart['"]''',
    );
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => forbidden.hasMatch(f.readAsStringSync()))
        .map((f) => f.path)
        .toList();
    expect(offenders, isEmpty, reason: 'Usa solo package:flutter/widgets.dart');
  });
}
