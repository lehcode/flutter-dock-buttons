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
  final Function(DockButton)? onButtonDraggedOutside;

  const Dock({
    super.key,
    required this.buttons,
    this.itemBaseWidth = 64.0,
    this.itemBaseHeight = 64.0,
    this.maxScale = 1.3,
    this.spacing = 23.0,
    this.backgroundOpacity = 0.1,
    this.onButtonDraggedOutside,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  Offset? _mousePosition;
  final _dockKey = GlobalKey();
  int? _dragTargetIndex;
  List<DockButton> _currentButtons = [];
  int? _draggingIndex;
  bool _isDisposed = false;

  @override
  void dispose() {
    // Cancel any pending operations before disposal
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentButtons = List.from(widget.buttons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDockBounds();
    });
  }

  @override
  void didUpdateWidget(Dock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.buttons != oldWidget.buttons) {
      setState(() {
        _currentButtons = List.from(widget.buttons);
        _draggingIndex = null;
      });
    }
  }

  void _handleDragStart(int index) {
    if (!_isDisposed && mounted) {
      setState(() {
        _draggingIndex = index;
        // Remove dragged button from current buttons
        // _currentButtons = List.from(widget.buttons);
        // _currentButtons.removeAt(index);
      });
    }
  }

  void _handleDragEnd(int index) {
    if (!_isDisposed && mounted) {
      setState(() {
        _draggingIndex = null;
      });
    }
  }

  void _arrangeButtons() {
    if (_dragTargetIndex != null) {
      setState(() {
        _currentButtons = List.from(widget.buttons);
        _dragTargetIndex = null;
      });
    }
  }

  final Map<int, Rect> _buttonBounds = {};
  Rect? _dockBounds;

  void _updateButtonBounds(int index, Rect bounds) {
    if (_isDisposed || !mounted) return;

    if (!_isDisposed && mounted) {
      setState(() {
        _buttonBounds[index] = bounds;
      });
      _checkIntersections();
    }
  }

  void _updateDockBounds() {
    if (_isDisposed || !mounted) return;

    final RenderBox? renderBox =
        _dockKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _dockBounds = Offset.zero & renderBox.size;
      });
    }
  }

  void _checkIntersections([Offset? dropPosition]) {
    if (_isDisposed || !mounted || _dockBounds == null) return;

    if (_dockBounds == null) {
      debugPrint('No dock bounds');
      return;
    }

    final RenderBox? dockBox =
        _dockKey.currentContext?.findRenderObject() as RenderBox?;
    if (dockBox == null) return;

    final dockGlobalPosition = dockBox.localToGlobal(Offset.zero);
    final dockRect = Rect.fromLTWH(dockGlobalPosition.dx, dockGlobalPosition.dy,
        dockBox.size.width, dockBox.size.height);

    if (dropPosition != null) {
      final bool isOutside = !dockRect.contains(dropPosition);

      // Only notify on state change
      if (isOutside) {
        debugPrint(
            'Button drag ${isOutside ? "exited" : "entered"} dock bounds at $dropPosition');
      }

      if (isOutside) {
        _showOverlayMessage(
            'Button ${isOutside ? "exited" : "entered"} dock bounds');
        debugPrint(
            'Button drag ${isOutside ? "exited" : "entered"} dock bounds at $dropPosition');
      }
    }
  }

  void _showOverlayMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
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
          child: AnimatedBuilder(
            animation:
                AlwaysStoppedAnimation(0), // Forces rebuild on state changes
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildDockItems(),
              );
            },
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

      // if (_draggingIndex == i) {
      //   continue;
      // }

      double scale = 1.0;
      double yOffset = 0.0;

      if (_mousePosition != null &&
          dockPosition != null &&
          _draggingIndex != i) {
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

      // Skip rendering if button is being dragged
      // if (_draggingIndex == i) {
      //   items.add(const SizedBox(width: buttonSize));
      //   continue;
      // }

      items.add(
        DragTarget<DockButton>(
          onWillAccept: (data) => data != null,
          onAcceptWithDetails: (details) {
            debugPrint('Drop detected at: ${details.offset}'); // Add this line
            _checkIntersections(details.offset);
          },
          onLeave: (_) => _arrangeButtons(),
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
                        onDragStarted: () => _handleDragStart(i),
                        onDragEnd: () => _handleDragEnd(i),
                        onDragCompleted: () => _handleDragEnd(i),
                        onDraggableCanceled: () => _handleDragEnd(i),
                        onBoundsChanged: (bounds) =>
                            _updateButtonBounds(i, bounds),
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
    if (!_isDisposed && mounted) {
      setState(() => _mousePosition = event.position);
    }
  }

  int _getHoveredButtonIndex(Offset mousePosition, Offset dockPosition) {
    final buttonWidth = widget.itemBaseWidth;
    final totalButtonWidth = buttonWidth + widget.spacing;

    for (int i = 0; i < _currentButtons.length; i++) {
      if (_draggingIndex == i) continue;

      final buttonStart = dockPosition.dx + 16.0 + (i * totalButtonWidth);
      final buttonEnd = buttonStart + buttonWidth;

      if (mousePosition.dx >= buttonStart && mousePosition.dx <= buttonEnd) {
        return i;
      }
    }
    return -1;
  }
}
