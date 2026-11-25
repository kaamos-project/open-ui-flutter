import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/menu_surface.dart';

/// Il menu Taglia/Copia/Incolla dei campi di testo, nello stile Kaamos.
///
/// Flutter ci dà già *quali* voci servono (`items`: dipendono da cosa è
/// selezionato e da cosa c'è negli appunti) e *dove* metterlo (`anchors`).
/// Noi decidiamo solo l'aspetto: la stessa lista dei menu Kaamos.
class KaamosTextContextMenu extends StatelessWidget {
  /// Crea il menu.
  const KaamosTextContextMenu({
    super.key,
    required this.anchors,
    required this.items,
  });

  /// Dove agganciarlo: il punto del clic destro (desktop) o sopra/sotto la
  /// selezione (touch).
  final TextSelectionToolbarAnchors anchors;

  /// Le voci da mostrare, già filtrate da Flutter.
  final List<ContextMenuButtonItem> items;

  static String _label(BuildContext context, ContextMenuButtonItem item) {
    if (item.label != null) return item.label!;
    // Le etichette tradotte esistono già nel livello widgets: con il
    // pacchetto flutter_localizations l'app le avrà in italiano, finlandese...
    final l = WidgetsLocalizations.of(context);
    return switch (item.type) {
      ContextMenuButtonType.cut => l.cutButtonLabel,
      ContextMenuButtonType.copy => l.copyButtonLabel,
      ContextMenuButtonType.paste => l.pasteButtonLabel,
      ContextMenuButtonType.selectAll => l.selectAllButtonLabel,
      ContextMenuButtonType.lookUp => l.lookUpButtonLabel,
      ContextMenuButtonType.searchWeb => l.searchWebButtonLabel,
      ContextMenuButtonType.share => l.shareButtonLabel,
      ContextMenuButtonType.delete => 'Delete',
      ContextMenuButtonType.liveTextInput => 'Scan text',
      ContextMenuButtonType.custom => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return CustomSingleChildLayout(
      delegate: _MenuLayout(anchors, MediaQuery.paddingOf(context)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
        child: KaamosPopoverSurface(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in items)
                  KaamosListRow(
                    onPressed: item.onPressed,
                    // Il focus deve restare nel campo di testo, altrimenti
                    // il menu si chiuderebbe al primo tocco.
                    canRequestFocus: false,
                    child: Text(_label(context, item)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Posiziona il menu dentro lo schermo.
///
/// - Desktop (un solo punto): l'angolo in alto a sinistra sul cursore; se
///   esce dallo schermo si sposta in alto o a sinistra.
/// - Touch (due punti, sopra e sotto la selezione): sopra la selezione, o
///   sotto se sopra non c'è posto. Così il dito non copre il menu.
class _MenuLayout extends SingleChildLayoutDelegate {
  const _MenuLayout(this.anchors, this.padding);

  final TextSelectionToolbarAnchors anchors;
  final EdgeInsets padding;
  static const double _gap = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size child) {
    final top = padding.top + _gap;
    final bottom = size.height - padding.bottom - _gap;
    final primary = anchors.primaryAnchor;
    final secondary = anchors.secondaryAnchor;

    double y;
    if (secondary == null) {
      y = primary.dy + child.height <= bottom
          ? primary.dy
          : primary.dy - child.height;
    } else {
      y = primary.dy - child.height - _gap >= top
          ? primary.dy - child.height - _gap
          : secondary.dy + _gap;
    }
    final x = secondary == null ? primary.dx : primary.dx - child.width / 2;
    return Offset(
      x.clamp(_gap, math.max(_gap, size.width - child.width - _gap)),
      y.clamp(top, math.max(top, bottom - child.height)),
    );
  }

  @override
  bool shouldRelayout(_MenuLayout old) =>
      old.anchors.primaryAnchor != anchors.primaryAnchor ||
      old.anchors.secondaryAnchor != anchors.secondaryAnchor ||
      old.padding != padding;
}
