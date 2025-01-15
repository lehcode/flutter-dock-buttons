import 'package:flutter/material.dart';
import 'package:dock_animate/models/dock_button.dart';
import 'package:dock_animate/widgets/dock_button_widget.dart';
import 'package:flutter/gestures.dart';

class Dock extends StatefulWidget {
  final List<DockButton> buttons;
  final double itemBaseWidth;
  final double itemBaseHeight;
  final double maxScale;
  final double spacing;
  final double backgroundOpacity;

  const Dock({
    super.key,
    required this.buttons,
    this.itemBaseWidth = 48.0,
    this.itemBaseHeight = 48.0,
    this.maxScale = 1.8,
    this.spacing = 4.0,
    this.backgroundOpacity = 0.3,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> with SingleTickerProviderStateMixin {
  Offset? _mousePosition;
  final _dockKey = GlobalKey();
  int? _dragTargetIndex;
  List<DockButton> _currentButtons = [];

  @override
  void initState() {
    super.initState();
    _currentButtons = List.from(widget.buttons);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _updateMousePosition,
      onExit: (_) => setState(() => _mousePosition = null),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Container(
          key: _dockKey,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(20),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildDockItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDockItems() {
    final List<Widget> items = [];
    final dockBox = _dockKey.currentContext?.findRenderObject() as RenderBox?;
    final dockPosition = dockBox?.localToGlobal(Offset.zero);

    for (int i = 0; i < _currentButtons.length; i++) {
      if (i > 0) {
        items.add(SizedBox(width: widget.spacing));
      }

      double scale = 1.0;
      if (_mousePosition != null && dockPosition != null) {
        final itemCenter = dockPosition.dx +
            (i * (widget.itemBaseWidth + widget.spacing)) +
            widget.itemBaseWidth / 2;
        
        final distance = (_mousePosition!.dx - itemCenter).abs();
        final maxDistance = widget.itemBaseWidth * 2;

        if (distance < maxDistance) {
          scale = 1.0 +
              (widget.maxScale - 1.0) *
                  (1.0 - (distance / maxDistance));
        }
      }

      items.add(
        DragTarget<DockButton>(
          onWillAccept: (data) => data != null,
          onAccept: (data) {
            final fromIndex = _currentButtons.indexOf(data);
            final toIndex = i;
            if (fromIndex != -1) {
              setState(() {
                final button = _currentButtons.removeAt(fromIndex);
                _currentButtons.insert(toIndex, button);
              });
            }
          },
          onMove: (details) => setState(() => _dragTargetIndex = i),
          onLeave: (_) => setState(() => _dragTargetIndex = null),
          builder: (context, candidateData, rejectedData) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: scale),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: DockButtonWidget(
                    button: _currentButtons[i],
                    width: widget.itemBaseWidth,
                    height: widget.itemBaseHeight,
                    scale: scale,
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return items;
  }

  void _updateMousePosition(PointerHoverEvent event) {
    setState(() => _mousePosition = event.position);
  }
}