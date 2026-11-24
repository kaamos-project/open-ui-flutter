import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

/// I valori visivi che i componenti Kaamos leggono dal contesto.
///
/// Perché non usare direttamente le costanti dei token (`KaamosColors.canvas`)?
/// Funzionerebbe ed è perfino un filo più veloce, ma blocca per sempre il
/// tema: un domani un tema chiaro, o un'app che vuole un accento diverso,
/// non avrebbe modo di cambiare i colori senza toccare ogni widget.
/// Leggendo da qui, il cambio avviene in un punto solo.
///
/// I campi sono *semantici* (a cosa servono), non una copia di tutta la
/// palette: se ne aggiunge uno quando un componente ne ha davvero bisogno.
@immutable
class KaamosThemeData with Diagnosticable {
  /// Crea un tema con tutti i valori espliciti.
  const KaamosThemeData({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.ink,
    required this.body,
    required this.onDark,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.disabledForeground,
    required this.hairline,
    required this.hairlineStrong,
    required this.focusRing,
    required this.textStyle,
    required this.buttonTextStyle,
  });

  /// L'unico tema per ora: quello scuro del DESIGN.md, preso dai token.
  static const KaamosThemeData dark = KaamosThemeData(
    canvas: KaamosColors.canvas,
    surface: KaamosColors.surface,
    surfaceElevated: KaamosColors.surfaceElevated,
    ink: KaamosColors.ink,
    body: KaamosColors.body,
    onDark: KaamosColors.onDark,
    primary: KaamosColors.primary,
    primaryPressed: KaamosColors.primaryPressed,
    onPrimary: KaamosColors.onPrimary,
    disabledForeground: KaamosColors.ash,
    hairline: KaamosColors.hairline,
    hairlineStrong: KaamosColors.hairlineStrong,
    focusRing: KaamosColors.onDarkMute,
    textStyle: KaamosTypography.bodyMd,
    buttonTextStyle: KaamosTypography.buttonMd,
  );

  /// Sfondo della pagina.
  final Color canvas;

  /// Sfondo delle sezioni.
  final Color surface;

  /// Superfici rialzate (bottone tertiary, bottone disabilitato).
  final Color surfaceElevated;

  /// Testo dei titoli.
  final Color ink;

  /// Testo normale.
  final Color body;

  /// Testo sopra superfici scure (bottoni secondary, tertiary, install).
  final Color onDark;

  /// Colore dell'azione principale (bottone primary).
  final Color primary;

  /// [primary] mentre lo premi.
  final Color primaryPressed;

  /// Testo sopra [primary].
  final Color onPrimary;

  /// Testo dei controlli disabilitati.
  final Color disabledForeground;

  /// Bordi sottili.
  final Color hairline;

  /// Bordi più visibili (bottone install).
  final Color hairlineStrong;

  /// Anello del focus da tastiera.
  final Color focusRing;

  /// Stile del testo di default (body-md, colore [body]).
  final TextStyle textStyle;

  /// Stile del testo dei bottoni.
  final TextStyle buttonTextStyle;

  /// Copia del tema con alcuni valori cambiati.
  KaamosThemeData copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? ink,
    Color? body,
    Color? onDark,
    Color? primary,
    Color? primaryPressed,
    Color? onPrimary,
    Color? disabledForeground,
    Color? hairline,
    Color? hairlineStrong,
    Color? focusRing,
    TextStyle? textStyle,
    TextStyle? buttonTextStyle,
  }) {
    return KaamosThemeData(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      ink: ink ?? this.ink,
      body: body ?? this.body,
      onDark: onDark ?? this.onDark,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      focusRing: focusRing ?? this.focusRing,
      textStyle: textStyle ?? this.textStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
    );
  }

  // == e hashCode servono a updateShouldNotify: se il tema "nuovo" è uguale
  // al vecchio, i widget che lo leggono non vengono ricostruiti.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KaamosThemeData &&
        other.canvas == canvas &&
        other.surface == surface &&
        other.surfaceElevated == surfaceElevated &&
        other.ink == ink &&
        other.body == body &&
        other.onDark == onDark &&
        other.primary == primary &&
        other.primaryPressed == primaryPressed &&
        other.onPrimary == onPrimary &&
        other.disabledForeground == disabledForeground &&
        other.hairline == hairline &&
        other.hairlineStrong == hairlineStrong &&
        other.focusRing == focusRing &&
        other.textStyle == textStyle &&
        other.buttonTextStyle == buttonTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        canvas,
        surface,
        surfaceElevated,
        ink,
        body,
        onDark,
        primary,
        primaryPressed,
        onPrimary,
        disabledForeground,
        hairline,
        hairlineStrong,
        focusRing,
        textStyle,
        buttonTextStyle,
      );
}

/// Mette un [KaamosThemeData] a disposizione di tutti i widget sotto di lui.
///
/// È un [InheritedWidget]: leggerlo con [KaamosTheme.of] costa una lookup in
/// una tabella (O(1)) e registra il widget come dipendente, così viene
/// ricostruito solo se il tema cambia davvero.
///
/// Non usiamo `ThemeExtension` perché vive dentro `ThemeData` di Material,
/// e questa libreria non dipende da Material.
class KaamosTheme extends InheritedWidget {
  /// Applica [data] a [child] e a tutto il suo sottoalbero.
  const KaamosTheme({super.key, required this.data, required super.child});

  /// Il tema da applicare.
  final KaamosThemeData data;

  /// Il tema più vicino sopra [context], o [KaamosThemeData.dark] se non ce
  /// n'è nessuno (così un widget funziona anche in un test senza KaamosApp).
  static KaamosThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<KaamosTheme>();
    return theme?.data ?? KaamosThemeData.dark;
  }

  @override
  bool updateShouldNotify(KaamosTheme oldWidget) => data != oldWidget.data;
}
