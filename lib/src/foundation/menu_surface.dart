import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import 'pressable.dart';
import 'theme.dart';

/// La "carta" su cui stanno menu, select, popover e il menu copia/incolla:
/// `surface`, bordo `hairline`, raggio 10px. Niente ombra, come da DESIGN.md.
class KaamosPopoverSurface extends StatelessWidget {
  /// Crea la superficie attorno a [child].
  const KaamosPopoverSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(4),
  });

  /// Il contenuto.
  final Widget child;

  /// Spazio interno. 4px per le liste (menu, select), 16px per i popover.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.hairline),
        borderRadius: const BorderRadius.all(Radius.circular(KaamosRadius.lg)),
      ),
      child: Padding(
        padding: padding,
        child: DefaultTextStyle(
          style: KaamosTypography.bodyMd.copyWith(color: theme.onDark),
          child: child,
        ),
      ),
    );
  }
}

/// Una riga cliccabile dentro una lista (command-palette-row del DESIGN.md).
/// La usano menu, select, command palette e il menu copia/incolla.
///
/// La riga è "evidenziata" (`surfaceCard`) quando ci passi sopra col mouse,
/// quando ha il focus da tastiera o quando [highlighted] è vero: quest'ultimo
/// serve alle liste dove il focus resta altrove (il campo di ricerca della
/// command palette) e la riga attiva si sceglie con le frecce.
class KaamosListRow extends StatelessWidget {
  /// Crea una riga. Se [onPressed] è null è disabilitata.
  const KaamosListRow({
    super.key,
    required this.onPressed,
    required this.child,
    this.leading,
    this.trailing,
    this.highlighted = false,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.semanticLabel,
    this.selected,
  });

  /// Cosa fare quando la scegli.
  final VoidCallback? onPressed;

  /// Il testo della riga.
  final Widget child;

  /// Icona a sinistra.
  final Widget? leading;

  /// A destra: una scorciatoia (keycap), una spunta, una freccia.
  final Widget? trailing;

  /// Evidenziata da fuori (riga attiva scelta con le frecce).
  final bool highlighted;

  /// Per controllare il focus da fuori.
  final FocusNode? focusNode;

  /// Prende il focus appena compare.
  final bool autofocus;

  /// `false` quando il focus deve restare altrove (es. sul campo di ricerca).
  final bool canRequestFocus;

  /// Testo per gli screen reader.
  final String? semanticLabel;

  /// Per le opzioni di una select: annunciata come "selezionata".
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    Widget row = KaamosPressable(
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      canRequestFocus: canRequestFocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final disabled = states.contains(WidgetState.disabled);
        final active = !disabled &&
            (highlighted ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused));
        final foreground = disabled ? theme.disabledForeground : theme.onDark;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: active ? theme.surfaceCard : null,
            borderRadius: const BorderRadius.all(
              Radius.circular(KaamosRadius.sm),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: IconTheme(
              data: IconThemeData(color: foreground, size: 16),
              child: DefaultTextStyle(
                style: KaamosTypography.bodyMd.copyWith(color: foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Row(
                  spacing: 12,
                  children: [
                    if (leading != null) leading!,
                    Expanded(child: child),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      row = Semantics(selected: selected, child: row);
    }
    return row;
  }
}
