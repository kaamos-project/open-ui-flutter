import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

/// Avvolge [child] in un'app Kaamos minima, centrato, per i test.
Widget wrap(Widget child) {
  return KaamosApp(
    debugShowCheckedModeBanner: false,
    home: Center(child: child),
  );
}
