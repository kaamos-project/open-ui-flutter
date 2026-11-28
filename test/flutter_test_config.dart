import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

/// Eseguito da `flutter test` prima di ogni file di test.
///
/// Nei test Flutter usa un font finto (Ahem: ogni lettera è un quadrato)
/// per avere misure identiche ovunque. Per i golden test vogliamo invece
/// vedere Inter vero, quindi lo carichiamo a mano dagli asset del pacchetto
/// dei token.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader =
      FontLoader('packages/${KaamosFont.package}/${KaamosFont.family}')
        ..addFont(
          rootBundle
              .load('packages/${KaamosFont.package}/fonts/InterVariable.ttf'),
        );
  await loader.load();
  // Lucide icons (KaamosIcons): same reason, otherwise they'd be Ahem boxes.
  final icons = FontLoader('packages/${KaamosFont.package}/KaamosIcons')
    ..addFont(
      rootBundle.load('packages/${KaamosFont.package}/fonts/KaamosIcons.ttf'),
    );
  await icons.load();
  await testMain();
}
