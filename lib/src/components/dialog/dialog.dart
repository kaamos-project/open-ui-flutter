import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/theme.dart';

/// Apre un dialog modale e aspetta la risposta.
///
/// ```dart
/// final ok = await showKaamosDialog<bool>(
///   context: context,
///   builder: (context) => KaamosDialog(
///     title: 'Eliminare il file?',
///     content: const Text('Potrai recuperarlo dal cestino per 30 giorni.'),
///     actions: [
///       KaamosButton(
///         variant: KaamosButtonVariant.secondary,
///         onPressed: () => Navigator.pop(context, false),
///         child: const Text('Annulla'),
///       ),
///       KaamosButton(
///         onPressed: () => Navigator.pop(context, true),
///         child: const Text('Elimina'),
///       ),
///     ],
///   ),
/// );
/// if (ok ?? false) deleteFile();
/// ```
///
/// Perché una *route* del Navigator e non un overlay come il menu? Una route
/// ci dà gratis tre cose che un dialog deve avere: il tasto "indietro" di
/// Android lo chiude, il focus resta intrappolato dentro (Tab non esce sulla
/// pagina sotto), e la pagina sotto non riceve clic. In più `await` restituisce
/// la scelta, come `dialog.returnValue` sul web.
///
/// Esc o un clic sul velo chiudono il dialog con `null`, a meno che
/// [barrierDismissible] sia falso.
Future<T?> showKaamosDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Close',
}) {
  final theme = KaamosTheme.of(context);
  return Navigator.of(context).push<T>(
    RawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: theme.scrim,
      transitionDuration: KaamosDuration.normal,
      // La pagina del dialog vive nell'Overlay del Navigator, fuori dal
      // sottoalbero di chi lo apre: riportiamo il tema a mano.
      pageBuilder: (context, animation, secondaryAnimation) =>
          KaamosTheme(data: theme, child: Builder(builder: builder)),
      // Una dissolvenza breve. FadeTransition costa un livello di disegno in
      // più, ma solo per i 200ms dell'animazione.
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: KaamosEasing.out),
        child: child,
      ),
    ),
  );
}

/// La cornice di un dialog (kaamos-dialog): `surface`, bordo `hairline`,
/// raggio 10px, padding 24px, largo al massimo 448px.
class KaamosDialog extends StatelessWidget {
  /// Crea un dialog con un titolo, un contenuto e i bottoni.
  const KaamosDialog({
    super.key,
    required this.title,
    this.content,
    this.actions = const [],
  });

  /// Il titolo: è anche il nome del dialog per gli screen reader.
  final String title;

  /// Il testo o i controlli del dialog.
  final Widget? content;

  /// I bottoni, allineati a destra. Un solo `primary`: l'azione principale.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Center(
      child: Padding(
        // w-[calc(100%-2rem)]: 16px dai bordi dello schermo.
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(color: theme.hairline),
                borderRadius: const BorderRadius.all(
                  Radius.circular(KaamosRadius.lg),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: DefaultTextStyle(
                  style: KaamosTypography.bodyMd.copyWith(color: theme.body),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        title,
                        style: KaamosTypography.headingSm.copyWith(
                          color: theme.ink,
                        ),
                      ),
                      if (content != null) Flexible(child: content!),
                      if (actions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 12,
                            children: actions,
                          ),
                        ),
                    ],
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
