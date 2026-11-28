import 'package:flutter/widgets.dart';
import 'package:kaamos_design_tokens/kaamos_design_tokens.dart';

import '../../foundation/focus_ring.dart';
import '../../foundation/icons.dart';
import '../../foundation/pressable.dart';
import '../../foundation/theme.dart';
import '../drawer/drawer.dart';

/// Un link della navigazione principale.
class KaamosNavItem {
  /// Crea un link.
  const KaamosNavItem({
    required this.label,
    required this.onPressed,
    this.current = false,
  });

  /// Il testo del link.
  final String label;

  /// Cosa fare al clic (di solito navigare a una pagina).
  final VoidCallback onPressed;

  /// È la pagina in cui sei (`aria-current="page"` sul web).
  final bool current;
}

/// La larghezza sotto cui la barra passa alla versione mobile (768px, il
/// breakpoint `md` di Tailwind usato da open-ui-web).
const double kaamosNavBreakpoint = 768;

/// Barra di navigazione in alto (kaamos-nav): 56px, logo a sinistra, link al
/// centro, azioni a destra.
///
/// Sotto i 768px i link finiscono in un cassetto che entra da sinistra,
/// aperto dal bottone hamburger, e le [secondaryActions] spariscono.
///
/// ```dart
/// KaamosNavBar(
///   brand: const Text('Kaamos'),
///   items: [
///     KaamosNavItem(label: 'Home', onPressed: goHome, current: true),
///     KaamosNavItem(label: 'Mail', onPressed: goMail),
///   ],
///   secondaryActions: [KaamosLink(label: 'Accedi', onPressed: login)],
///   actions: [KaamosButton(onPressed: download, child: const Text('Download'))],
/// )
/// ```
class KaamosNavBar extends StatelessWidget {
  /// Crea la barra.
  const KaamosNavBar({
    super.key,
    required this.brand,
    this.items = const [],
    this.actions = const [],
    this.secondaryActions = const [],
    this.menuLabel = 'Open menu',
  });

  /// Il logo o il nome dell'app.
  final Widget brand;

  /// I link di navigazione.
  final List<KaamosNavItem> items;

  /// Azioni sempre visibili a destra (es. il bottone "Download").
  final List<Widget> actions;

  /// Azioni visibili solo su schermi larghi (es. "Accedi").
  final List<Widget> secondaryActions;

  /// Etichetta per gli screen reader del bottone hamburger.
  final String menuLabel;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    // sizeOf invece di MediaQuery.of: ricostruisce solo se cambia la misura,
    // non se compare la tastiera o cambia la luminosità.
    final wide = MediaQuery.sizeOf(context).width >= kaamosNavBreakpoint;

    final brandWidget = DefaultTextStyle(
      style: KaamosTypography.bodyStrong.copyWith(color: theme.ink),
      maxLines: 1,
      child: brand,
    );

    final Widget content;
    if (wide) {
      content = Row(
        spacing: 32,
        children: [
          brandWidget,
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [for (final i in items) _NavLink(item: i)],
            ),
          ),
          Row(spacing: 12, children: [...secondaryActions, ...actions]),
        ],
      );
    } else {
      content = Row(
        spacing: 16,
        children: [
          if (items.isNotEmpty)
            _MenuToggle(
              label: menuLabel,
              onPressed: () =>
                  showKaamosNavDrawer(context: context, items: items),
            ),
          Expanded(child: Center(child: brandWidget)),
          Row(spacing: 12, children: actions),
        ],
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.canvas,
          border: Border(bottom: BorderSide(color: theme.hairline)),
        ),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Apre il cassetto di navigazione da sinistra. Lo usa [KaamosNavBar] su
/// mobile, ma puoi chiamarlo anche tu.
///
/// È una route (come il dialog): il tasto indietro di Android lo chiude e il
/// focus resta dentro finché è aperto.
Future<void> showKaamosNavDrawer({
  required BuildContext context,
  required List<KaamosNavItem> items,
  String barrierLabel = 'Close menu',
}) =>
    showKaamosDrawer<void>(
      context: context,
      barrierLabel: barrierLabel,
      builder: (context) => _DrawerLinks(items: items),
    );

class _DrawerLinks extends StatelessWidget {
  const _DrawerLinks({required this.items});

  final List<KaamosNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          for (final i in items)
            _NavLink(
              item: i,
              vertical: 8,
              onPressed: () {
                Navigator.of(context).pop();
                i.onPressed();
              },
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.item, this.vertical = 6, this.onPressed});

  final KaamosNavItem item;
  final double vertical;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return Semantics(
      selected: item.current,
      child: KaamosPressable(
        onPressed: onPressed ?? item.onPressed,
        isButton: false,
        isLink: true,
        builder: (context, states) {
          final strong = item.current || states.contains(WidgetState.hovered);
          return KaamosFocusRing(
            visible: states.contains(WidgetState.focused),
            color: theme.focusRing,
            borderRadius: KaamosRadius.sm,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: vertical),
              child: Text(
                item.label,
                maxLines: 1,
                style: KaamosTypography.bodySmStrong.copyWith(
                  color: strong ? theme.onDark : theme.onDarkMute,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuToggle extends StatelessWidget {
  const _MenuToggle({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = KaamosTheme.of(context);
    return KaamosPressable(
      onPressed: onPressed,
      semanticLabel: label,
      builder: (context, states) => KaamosFocusRing(
        visible: states.contains(WidgetState.focused),
        color: theme.focusRing,
        borderRadius: KaamosRadius.md,
        child: SizedBox.square(
          dimension: 36,
          child:
              Center(child: KaamosIcon(KaamosIcons.menu, color: theme.onDark)),
        ),
      ),
    );
  }
}
