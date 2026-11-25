import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/icons.dart';
import '../../foundation/theme.dart';
import 'editable.dart';

/// Campo di ricerca con la lente a sinistra (store-search-bar del DESIGN.md).
///
/// Più alto del text field (44px), senza bordo finché non ha il focus.
/// Esc svuota il campo; su mobile la tastiera mostra il tasto "Cerca".
///
/// ```dart
/// KaamosSearchBar(
///   placeholder: 'Search...',
///   semanticLabel: 'Cerca estensioni',
///   onSubmitted: (q) => search(q),
/// )
/// ```
class KaamosSearchBar extends StatefulWidget {
  /// Crea una barra di ricerca.
  const KaamosSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.semanticLabel,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
  });

  /// Il testo cercato.
  final TextEditingController? controller;

  /// Per dare il focus da codice (es. con una scorciatoia Ctrl+K).
  final FocusNode? focusNode;

  /// Testo grigio quando il campo è vuoto.
  final String? placeholder;

  /// Etichetta per gli screen reader: dalla sempre, il placeholder non basta.
  final String? semanticLabel;

  /// Se falso il campo è grigio e non prende il focus.
  final bool enabled;

  /// Prende il focus appena compare.
  final bool autofocus;

  /// A ogni modifica: per filtrare mentre scrivi.
  final ValueChanged<String>? onChanged;

  /// Quando l'utente preme Invio o "Cerca".
  final ValueChanged<String>? onSubmitted;

  /// A destra: per esempio i keycap della scorciatoia.
  final Widget? trailing;

  @override
  State<KaamosSearchBar> createState() => _KaamosSearchBarState();
}

class _KaamosSearchBarState extends State<KaamosSearchBar> {
  TextEditingController? _own;
  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _clear() {
    if (_controller.text.isEmpty) return;
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    // CallbackShortcuts: Esc funziona solo quando il focus è qui dentro.
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _clear},
      child: KaamosEditable(
        controller: _controller,
        focusNode: widget.focusNode,
        placeholder: widget.placeholder,
        semanticLabel: widget.semanticLabel,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        frameBuilder: (context, field, focused) => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surfaceElevated,
            border: Border.all(
              color: kaamosFieldBorderColor(
                theme,
                focused: focused,
                invalid: false,
                idle: const Color(0x00000000),
              ),
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(KaamosRadius.md),
            ),
          ),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 12,
                children: [
                  KaamosIcon(KaamosIcons.search, color: theme.mute),
                  Expanded(child: field),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
