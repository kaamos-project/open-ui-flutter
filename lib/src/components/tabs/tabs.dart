import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'pill_tab.dart';

/// Divide un contenuto in sezioni, mostrandone una alla volta (kaamos-tabs).
/// Le tab hanno l'aspetto delle [KaamosPillTab].
///
/// ```dart
/// KaamosTabs(
///   semanticLabel: 'Impostazioni account',
///   labels: const ['Generale', 'Account', 'Privacy'],
///   panels: const [GeneralPanel(), AccountPanel(), PrivacyPanel()],
/// )
/// ```
///
/// Tastiera: Tab entra nella tab attiva e il Tab successivo va nel pannello
/// (solo la tab attiva è nell'ordine del Tab, "roving focus"). ← → cambiano
/// tab girando in tondo e la attivano subito; Home e Fine vanno alla prima e
/// all'ultima.
///
/// Trade-off: si costruisce solo il pannello visibile. È più leggero di un
/// `IndexedStack` (che li tiene tutti vivi), ma cambiando tab lo stato del
/// pannello lasciato (scroll, testo non salvato) si perde. Se ti serve
/// tenerlo, salvalo fuori dal pannello.
class KaamosTabs extends StatefulWidget {
  /// Crea un gruppo di tab. [labels] e [panels] vanno nello stesso ordine.
  const KaamosTabs({
    super.key,
    required this.labels,
    required this.panels,
    this.initialIndex = 0,
    this.onChanged,
    this.semanticLabel,
    this.spacing = 16,
  });

  /// I testi delle tab.
  final List<String> labels;

  /// I pannelli, uno per tab.
  final List<Widget> panels;

  /// La tab attiva all'inizio.
  final int initialIndex;

  /// Quando l'utente cambia tab.
  final ValueChanged<int>? onChanged;

  /// Descrive il gruppo per gli screen reader.
  final String? semanticLabel;

  /// Spazio tra le tab e il pannello.
  final double spacing;

  @override
  State<KaamosTabs> createState() => _KaamosTabsState();
}

class _KaamosTabsState extends State<KaamosTabs> {
  late int _index = widget.initialIndex.clamp(0, widget.labels.length - 1);
  final List<FocusNode> _nodes = [];

  void _syncNodes() {
    while (_nodes.length > widget.labels.length) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < widget.labels.length) {
      _nodes.add(FocusNode());
    }
    for (var i = 0; i < _nodes.length; i++) {
      // Roving focus: con Tab si raggiunge solo la tab attiva.
      _nodes[i].skipTraversal = i != _index;
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _select(int index, {bool focus = false}) {
    final n = widget.labels.length;
    final i = index % n;
    if (i != _index) {
      setState(() => _index = i);
      widget.onChanged?.call(i);
    }
    if (focus) _nodes[i].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Qui e non nel costruttore: un assert su .length impedirebbe `const`.
    assert(widget.labels.length == widget.panels.length);
    _syncNodes();
    final last = widget.labels.length - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: widget.spacing,
      children: [
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                _select(_index + 1, focus: true),
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                _select(_index - 1 + widget.labels.length, focus: true),
            const SingleActivator(LogicalKeyboardKey.home): () =>
                _select(0, focus: true),
            const SingleActivator(LogicalKeyboardKey.end): () =>
                _select(last, focus: true),
          },
          child: Semantics(
            label: widget.semanticLabel,
            explicitChildNodes: true,
            child: SingleChildScrollView(
              // Su schermi stretti le tab scorrono invece di andare a capo.
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 4,
                children: [
                  for (var i = 0; i <= last; i++)
                    KaamosPillTab(
                      label: widget.labels[i],
                      selected: i == _index,
                      asTab: true,
                      focusNode: _nodes[i],
                      onPressed: () => _select(i),
                    ),
                ],
              ),
            ),
          ),
        ),
        // KeyedSubtree: cambiando tab Flutter crea un pannello nuovo invece
        // di riciclare quello vecchio con dati sbagliati.
        KeyedSubtree(
          key: ValueKey<int>(_index),
          child: widget.panels[_index],
        ),
      ],
    );
  }
}
