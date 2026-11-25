/// Kaamos design system per Flutter.
///
/// Costruito solo sul livello `widgets` di Flutter (niente Material o
/// Cupertino): stesso aspetto su desktop, mobile e web.
///
/// ```dart
/// import 'package:kaamos_project_ui/kaamos_project_ui.dart';
///
/// void main() => runApp(const KaamosApp(home: HomePage()));
/// ```
library;

// I token vengono riesportati: chi usa la libreria non deve aggiungere
// anche kaamos_design_tokens alle sue dipendenze per avere KaamosColors & co.
export 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

export 'src/components/app_icon_tile/app_icon_tile.dart';
export 'src/components/badge/badge.dart';
export 'src/components/button/button.dart';
export 'src/components/card/card.dart';
export 'src/components/checkbox/checkbox.dart';
export 'src/components/command_palette/command_palette.dart';
export 'src/components/dialog/dialog.dart';
export 'src/components/keycap/keycap.dart';
export 'src/components/link/link.dart';
export 'src/components/menu/menu.dart';
export 'src/components/nav/nav_bar.dart';
export 'src/components/popover/popover.dart';
export 'src/components/select/select.dart';
export 'src/components/slider/slider.dart';
export 'src/components/tabs/pill_tab.dart';
export 'src/components/tabs/tabs.dart';
export 'src/components/text_field/search_bar.dart';
export 'src/components/text_field/text_field.dart';
export 'src/foundation/anchored_overlay.dart';
export 'src/foundation/app.dart';
export 'src/foundation/focus_ring.dart';
export 'src/foundation/icons.dart';
export 'src/foundation/menu_surface.dart';
export 'src/foundation/pressable.dart';
export 'src/foundation/scroll.dart';
export 'src/foundation/theme.dart';
