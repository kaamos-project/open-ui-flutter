import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Quello che riceve l'ancora di un popover, menu o select per aprirlo.
abstract interface class KaamosOverlayHandle {
  /// Apre il pannello.
  void show();

  /// Chiude il pannello.
  void hide();

  /// Apre se è chiuso, chiude se è aperto.
  void toggle();

  /// Se il pannello è aperto.
  bool get isShowing;
}

/// Un [KaamosOverlayHandle] che passa tutto a un [OverlayPortalController].
class KaamosOverlayPortalHandle implements KaamosOverlayHandle {
  /// Avvolge [controller].
  const KaamosOverlayPortalHandle(this.controller);

  /// Il controller vero.
  final OverlayPortalController controller;

  @override
  void show() => controller.show();

  @override
  void hide() => controller.hide();

  @override
  void toggle() => controller.toggle();

  @override
  bool get isShowing => controller.isShowing;
}

/// Costruisce l'ancora di un overlay: riceve l'handle per aprirlo.
typedef KaamosOverlayAnchorBuilder = Widget Function(
  BuildContext context,
  KaamosOverlayHandle overlay,
);

/// Un pannello che si apre "attaccato" a un altro widget (l'ancora): la base
/// di popover, menu e select.
///
/// Usa due mattoni del livello widgets:
///
/// - [OverlayPortal]: disegna il pannello nell'[Overlay] (sopra tutto il
///   resto), ma lo lascia *nell'albero* del widget che lo apre. Così il
///   pannello legge lo stesso tema, e se l'ancora sparisce sparisce anche lui.
///   Una route del Navigator (come per il dialog) sarebbe più pesante e
///   andrebbe chiusa a mano.
/// - [CompositedTransformFollower]: il pannello segue l'ancora anche se la
///   pagina scorre, senza ricostruire niente (lavora a livello di layer).
///
/// Dove aprirlo si decide all'apertura: sotto l'ancora se c'è spazio,
/// altrimenti sopra; allineato a sinistra, o a destra se a sinistra non ci
/// sta. Come `position-try-fallbacks: flip-block, flip-inline` del web.
class KaamosAnchoredOverlay extends StatefulWidget {
  /// Crea un'ancora con il suo pannello.
  const KaamosAnchoredOverlay({
    super.key,
    required this.controller,
    required this.overlayBuilder,
    required this.child,
    this.matchAnchorWidth = false,
    this.preferredMaxHeight = 288,
    this.onDismiss,
    this.gap = 4,
  });

  /// Apre e chiude il pannello: `show()`, `hide()`, `toggle()`, `isShowing`.
  final OverlayPortalController controller;

  /// Costruisce il contenuto del pannello.
  final WidgetBuilder overlayBuilder;

  /// L'ancora (di solito il bottone che apre il pannello).
  final Widget child;

  /// Il pannello è largo almeno quanto l'ancora (per la select).
  final bool matchAnchorWidth;

  /// Altezza massima del pannello, se lo schermo lo permette.
  final double preferredMaxHeight;

  /// Chiamato quando l'utente clicca fuori dal pannello e dall'ancora.
  /// Se null il pannello si chiude da solo.
  final VoidCallback? onDismiss;

  /// Distanza tra ancora e pannello.
  final double gap;

  @override
  State<KaamosAnchoredOverlay> createState() => _KaamosAnchoredOverlayState();
}

class _KaamosAnchoredOverlayState extends State<KaamosAnchoredOverlay> {
  final LayerLink _link = LayerLink();
  // Ancora e pannello sono "lo stesso gruppo": un clic su uno dei due non
  // conta come clic fuori.
  final Object _tapGroup = Object();

  void _dismiss() {
    if (!widget.controller.isShowing) return;
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      widget.controller.hide();
    }
  }

  Widget _buildOverlay(BuildContext context) {
    final box = this.context.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    const margin = 8.0;

    final spaceBelow =
        screen.height - padding.bottom - anchor.bottom - widget.gap - margin;
    final spaceAbove = anchor.top - padding.top - widget.gap - margin;
    final below =
        spaceBelow >= widget.preferredMaxHeight || spaceBelow >= spaceAbove;
    final maxHeight = math.max(
      0.0,
      math.min(widget.preferredMaxHeight, below ? spaceBelow : spaceAbove),
    );

    final spaceRight = screen.width - anchor.left - margin;
    final spaceLeft = anchor.right - margin;
    final alignRight = spaceRight < 240 && spaceLeft > spaceRight;
    final maxWidth = math.max(0.0, alignRight ? spaceLeft : spaceRight);

    final (target, follower) = switch ((below, alignRight)) {
      (true, false) => (Alignment.bottomLeft, Alignment.topLeft),
      (true, true) => (Alignment.bottomRight, Alignment.topRight),
      (false, false) => (Alignment.topLeft, Alignment.bottomLeft),
      (false, true) => (Alignment.topRight, Alignment.bottomRight),
    };

    return Align(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: target,
        followerAnchor: follower,
        offset: Offset(0, below ? widget.gap : -widget.gap),
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _dismiss(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.matchAnchorWidth
                  ? math.min(anchor.width, maxWidth)
                  : 0,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: widget.overlayBuilder(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: widget.controller,
        overlayChildBuilder: _buildOverlay,
        child: TapRegion(groupId: _tapGroup, child: widget.child),
      ),
    );
  }
}
