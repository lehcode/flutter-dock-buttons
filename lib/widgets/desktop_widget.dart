import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:dock_animate/models/dock_button.dart';

class DesktopWidget extends StatefulWidget {
  final Widget child;
  final Function(DockButton) onButtonDropped;

  const DesktopWidget({
    super.key,
    required this.child,
    required this.onButtonDropped,
  });

  @override
  State<DesktopWidget> createState() => _DesktopWidgetState();
}

class _DesktopWidgetState extends State<DesktopWidget> {
  List<_DesktopIcon> droppedIcons = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8E2DE2),
            Color(0xFF4A00E0),
          ],
        ),
      ),
      child: DragTarget<DockButton>(
        onWillAccept: (data) => data != null,
        onAcceptWithDetails: (details) {
          final DockButton button = details.data;
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.offset);

          // Get dock bounds
          final dockBox = context.findRenderObject() as RenderBox;
          final dockGlobalPosition = dockBox.localToGlobal(Offset.zero);
          final dockRect = Rect.fromLTWH(dockGlobalPosition.dx,
              dockGlobalPosition.dy, dockBox.size.width, dockBox.size.height);

          // Only add to desktop if dropped outside dock
          if (!dockRect.contains(details.offset)) {
            setState(() {
              droppedIcons.add(
                _DesktopIcon(
                  button: button,
                  position: localPosition,
                ),
              );
              widget.onButtonDropped(button);
            });
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              widget.child,
              // if (candidateData.isNotEmpty)
              //   Container(
              //     color: Colors.white.withOpacity(0.1),
              //     child: const Center(
              //       child: Text(
              //         'Drop here to add to desktop',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 24,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              ...droppedIcons.map((icon) => Positioned(
                    left: icon.position.dx - 32,
                    top: icon.position.dy - 32,
                    child: _DesktopIconWidget(icon: icon),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopIcon {
  final DockButton button;
  final Offset position;

  _DesktopIcon({
    required this.button,
    required this.position,
  });
}

class _DesktopIconWidget extends StatefulWidget {
  final _DesktopIcon icon;

  const _DesktopIconWidget({
    required this.icon,
  });

  @override
  State<_DesktopIconWidget> createState() => _DesktopIconWidgetState();
}

class _DesktopIconWidgetState extends State<_DesktopIconWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              _isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.icon.button.color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon.button.icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.icon.button.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
