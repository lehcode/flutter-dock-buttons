import 'package:flutter/material.dart';
import 'package:dock_animate/models/dock_button.dart';

const buttonSize = 64.0;

class DockButtonWidget extends StatefulWidget {
  final DockButton button;
  final double scale;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDraggableCanceled;
  final Function(Rect bounds)? onBoundsChanged;
  late final GlobalKey buttonKey;

  DockButtonWidget({
    super.key,
    required this.button,
    this.scale = 1.0,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragCompleted,
    this.onDraggableCanceled,
    this.onBoundsChanged,
  }) {
    buttonKey = GlobalKey();
  }

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
  bool _isDisposed = false;

  @override
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
  /// Disposes of the widget's state, clearing any drag-related states and
  /// resetting all internal state flags to their default values. Marks the
  /// widget as disposed to prevent further state updates. Always calls the
  /// superclass's dispose method to complete the disposal process.
  void dispose() {
    // Clear any drag related states
    _dragStartPosition = null;
    
    // Reset all state flags
    _isHovered = false;
    _isPressed = false;
    _isDragging = false;
    _isDisposed = true;
    
    super.dispose();
  }

  /// Updates the bounds of the button by getting the current render box and
  /// calling the [onBoundsChanged] callback with the new bounds. This method
  /// is only called if the widget is not disposed and is still mounted. If no
  /// render box is found, the method does nothing.
  void _updateBounds() {
    if (_isDisposed || !mounted) return;
    
    final RenderBox? renderBox =
        widget.buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final bounds = position & size;
      widget.onBoundsChanged?.call(bounds);
    }
  }

  @override
  /// Builds the dock button widget.
  ///
  /// This widget is a [Draggable] with a [GestureDetector] as its child. The
  /// [GestureDetector] handles tap events and updates the button's state
  /// accordingly. The button itself is a [Stack] with an [AnimatedContainer]
  /// as its first child and the button's icon as its second child. The
  /// [AnimatedContainer] is used to animate the button's size and color when
  /// it is pressed or hovered. The button's size is determined by the
  /// [DockButtonWidget.width] and [DockButtonWidget.height] properties.
  ///
  /// The widget also updates the button's bounds whenever its size changes by
  /// calling the [onBoundsChanged] callback with the new bounds. This method
  /// is only called if the widget is not disposed and is still mounted. If no
  /// render box is found, the method does nothing.
  ///
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateBounds();
        });

        return GestureDetector(
          onPanStart: (details) {
            _dragStartPosition = details.localPosition;
          },
          onPanUpdate: (details) {
            if (_dragStartPosition != null) {
              final distance =
                  (_dragStartPosition! - details.localPosition).distance;
              if (distance > 10.0) {
                setState(() => _isDragging = true);
              }
            }
          },
          onPanEnd: (_) {
            if (mounted) {
              // Check if mounted
              setState(() {
                _isDragging = false;
                _dragStartPosition = null;
              });
            }
          },
          child: Draggable<DockButton>(
            data: widget.button,
            feedback: Builder(
              builder: (context) {
                return Transform.translate(
                  offset: _dragStartPosition ?? Offset.zero,
                  child: Material(
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
                );
              },
            ),
            childWhenDragging: const SizedBox.shrink(),
            onDragStarted: () {
              setState(() => _isDragging = true);
              widget.onDragStarted?.call();
            },
            onDragEnd: (details) {
              if (mounted) {
                // Add mounted check
                setState(() {
                  _isDragging = false;
                  _dragStartPosition = null;
                });
              }
              widget.onDragEnd?.call();
            },
            onDragCompleted: () {
              if (mounted) {
                // Add mounted check
                setState(() {
                  _isDragging = false;
                  _dragStartPosition = null;
                });
              }
              widget.onDragCompleted?.call();
            },
            onDraggableCanceled: (_, __) {
              if (mounted) {
                // Add mounted check
                setState(() {
                  _isDragging = false;
                  _dragStartPosition = null;
                });
              }
              widget.onDraggableCanceled?.call();
            },
            child: Container(
              key: widget.buttonKey,
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
                        duration: const Duration(milliseconds: 300),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
