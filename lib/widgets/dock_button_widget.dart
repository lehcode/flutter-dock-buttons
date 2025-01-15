import 'package:flutter/material.dart';
import 'package:dock_animate/models/dock_button.dart';

class DockButtonWidget extends StatefulWidget {
  final DockButton button;
  final double width;
  final double height;
  final double scale;

  const DockButtonWidget({
    super.key,
    required this.button,
    required this.width,
    required this.height,
    this.scale = 1.0,
  });

  @override
  State<DockButtonWidget> createState() => _DockButtonWidgetState();
}

class _DockButtonWidgetState extends State<DockButtonWidget> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Draggable<DockButton>(
      data: widget.button,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.button.color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.button.color.withAlpha(100),
              width: 1,
            ),
          ),
        ),
      ),
      onDragStarted: () => setState(() => _isDragging = true),
      onDragEnd: (details) => setState(() => _isDragging = false),
      onDragCompleted: () => setState(() => _isDragging = false),
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
                width: widget.width,
                height: widget.height,
                margin: EdgeInsets.only(bottom: _isPressed ? 0 : 2),
                decoration: BoxDecoration(
                  color: _isPressed 
                      ? widget.button.color.withAlpha(200)
                      : widget.button.color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: null,
                ),
                child: Icon(
                  widget.button.icon,
                  color: Colors.white,
                  size: 24 * widget.scale,
                ),
              ),
              if (_isHovered && !_isDragging)
                Positioned(
                  bottom: -28,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(240),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.button.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    ));
  }
}