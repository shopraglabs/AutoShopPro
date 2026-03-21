import 'package:flutter/cupertino.dart';

// ─── Public API ───────────────────────────────────────────────────────────────

/// One action in a context menu.
/// Set [isDestructive] for delete-style actions (renders in red).
/// Pass [onTap] = null to render the item grayed/disabled.
class ContextMenuAction {
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ContextMenuAction({
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.onTap,
  });
}

/// A horizontal separator line between groups of menu items.
/// Pass [null] in the [items] list to insert one.
const ContextMenuAction contextMenuDivider = ContextMenuAction(label: '\x00');

/// Shows a macOS-style context menu at [position] (global coordinates).
/// Pass [null] between [ContextMenuAction]s to insert a separator.
void showContextMenu({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuAction> items,
}) {
  _dismissActive();
  final overlay = Overlay.of(context, rootOverlay: true);
  _activeEntry = OverlayEntry(
    builder: (_) => _ContextMenuOverlay(
      position: position,
      items: items,
      onDismiss: _dismissActive,
    ),
  );
  overlay.insert(_activeEntry!);
}

// ─── Internal state ───────────────────────────────────────────────────────────

OverlayEntry? _activeEntry;

void _dismissActive() {
  _activeEntry?.remove();
  _activeEntry = null;
}

// ─── Overlay ──────────────────────────────────────────────────────────────────

class _ContextMenuOverlay extends StatelessWidget {
  final Offset position;
  final List<ContextMenuAction> items;
  final VoidCallback onDismiss;

  const _ContextMenuOverlay({
    required this.position,
    required this.items,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    const menuWidth = 230.0;
    // Estimate height: 28px per item, 9px per separator, 10px vertical padding
    final menuHeight = items.fold(
          0.0,
          (h, item) => h + (item.label == '\x00' ? 9.0 : 28.0),
        ) +
        10.0;

    // Keep menu on screen
    final left = (position.dx + menuWidth > screen.width - 8)
        ? screen.width - menuWidth - 8
        : position.dx;
    final top = (position.dy + menuHeight > screen.height - 8)
        ? screen.height - menuHeight - 8
        : position.dy;

    return Stack(
      children: [
        // Full-screen invisible tap target to dismiss on click-away
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            onSecondaryTap: onDismiss,
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: _ContextMenuCard(items: items, onDismiss: onDismiss),
        ),
      ],
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ContextMenuCard extends StatelessWidget {
  final List<ContextMenuAction> items;
  final VoidCallback onDismiss;

  const _ContextMenuCard({required this.items, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        // macOS context menu uses a slightly warm off-white / light gray
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCCCCCC), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.map((item) {
            if (item.label == '\x00') {
              // Separator
              return Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: const Color(0xFFD4D4D4),
              );
            }
            return _ContextMenuRow(action: item, onDismiss: onDismiss);
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Row ──────────────────────────────────────────────────────────────────────

class _ContextMenuRow extends StatefulWidget {
  final ContextMenuAction action;
  final VoidCallback onDismiss;

  const _ContextMenuRow({required this.action, required this.onDismiss});

  @override
  State<_ContextMenuRow> createState() => _ContextMenuRowState();
}

class _ContextMenuRowState extends State<_ContextMenuRow> {
  bool _hovered = false;

  bool get _enabled => widget.action.onTap != null;

  @override
  Widget build(BuildContext context) {
    final fg = _hovered && _enabled
        ? CupertinoColors.white
        : widget.action.isDestructive
            ? const Color(0xFFFF3B30)
            : _enabled
                ? const Color(0xFF1C1C1E)
                : const Color(0xFFAEAEB2);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _enabled
            ? () {
                widget.onDismiss();
                widget.action.onTap!();
              }
            : null,
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: _hovered && _enabled
                ? const Color(0xFF0063DA) // macOS selection blue
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (widget.action.icon != null) ...[
                Icon(widget.action.icon, size: 13, color: fg),
                const SizedBox(width: 7),
              ],
              Expanded(
                child: Text(
                  widget.action.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: fg,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
