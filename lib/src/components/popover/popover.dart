import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/anchored_overlay.dart';
import '../../foundation/menu_surface.dart';
import '../../foundation/theme.dart';

/// Un pannello leggero vicino a un bottone (kaamos-popover): un aiuto, un
/// dettaglio, qualche controllo. Si chiude cliccando fuori o con Esc.
///
/// ```dart
/// KaamosPopover(
///   content: const Text('Testo di aiuto vicino al bottone.'),
///   builder: (context, popover) => KaamosButton(
///     variant: KaamosButtonVariant.tertiary,
///     onPressed: popover.toggle,
///     child: const Text('Info'),
///   ),
/// )
/// ```
class KaamosPopover extends StatefulWidget {
  /// Crea un popover.
  const KaamosPopover({
    super.key,
    required this.content,
    required this.builder,
    this.controller,
  });

  /// Il contenuto del pannello.
  final Widget content;

  /// L'ancora: chiama `overlay.toggle()` per aprire e chiudere.
  final KaamosOverlayAnchorBuilder builder;

  /// Per aprirlo da fuori. Se null ne crea uno suo.
  final OverlayPortalController? controller;

  @override
  State<KaamosPopover> createState() => _KaamosPopoverState();
}

class _KaamosPopoverState extends State<KaamosPopover> {
  late final OverlayPortalController _own = OverlayPortalController();
  OverlayPortalController get _controller => widget.controller ?? _own;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return KaamosAnchoredOverlay(
      controller: _controller,
      preferredMaxHeight: 400,
      overlayBuilder: (context) => ConstrainedBox(
        // max-w-xs del web.
        constraints: const BoxConstraints(maxWidth: 320),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): _controller.hide,
          },
          // Il focus entra nel pannello, così Esc funziona e chi usa la
          // tastiera può raggiungere i controlli dentro.
          child: FocusScope(
            autofocus: true,
            child: KaamosPopoverSurface(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: KaamosTypography.bodySm.copyWith(color: theme.body),
                child: widget.content,
              ),
            ),
          ),
        ),
      ),
      child: widget.builder(context, KaamosOverlayPortalHandle(_controller)),
    );
  }
}
