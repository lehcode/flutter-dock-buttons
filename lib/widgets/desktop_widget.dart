import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:dock_animate/models/dock_button.dart';

class DesktopWidget extends StatefulWidget {
  final Widget child;

  const DesktopWidget({
    super.key,
    required this.child,
    // required this.onButtonDropped,
  });

  @override
  State<DesktopWidget> createState() => _DesktopWidgetState();
}

class _DesktopWidgetState extends State<DesktopWidget> {
  /// The `_isDisposed` boolean variable in the `_DesktopWidgetState` class is used to keep track
  /// of whether the state object has been disposed or not. When the `dispose()` method is called,
  /// `_isDisposed` is set to `true`, indicating that the state object has been disposed. This flag
  /// is then checked in the `setState()` method override to prevent any state updates from being
  /// performed on a disposed state object.
  bool _isDisposed = false;
  /// `droppedIcons` is a list that keeps track of the icons that have been dropped
  /// onto the desktop in the `DesktopWidget` class. Each `_DesktopIcon` object in
  /// the list represents a button that has been dropped, along with its position on
  /// the desktop. The `droppedIcons` list is updated whenever a button is dropped
  /// outside the dock area, and the desktop is re-rendered to display these dropped
  /// icons using `_DesktopIconWidget`.
  List<_DesktopIcon> droppedIcons = [];
  
  

  @override
  // Modify state updates to check disposed flag
  /// Overrides the default [setState] to ensure that state updates are only
  /// performed if the widget is not disposed and is still mounted. This prevents
  /// attempting to update the state of a disposed widget, which can lead to
  /// errors. The provided [fn] callback is executed if conditions are met.
  void setState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      super.setState(fn);
    }
  }

  @override
  /// Overrides the default [dispose] method to set the `_isDisposed` flag to
  /// `true` before calling the superclass implementation. This ensures that the
  /// widget is marked as disposed, even if the superclass implementation does not
  /// call [State.dispose]. This flag is then checked in the [setState] override
  /// to prevent any state updates from being performed on a disposed widget.
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  /// Builds the desktop widget.
  ///
  /// This widget displays the desktop background and renders all the icons
  /// that have been dropped onto the desktop. It also handles the drag and
  /// drop events for dropping icons onto the desktop. The widget is a
  /// [DragTarget] that accepts [DockButton] objects as data. When an icon
  /// is dropped onto the desktop, it is added to the list of dropped icons
  /// and the desktop is re-rendered to display the new icon. The icons are
  /// rendered at the position where they were dropped, and are displayed on
  /// top of the desktop background.
  ///
  /// The widget also renders the child widget provided by the user, which is
  /// typically the dock. The child widget is rendered at the top of the stack,
  /// below the dropped icons.
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
            });
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              widget.child,
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
