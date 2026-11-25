/// Kaamos design system per Flutter.
///
/// Costruito solo sul livello `widgets` di Flutter (niente Material o
/// Cupertino): stesso aspetto su desktop, mobile e web.
///
/// ```dart
/// import 'package:kaamos_ui/kaamos_ui.dart';
///
/// void main() => runApp(const KaamosApp(home: HomePage()));
/// ```
library;

// I token vengono riesportati: chi usa la libreria non deve aggiungere
// anche kaamos_design_tokens alle sue dipendenze per avere KaamosColors & co.
export 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

export 'src/components/button/button.dart';
export 'src/foundation/app.dart';
export 'src/foundation/focus_ring.dart';
export 'src/foundation/pressable.dart';
export 'src/foundation/theme.dart';
