import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';

/// Le varianti del bottone, come nel DESIGN.md e in `<kaamos-button>`.
enum KaamosButtonVariant {
  /// Bianco pieno: l'azione principale. Una sola per schermata.
  primary,

  /// Solo testo su sfondo trasparente: azioni leggere ("Learn more →").
  secondary,

  /// Superficie soffice: azioni medie dentro le card.
  tertiary,

  /// Bordo sottile, più compatto (32px): sulle card dello store.
  install,
}

/// Bottone d'azione Kaamos.
///
/// ```dart
/// KaamosButton(
///   onPressed: () => print('ciao'),
///   child: const Text('Download'),
/// )
/// ```
///
/// Con `onPressed: null` il bottone è disabilitato (convenzione di Flutter,
/// come per i bottoni Material): niente parametro `disabled` separato che
/// potrebbe contraddire la callback.
class KaamosButton extends StatelessWidget {
  /// Crea un bottone. [child] è di solito un [Text].
  const KaamosButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = KaamosButtonVariant.primary,
    this.leading,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Chiamato al clic, al tocco o con Invio/Spazio. `null` = disabilitato.
  final VoidCallback? onPressed;

  /// L'etichetta del bottone.
  final Widget child;

  /// L'aspetto del bottone.
  final KaamosButtonVariant variant;

  /// Icona prima dell'etichetta (8px di distanza).
  final Widget? leading;

  /// Icona dopo l'etichetta (8px di distanza).
  final Widget? trailing;

  /// Per controllare il focus da fuori.
  final FocusNode? focusNode;

  /// Prende il focus appena compare.
  final bool autofocus;

  /// Testo per gli screen reader, utile se [child] è solo un'icona.
  final String? semanticLabel;

  // Misure dal DESIGN.md (stesse di open-ui-web): 36px di altezza e 16px ai
  // lati, install 32px e 14px. 36px supera già la soglia WCAG AA di 24px per
  // i bersagli touch, quindi usiamo una densità sola su tutte le piattaforme.
  static const double _height = 36;
  static const double _installHeight = 32;
  static const double _paddingX = 4 * KaamosSpacing.base; // 16
  static const double _installPaddingX = 3.5 * KaamosSpacing.base; // 14
  static const double _gap = 2 * KaamosSpacing.base; // 8
  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return KaamosPressable(
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final style = _ButtonStyle.resolve(theme, variant, states);
        final isInstall = variant == KaamosButtonVariant.install;
        return KaamosFocusRing(
          visible: states.contains(WidgetState.focused),
          color: theme.focusRing,
          borderRadius: KaamosRadius.md,
          // DecoratedBox + Padding invece di Container: fanno lo stesso
          // lavoro ma si vede esattamente cosa viene creato.
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.background,
              border: style.border,
              borderRadius: const BorderRadius.all(
                Radius.circular(KaamosRadius.md),
              ),
            ),
            child: SizedBox(
              height: isInstall ? _installHeight : _height,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isInstall ? _installPaddingX : _paddingX,
                ),
                child: IconTheme(
                  data: IconThemeData(color: style.foreground, size: _iconSize),
                  child: DefaultTextStyle(
                    style: theme.buttonTextStyle.copyWith(
                      color: style.foreground,
                    ),
                    // CSS: whitespace-nowrap.
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: _gap,
                      children: [
                        if (leading != null) leading!,
                        Flexible(child: child),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// I colori di una variante in un certo stato. Separato dal widget così si
/// legge come la tabella del DESIGN.md.
class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Border? border;

  static _ButtonStyle resolve(
    KaamosThemeData theme,
    KaamosButtonVariant variant,
    Set<WidgetState> states,
  ) {
    // button-disabled: uguale per tutte le varianti. Il bordo resta (ma
    // trasparente) così install non cambia misura quando lo disabiliti.
    if (states.contains(WidgetState.disabled)) {
      return _ButtonStyle(
        background: theme.surfaceElevated,
        foreground: theme.disabledForeground,
        border: variant == KaamosButtonVariant.install
            ? Border.all(color: const Color(0x00000000))
            : null,
      );
    }
    final pressed = states.contains(WidgetState.pressed);
    return switch (variant) {
      KaamosButtonVariant.primary => _ButtonStyle(
          background: pressed ? theme.primaryPressed : theme.primary,
          foreground: theme.onPrimary,
        ),
      KaamosButtonVariant.secondary => _ButtonStyle(
          background: const Color(0x00000000),
          foreground: theme.onDark,
        ),
      KaamosButtonVariant.tertiary => _ButtonStyle(
          background: theme.surfaceElevated,
          foreground: theme.onDark,
        ),
      KaamosButtonVariant.install => _ButtonStyle(
          background: const Color(0x00000000),
          foreground: theme.onDark,
          border: Border.all(color: theme.hairlineStrong),
        ),
    };
  }
}
