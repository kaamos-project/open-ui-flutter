import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';

/// Floating action button: the one main action of a screen ("Compose",
/// "New task"), floating over the content in a corner.
///
/// ```dart
/// Stack(children: [
///   list,
///   Positioned(
///     right: 16,
///     bottom: 16,
///     child: KaamosFab(
///       onPressed: compose,
///       icon: const PencilIcon(),
///       label: 'Compose',
///       extended: !scrolledDown,
///     ),
///   ),
/// ])
/// ```
///
/// With a [label] it is an *extended* FAB (icon + text). Set [extended] to
/// false to shrink it to the icon, for example while the user scrolls down
/// a list: the label slides away and the button keeps its place. The
/// [label] stays the accessible name in both shapes.
///
/// It uses the `primary` colours: like the primary button, use one per
/// screen.
class KaamosFab extends StatelessWidget {
  /// Creates a floating action button.
  const KaamosFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.extended = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Called on click, tap, Enter or Space. `null` = disabled.
  final VoidCallback? onPressed;

  /// The icon, usually a [KaamosIcon]. It gets colour and size (24px) from
  /// an [IconTheme].
  final Widget icon;

  /// The text next to the icon. Null = a round icon-only button.
  final String? label;

  /// Whether the [label] is shown. Changes are animated.
  final bool extended;

  /// To control focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as soon as it appears.
  final bool autofocus;

  /// Text for screen readers. Defaults to [label]; needed when there is no
  /// label.
  final String? semanticLabel;

  /// Height, and width of the icon-only shape. 56px: Material's size,
  /// comfortable for a thumb and above the WCAG target size.
  static const double size = 56;

  static const double _iconSize = 24;
  static const double _paddingX = 4 * KaamosSpacing.base; // 16
  static const double _gap = 3 * KaamosSpacing.base; // 12

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final text = label;
    final showLabel = text != null && extended;
    return KaamosPressable(
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel ?? text,
      builder: (context, states) {
        final disabled = states.contains(WidgetState.disabled);
        final pressed = states.contains(WidgetState.pressed);
        final background = disabled
            ? theme.surfaceElevated
            : pressed
                ? theme.primaryPressed
                : theme.primary;
        final foreground =
            disabled ? theme.disabledForeground : theme.onPrimary;
        return KaamosFocusRing(
          visible: states.contains(WidgetState.focused),
          color: theme.focusRing,
          borderRadius: KaamosRadius.xl,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: const BorderRadius.all(
                Radius.circular(KaamosRadius.xl),
              ),
              // It floats over the content: a soft shadow separates it from
              // the rows below. The design system has no elevation tokens,
              // so this is the only shadow in the library.
              boxShadow: disabled
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: SizedBox(
              height: size,
              child: IconTheme(
                data: IconThemeData(color: foreground, size: _iconSize),
                child: DefaultTextStyle(
                  style: theme.buttonTextStyle.copyWith(color: foreground),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // AnimatedSize resizes the button while the label comes
                  // and goes, with the icon staying in place on the left.
                  child: AnimatedSize(
                    duration: KaamosDuration.normal,
                    curve: KaamosEasing.out,
                    alignment: Alignment.centerLeft,
                    child: showLabel
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: _paddingX,
                              right: _paddingX + 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: _gap,
                              children: [icon, Text(text)],
                            ),
                          )
                        : SizedBox.square(
                            dimension: size,
                            child: Center(child: icon),
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
