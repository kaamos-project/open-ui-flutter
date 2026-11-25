import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';
import 'editable.dart';

/// Campo di testo su una riga (text-input del DESIGN.md).
///
/// Alto 36px, sfondo `surfaceElevated`, bordo `hairline` che al focus
/// diventa `hairlineStrong`: una leggera schiarita, non un anello colorato.
///
/// ```dart
/// final email = TextEditingController();
///
/// KaamosTextField(
///   controller: email,
///   placeholder: 'tu@esempio.org',
///   semanticLabel: 'Email',
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class KaamosTextField extends StatelessWidget {
  /// Crea un campo di testo.
  const KaamosTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.semanticLabel,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.invalid = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
  });

  /// Il testo del campo: leggilo con `controller.text`.
  final TextEditingController? controller;

  /// Per dare o togliere il focus da codice.
  final FocusNode? focusNode;

  /// Testo grigio quando il campo è vuoto. Non è un'etichetta: sparisce
  /// quando scrivi. Usa anche [semanticLabel] o un'etichetta visibile.
  final String? placeholder;

  /// Etichetta per gli screen reader.
  final String? semanticLabel;

  /// Se falso il campo è grigio e non prende il focus.
  final bool enabled;

  /// Si può selezionare e copiare ma non modificare.
  final bool readOnly;

  /// Nasconde il testo (password).
  final bool obscureText;

  /// Bordo rosso: il valore non è valido.
  final bool invalid;

  /// Prende il focus appena compare.
  final bool autofocus;

  /// Che tastiera mostrare su mobile (email, numeri, URL...).
  final TextInputType? keyboardType;

  /// Il tasto azione della tastiera mobile.
  final TextInputAction? textInputAction;

  /// A ogni modifica del testo.
  final ValueChanged<String>? onChanged;

  /// Quando l'utente preme Invio.
  final ValueChanged<String>? onSubmitted;

  /// Numero massimo di caratteri.
  final int? maxLength;

  /// Filtri sul testo (es. `FilteringTextInputFormatter.digitsOnly`).
  final List<TextInputFormatter>? inputFormatters;

  /// Suggerimenti per l'autofill (es. `AutofillHints.email`).
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return KaamosEditable(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      semanticLabel: semanticLabel,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      inputFormatters: [
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ...?inputFormatters,
      ],
      frameBuilder: (context, field, focused) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surfaceElevated,
          border: Border.all(
            color: kaamosFieldBorderColor(
              theme,
              focused: focused,
              invalid: invalid,
            ),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(KaamosRadius.md),
          ),
        ),
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(alignment: Alignment.centerLeft, child: field),
          ),
        ),
      ),
    );
  }
}
