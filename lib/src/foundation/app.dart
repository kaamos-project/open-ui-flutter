import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Radice di un'app Kaamos: l'equivalente di `MaterialApp`, ma senza Material.
///
/// Sotto usa [WidgetsApp], che dà già navigazione, localizzazioni di base,
/// scorciatoie da tastiera di sistema e il titolo della finestra. Sopra
/// aggiunge solo il nostro tema, lo stile di testo di default e lo sfondo.
class KaamosApp extends StatelessWidget {
  /// Crea un'app con [home] come prima schermata.
  const KaamosApp({
    super.key,
    required this.home,
    this.title = '',
    this.theme = KaamosThemeData.dark,
    this.navigatorKey,
    this.debugShowCheckedModeBanner = true,
  });

  /// La prima schermata.
  final Widget home;

  /// Titolo della finestra (desktop) o della scheda (web).
  final String title;

  /// Il tema dell'app.
  final KaamosThemeData theme;

  /// Per navigare senza un [BuildContext].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Il nastro "DEBUG" in alto a destra.
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context) {
    return KaamosTheme(
      data: theme,
      child: WidgetsApp(
        title: title,
        color: theme.canvas,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        textStyle: theme.textStyle.copyWith(color: theme.body),
        home: home,
        // WidgetsApp non sa che pagina creare (MaterialApp usa
        // MaterialPageRoute). Una PageRouteBuilder senza animazione è la
        // scelta neutra: le transizioni Kaamos le definiremo quando servono.
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        },
        builder: (context, child) => ColoredBox(
          color: theme.canvas,
          child: child,
        ),
      ),
    );
  }
}
