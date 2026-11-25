import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/anchored_overlay.dart';
import '../../foundation/menu_surface.dart';
import '../../foundation/theme.dart';

/// Una voce o un separatore di [KaamosMenu].
sealed class KaamosMenuEntry {
  const KaamosMenuEntry();
}

/// Una voce del menu.
class KaamosMenuItem extends KaamosMenuEntry {
  /// Crea una voce. Se [onPressed] è null è disabilitata.
  const KaamosMenuItem({
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
  });

  /// Il testo della voce.
  final String label;

  /// Cosa fare quando la scegli. Il menu si chiude prima di chiamarla.
  final VoidCallback? onPressed;

  /// Icona a sinistra.
  final Widget? leading;

  /// A destra: di solito i keycap della scorciatoia.
  final Widget? trailing;
}

/// Linea di separazione tra gruppi di voci.
class KaamosMenuDivider extends KaamosMenuEntry {
  /// Crea un separatore.
  const KaamosMenuDivider();
}

/// Menu a tendina che si apre da un bottone (kaamos-menu).
///
/// ```dart
/// KaamosMenu(
///   items: [
///     KaamosMenuItem(label: 'Rinomina', onPressed: rename),
///     KaamosMenuItem(
///       label: 'Duplica',
///       onPressed: duplicate,
///       trailing: const KaamosKeycap('⌘ D'),
///     ),
///     const KaamosMenuItem(label: 'Sposta', onPressed: null),
///     const KaamosMenuDivider(),
///     KaamosMenuItem(label: 'Elimina', onPressed: delete),
///   ],
///   builder: (context, menu) => KaamosButton(
///     variant: KaamosButtonVariant.tertiary,
///     onPressed: menu.toggle,
///     child: const Text('Azioni'),
///   ),
/// )
/// ```
///
/// Tastiera: all'apertura il focus va sulla prima voce. ↑ ↓ si muovono
/// (girando in tondo e saltando le voci disabilitate), Home e Fine vanno a
/// inizio e fine, Invio sceglie, Esc chiude, Tab chiude e prosegue.
class KaamosMenu extends StatefulWidget {
  /// Crea un menu.
  const KaamosMenu({
    super.key,
    required this.items,
    required this.builder,
    this.semanticLabel,
  });

  /// Le voci, in ordine.
  final List<KaamosMenuEntry> items;

  /// L'ancora: chiama `overlay.toggle()` per aprire e chiudere.
  final KaamosOverlayAnchorBuilder builder;

  /// Nome del menu per gli screen reader ("Azioni sul file").
  final String? semanticLabel;

  @override
  State<KaamosMenu> createState() => _KaamosMenuState();
}

class _KaamosMenuState extends State<KaamosMenu> {
  final OverlayPortalController _controller = OverlayPortalController();
  // Un FocusNode per voce, così le frecce possono spostare il focus.
  final List<FocusNode> _nodes = [];
  // Il focus da restituire alla chiusura (di solito il bottone).
  FocusNode? _returnFocus;

  List<KaamosMenuItem> get _items =>
      widget.items.whereType<KaamosMenuItem>().toList(growable: false);

  void _syncNodes() {
    final count = _items.length;
    while (_nodes.length > count) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < count) {
      _nodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _open() {
    _returnFocus = FocusManager.instance.primaryFocus;
    _controller.show();
    // Dopo il primo frame le voci esistono: diamo il focus alla prima attiva.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusEdge(first: true));
  }

  void _close({bool restoreFocus = true}) {
    if (!_controller.isShowing) return;
    _controller.hide();
    if (restoreFocus) _returnFocus?.requestFocus();
  }

  void _toggle() => _controller.isShowing ? _close() : _open();

  int get _current => _nodes.indexWhere((n) => n.hasFocus);

  void _focusEdge({required bool first}) {
    final items = _items;
    final order = first
        ? List.generate(items.length, (i) => i)
        : List.generate(items.length, (i) => items.length - 1 - i);
    for (final i in order) {
      if (items[i].onPressed != null) return _nodes[i].requestFocus();
    }
  }

  void _move(int delta) {
    final items = _items;
    if (items.isEmpty) return;
    var i = _current;
    if (i < 0) return _focusEdge(first: delta > 0);
    for (var step = 0; step < items.length; step++) {
      i = (i + delta) % items.length;
      if (items[i].onPressed != null) return _nodes[i].requestFocus();
    }
  }

  void _choose(KaamosMenuItem item) {
    _close();
    item.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final anchor = _AnchorController(_controller, _toggle);
    return KaamosAnchoredOverlay(
      controller: _controller,
      onDismiss: () => _close(restoreFocus: false),
      overlayBuilder: _buildMenu,
      child: widget.builder(context, anchor),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = KaamosTheme.of(context);
    var index = 0;
    final children = <Widget>[];
    for (final entry in widget.items) {
      switch (entry) {
        case KaamosMenuItem():
          final node = _nodes[index++];
          children.add(
            KaamosListRow(
              focusNode: node,
              onPressed: entry.onPressed == null ? null : () => _choose(entry),
              leading: entry.leading,
              trailing: entry.trailing,
              child: Text(entry.label),
            ),
          );
        case KaamosMenuDivider():
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child:
                  SizedBox(height: 1, child: ColoredBox(color: theme.hairline)),
            ),
          );
      }
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.home): () =>
            _focusEdge(first: true),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            _focusEdge(first: false),
        const SingleActivator(LogicalKeyboardKey.escape): _close,
        // Tab: chiude e lascia proseguire il focus dal bottone.
        const SingleActivator(LogicalKeyboardKey.tab): () {
          _close();
          FocusManager.instance.primaryFocus?.nextFocus();
        },
        const SingleActivator(LogicalKeyboardKey.tab, shift: true): () {
          _close();
          FocusManager.instance.primaryFocus?.previousFocus();
        },
      },
      child: Semantics(
        label: widget.semanticLabel,
        explicitChildNodes: true,
        child: FocusScope(
          child: ConstrainedBox(
            // min-w-48 del web.
            constraints: const BoxConstraints(minWidth: 192),
            child: KaamosPopoverSurface(
              child: IntrinsicWidth(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Il `toggle()` passa dal menu, così all'apertura il focus va sulla
/// prima voce.
class _AnchorController implements KaamosOverlayHandle {
  _AnchorController(this._inner, this._toggle);

  final OverlayPortalController _inner;
  final VoidCallback _toggle;

  @override
  void toggle() => _toggle();

  @override
  void show() {
    if (!_inner.isShowing) _toggle();
  }

  @override
  void hide() {
    if (_inner.isShowing) _toggle();
  }

  @override
  bool get isShowing => _inner.isShowing;
}
