import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';

/// The widest a drawer gets (Tailwind `w-72`).
const double kaamosDrawerMaxWidth = 288;

/// Opens a modal drawer that slides in from the left, over a dimmed
/// [KaamosThemeData.scrim], and waits for it to close.
///
/// ```dart
/// showKaamosDrawer<void>(
///   context: context,
///   barrierLabel: 'Close folders',
///   builder: (context) => FolderList(
///     onSelected: (folder) {
///       Navigator.of(context).pop();
///       open(folder);
///     },
///   ),
/// );
/// ```
///
/// The drawer is 85% of the screen, at most [maxWidth], so the page stays
/// visible on the right: the user sees where they will go back to.
///
/// Like the dialog it is a Navigator route: Android's back button, Esc and
/// a tap on the scrim close it, focus stays inside, and the page below gets
/// no taps. To close it from the content, pop the route
/// (`Navigator.of(context).pop(result)`) with the `context` given to
/// [builder].
Future<T?> showKaamosDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String barrierLabel = 'Close menu',
  double maxWidth = kaamosDrawerMaxWidth,
}) {
  final theme = KaamosTheme.of(context);
  return Navigator.of(context).push<T>(
    RawDialogRoute<T>(
      barrierDismissible: true,
      barrierLabel: barrierLabel,
      barrierColor: theme.scrim,
      transitionDuration: KaamosDuration.normal,
      // The route lives in the Navigator's Overlay, outside the caller's
      // subtree: the theme has to be passed on by hand.
      pageBuilder: (context, animation, secondaryAnimation) => KaamosTheme(
        data: theme,
        child: KaamosDrawerPanel(
            maxWidth: maxWidth, child: Builder(builder: builder)),
      ),
      // SlideTransition moves the layer only, without a layout per frame.
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: KaamosEasing.out),
        ),
        child: child,
      ),
    ),
  );
}

/// The panel of [showKaamosDrawer]: full height, on the left, 85% of the
/// screen width and at most [maxWidth], with the canvas colour and a
/// hairline on the right. Public so that a drawer's look can be tested or
/// reused without the route.
class KaamosDrawerPanel extends StatelessWidget {
  /// Creates the panel.
  const KaamosDrawerPanel({
    super.key,
    required this.child,
    this.maxWidth = kaamosDrawerMaxWidth,
  });

  /// The drawer's content. It is laid out inside a [SafeArea].
  final Widget child;

  /// The widest the panel gets.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final width = MediaQuery.sizeOf(context).width * 0.85;
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: width < maxWidth ? width : maxWidth,
        height: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.canvas,
            border: Border(right: BorderSide(color: theme.hairline)),
          ),
          child: SafeArea(
            right: false,
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
