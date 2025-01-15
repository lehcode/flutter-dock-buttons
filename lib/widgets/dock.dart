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
    this.itemBaseWidth = 64.0,
    this.itemBaseHeight = 64.0,
    this.maxScale = 1.3,
    this.spacing = 23.0,
    this.backgroundOpacity = 0.1,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(15),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: MouseRegion(
        onHover: _updateMousePosition,
        onExit: (_) => setState(() => _mousePosition = null),
        child: Container(
          key: _dockKey,
          constraints: BoxConstraints(
            minHeight: widget.itemBaseHeight * widget.maxScale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
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
      double yOffset = 0.0;
      if (_mousePosition != null && dockPosition != null) {
        final hoveredIndex =
            _getHoveredButtonIndex(_mousePosition!, dockPosition);
        if (hoveredIndex != -1) {
          final distance = (i - hoveredIndex).abs();
          if (distance <= 2) {
            if (distance == 0) {
              scale = widget.maxScale;
              yOffset =
                  -(widget.itemBaseHeight * (widget.maxScale - 1.0)) + 6.0;
            } else if (distance == 1) {
              scale = 1.0 + (widget.maxScale - 1.0) * 0.6;
              yOffset = -(widget.itemBaseHeight * (scale - 1.0));
            } else if (distance == 2) {
              scale = 1.0 + (widget.maxScale - 1.0) * 0.3;
              yOffset = -(widget.itemBaseHeight * (scale - 1.0));
            }
          }
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
              tween: Tween(begin: 0.0, end: yOffset),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCirc,
              builder: (context, animatedOffset, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: scale),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCirc,
                  builder: (context, animatedScale, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..translate(0.0, animatedOffset)
                        ..scale(animatedScale),
                      alignment: Alignment.bottomCenter,
                      child: DockButtonWidget(
                        button: _currentButtons[i],
                        scale: animatedScale,
                      ),
                    );
                  },
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

  int _getHoveredButtonIndex(Offset mousePosition, Offset dockPosition) {
    final buttonWidth = widget.itemBaseWidth;
    final totalButtonWidth = buttonWidth + widget.spacing;

    for (int i = 0; i < _currentButtons.length; i++) {
      final buttonStart = dockPosition.dx + 16.0 + (i * totalButtonWidth);
      final buttonEnd = buttonStart + buttonWidth;

      if (mousePosition.dx >= buttonStart && mousePosition.dx <= buttonEnd) {
        return i;
      }
    }
    return -1;
  }
}
