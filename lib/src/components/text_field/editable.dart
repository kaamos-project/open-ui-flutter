import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';
import 'context_menu.dart';
import 'selection_controls.dart';

/// Disegna la cornice attorno al campo: riceve il campo già pronto e se ha
/// il focus (per cambiare il colore del bordo).
typedef KaamosFieldFrameBuilder = Widget Function(
  BuildContext context,
  Widget field,
  bool focused,
);

/// Il cuore condiviso da [KaamosTextField] e [KaamosSearchBar].
///
/// Non è esportato: è il pezzo "difficile" che i campi pubblici riusano.
/// Mette insieme quattro mattoni del livello widgets di Flutter:
///
/// 1. [EditableText]: il motore del testo. Cursore, tastiera del sistema
///    (IME, emoji, dettatura), scorciatoie (Ctrl+C, Ctrl+Z), autofill e
///    accessibilità. Riscriverlo sarebbe un lavoro enorme.
/// 2. [TextSelectionGestureDetectorBuilder]: i gesti. Tap per spostare il
///    cursore, doppio tap per selezionare una parola, trascinare per
///    selezionare, tasto destro per il menu. Lo stesso che usa Material.
/// 3. [KaamosTextSelectionControls]: le maniglie di selezione su touch,
///    disegnate da noi (le uniche pronte sono Material o Cupertino).
/// 4. [KaamosTextContextMenu]: il menu Taglia/Copia/Incolla, disegnato da noi.
class KaamosEditable extends StatefulWidget {
  /// Crea il cuore di un campo di testo.
  const KaamosEditable({
    super.key,
    required this.frameBuilder,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.semanticLabel,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
    this.style,
  });

  /// Cornice attorno al campo.
  final KaamosFieldFrameBuilder frameBuilder;

  /// Il testo del campo. Se null il campo ne crea uno suo.
  final TextEditingController? controller;

  /// Il focus del campo. Se null il campo ne crea uno suo.
  final FocusNode? focusNode;

  /// Testo grigio mostrato quando il campo è vuoto.
  final String? placeholder;

  /// Etichetta per gli screen reader (il placeholder non lo è).
  final String? semanticLabel;

  /// Se falso il campo è grigio e non prende il focus.
  final bool enabled;

  /// Si può selezionare e copiare ma non modificare.
  final bool readOnly;

  /// Nasconde il testo (password).
  final bool obscureText;

  /// Prende il focus appena compare.
  final bool autofocus;

  /// Che tastiera mostrare su mobile.
  final TextInputType? keyboardType;

  /// Il tasto in basso a destra della tastiera (Invio, Cerca, Avanti...).
  final TextInputAction? textInputAction;

  /// A ogni modifica del testo.
  final ValueChanged<String>? onChanged;

  /// Quando l'utente preme Invio (o il tasto della tastiera mobile).
  final ValueChanged<String>? onSubmitted;

  /// Filtri sul testo inserito (es. lunghezza massima, solo cifre).
  final List<TextInputFormatter>? inputFormatters;

  /// Suggerimenti per l'autofill del sistema (email, password...).
  final Iterable<String>? autofillHints;

  /// Stile del testo. Default: body-md.
  final TextStyle? style;

  @override
  State<KaamosEditable> createState() => _KaamosEditableState();
}

class _KaamosEditableState extends State<KaamosEditable>
    implements TextSelectionGestureDetectorBuilderDelegate {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  bool _showSelectionHandles = false;
  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    _focusNode.canRequestFocus = widget.enabled;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(KaamosEditable old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
    _focusNode.canRequestFocus = widget.enabled;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  // Ricostruiamo al cambio di focus per cambiare il colore del bordo.
  void _onFocusChanged() => setState(() {});

  // Le maniglie compaiono solo quando servono: dopo un tocco o una pressione
  // lunga su touch, mai usando la tastiera o il mouse. Stessa logica del
  // TextField di Material, semplificata.
  void _onSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final show = _gestures.shouldShowSelectionHandles &&
        cause != SelectionChangedCause.keyboard &&
        widget.enabled &&
        !(widget.readOnly && selection.isCollapsed) &&
        (cause == SelectionChangedCause.longPress ||
            _controller.text.isNotEmpty);
    if (show != _showSelectionHandles) {
      setState(() => _showSelectionHandles = show);
    }
  }

  Widget? _placeholder(TextStyle style, KaamosThemeData theme) {
    final text = widget.placeholder;
    if (text == null) return null;
    // ValueListenableBuilder: quando scrivi si ricostruisce solo il
    // placeholder, non tutto il campo.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        if (value.text.isNotEmpty) return const SizedBox.shrink();
        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: theme.mute),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    final style = (widget.style ?? KaamosTypography.bodyMd).copyWith(
      color: widget.enabled ? theme.onDark : theme.disabledForeground,
    );
    final placeholder = _placeholder(style, theme);

    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focusNode,
      style: style,
      cursorColor: theme.cursor,
      backgroundCursorColor: theme.mute,
      selectionColor: theme.selection,
      cursorWidth: 1.5,
      cursorRadius: const Radius.circular(1),
      readOnly: widget.readOnly || !widget.enabled,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      // Il gesture builder gestisce i tocchi: l'EditableText non deve
      // rispondere da solo, altrimenti ogni tap verrebbe contato due volte.
      rendererIgnoresPointer: true,
      showSelectionHandles: _showSelectionHandles,
      selectionControls: kaamosTextSelectionControls,
      onSelectionChanged: _onSelectionChanged,
      contextMenuBuilder: _contextMenuBuilder,
      maxLines: 1,
      // Clicca fuori dal campo: perde il focus (come sul web).
      onTapOutside: (_) => _focusNode.unfocus(),
    );

    final field = Semantics(
      label: widget.semanticLabel,
      hint: widget.placeholder,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.text
            : SystemMouseCursors.forbidden,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: _gestures.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                if (placeholder != null)
                  // Il placeholder non deve ricevere tocchi né essere letto
                  // due volte: è già nel "hint" qui sopra.
                  IgnorePointer(child: ExcludeSemantics(child: placeholder)),
                editable,
              ],
            ),
          ),
        ),
      ),
    );

    return widget.frameBuilder(context, field, _focusNode.hasFocus);
  }

  // Sul web lasciamo il menu del browser: il nostro "Incolla" dovrebbe
  // chiedere il permesso di leggere gli appunti, quello del browser no.
  // È l'unica eccezione alla regola "niente UI di sistema".
  EditableTextContextMenuBuilder? get _contextMenuBuilder {
    if (kIsWeb && BrowserContextMenu.enabled) return null;
    return (context, state) => KaamosTextContextMenu(
          anchors: state.contextMenuAnchors,
          items: state.contextMenuButtonItems,
        );
  }
}

/// Il colore del bordo dei campi: usato da text field e search bar.
Color kaamosFieldBorderColor(
  KaamosThemeData theme, {
  required bool focused,
  required bool invalid,
  Color? idle,
}) {
  if (invalid) return theme.danger;
  if (focused) return theme.hairlineStrong;
  return idle ?? theme.hairline;
}
