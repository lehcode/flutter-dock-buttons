import 'package:flutter/material.dart';
import 'package:dock_animate/models/dock_button.dart';

const buttonSize = 64.0;

class DockButtonWidget extends StatefulWidget {
  final DockButton button;
  final double scale;

  const DockButtonWidget({
    super.key,
    required this.button,
    this.scale = 1.0,
  });

  double get width => buttonSize * scale;
  double get height => buttonSize * scale;

  @override
  State<DockButtonWidget> createState() => _DockButtonWidgetState();
}

class _DockButtonWidgetState extends State<DockButtonWidget> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isDragging = false;
  Offset? _dragStartPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _dragStartPosition = details.localPosition;
      },
      onPanUpdate: (details) {
        if (_dragStartPosition != null) {
          final distance = (_dragStartPosition! - details.localPosition).distance;
          if (distance > 10.0) {
            setState(() => _isDragging = true);
          }
        }
      },
      onPanEnd: (_) {
        setState(() {
          _isDragging = false;
          _dragStartPosition = null;
        });
      },
      child: Draggable<DockButton>(
        data: widget.button,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.button.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.button.icon,
              color: Colors.white,
              size: 24 * widget.scale,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.button.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        onDragStarted: () => setState(() => _isDragging = true),
        onDragEnd: (details) => setState(() {
          _isDragging = false;
          _dragStartPosition = null;
        }),
        onDragCompleted: () => setState(() {
          _isDragging = false;
          _dragStartPosition = null;
        }),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          margin: EdgeInsets.only(bottom: _isPressed ? 0 : 2),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() {
              _isHovered = false;
              _isPressed = false;
            }),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.button.onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: _isPressed
                          ? widget.button.color.withOpacity(0.8)
                          : widget.button.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.button.icon,
                      color: Colors.white,
                      size: 24 * widget.scale,
                    ),
                  ),
                  if (_isHovered && !_isDragging)
                    Positioned(
                      bottom: -32,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.button.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}