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

class _DockState extends State<Dock> with TickerProviderStateMixin {
  Offset? _mousePosition;
  final _dockKey = GlobalKey();
  int? _dragTargetIndex;
  List<DockButton> _currentButtons = [];
  int? _draggingIndex;
  bool _isDisposed = false;
  final Map<int, Rect> _buttonBounds = {};
  Rect? _dockBounds;

  @override
  /// Disposes of the dock state, removing any observers, clearing button bounds,
  /// resetting the mouse position, and marking the dock as disposed. This ensures
  /// that no further state updates occur and resources are properly released. 
  /// Always call the superclass's dispose method to complete the disposal process.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    _buttonBounds.clear();
    _mousePosition = null;
    _isDisposed = true;
    _currentButtons.clear();
    super.dispose();
  }

  @override
  /// Initializes the dock state by copying the list of buttons from the widget
  /// and setting up a post-frame callback to update the dock bounds. This ensures
  /// that the dock bounds are calculated after the initial layout is complete,
  /// allowing for accurate positioning and sizing of dock items.
  void initState() {
    super.initState();
    _currentButtons = List.from(widget.buttons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDockBounds();
    });
  }

  @override
  /// Called when the [Dock] widget is updated. If the list of buttons has changed,
  /// this method updates the internal list of buttons and resets the dragging index.
  /// This ensures that the dock is properly updated when the list of buttons changes.
  ///
  /// This method is an override of [State.didUpdateWidget] and is called by the
  /// framework when the widget is updated. It is not intended to be called directly.
  ///
  /// The [oldWidget] parameter is the previous instance of the [Dock] widget. This
  /// is used to compare the old and new lists of buttons and update the internal
  /// state accordingly.
  void didUpdateWidget(Dock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.buttons != oldWidget.buttons) {
      setState(() {
        _currentButtons = List.from(widget.buttons);
        _draggingIndex = null;
      });
    }
  }

  /// Handles the start of a drag operation, setting the dragging index to the given index.
  ///
  /// This method is called when a drag operation is started. It sets the dragging index
  /// to the given index, indicating that the button at that index is being dragged. This
  /// causes the dock to update its state, redrawing the dock with the button at the
  /// given index in its dragged position.
  ///
  /// The [index] parameter is the index of the button in the dock that is being dragged.
  void _handleDragStart(int index) {
    if (!_isDisposed && mounted) {
      setState(() {
        _draggingIndex = index;
      });
    }
  }

  /// Handles the end of a drag operation, resetting the dragging index to null.
  ///
  /// This method is called when a drag operation is completed. It resets the
  /// dragging index to null, indicating that no button is currently being
  /// dragged. This causes the dock to update its state, redrawing the dock with
  /// the button that was previously being dragged at its original position.
  ///
  /// The [index] parameter is the index of the button in the dock that was
  /// being dragged.
  void _handleDragEnd(int index) {
    if (!_isDisposed && mounted) {
      setState(() {
        _draggingIndex = null;
      });
    }
  }

  /// Rearranges the dock buttons if a button was dropped onto the dock.
  ///
  /// If a button was dropped onto the dock, this method is called to rearrange
  /// the dock buttons. It resets the internal list of buttons to the original
  /// list of buttons and sets the dragging target index to null, indicating that
  /// no button is currently being dragged onto the dock. This causes the dock to
  /// update its state, redrawing the dock with the buttons in their original
  /// positions.
  void _arrangeButtons() {
    if (_dragTargetIndex != null) {
      setState(() {
        _currentButtons = List.from(widget.buttons);
        _dragTargetIndex = null;
      });
    }
  }

  /// Updates the bounds of a dock button and checks for intersections.
  ///
  /// This method is called when the bounds of a dock button have changed. It
  /// updates the internal map of button bounds with the new bounds for the
  /// given [index]. It then calls [_checkIntersections] to check for
  /// intersections between the dock and the desktop icons. If an intersection
  /// is found, a message is shown to the user.
  void _updateButtonBounds(int index, Rect bounds) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _buttonBounds[index] = bounds;
    });
    _checkIntersections();
  }

  /// Updates the dock bounds.
  ///
  /// This method is called when the dock size changes. It gets the current
  /// dock size from the render box and updates the internal [_dockBounds]
  /// variable with the new size. The [_dockBounds] variable is used to check
  /// for intersections between the dock and the desktop icons. If an
  /// intersection is found, a message is shown to the user. This method is
  /// called when the dock size changes, such as when the dock is moved or
  /// resized.
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

  /// Checks for intersections between the dock and a potential drop position.
  ///
  /// This method verifies if a given [dropPosition] is outside the current
  /// dock bounds. If the [dropPosition] is provided and is outside the dock
  /// bounds, an overlay message is shown to the user. The method ensures
  /// that no operations are performed if the widget is disposed, not mounted,
  /// or if the dock bounds are not available.
  ///
  /// The [dropPosition] is an optional parameter representing the position
  /// where an item might have been dropped. If null, no intersection checks
  /// are performed.
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
      if (isOutside) {
        _showOverlayMessage('Button exited dock bounds');
      }
    }
  }

  /// Displays an overlay message using a [SnackBar].
  ///
  /// This method shows a [SnackBar] with the given [message] for a duration
  /// of 1 second. It uses the [ScaffoldMessenger] to display the [SnackBar]
  /// in the current [BuildContext].
  ///
  /// - [message]: The message to be displayed in the [SnackBar].
  void _showOverlayMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  /// Builds the dock widget.
  ///
  /// This widget is a container with a semi-transparent grey background
  /// and rounded corners. It contains a [MouseRegion] to track mouse
  /// hover events, updating the dock's state accordingly. The dock
  /// displays its items in a [Row] layout, with each button's size and
  /// position dynamically adjusted based on the mouse's proximity
  /// to create a scaling animation effect. The dock's size is constrained
  /// to ensure a minimum height based on the button's base height and
  /// maximum scale factor.
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

  /// Builds the dock items.
  ///
  /// This method returns a list of widgets which represent the dock items.
  /// The items are built by iterating over the list of dock buttons and
  /// creating a [DragTarget] for each button. The drag target is used to
  /// detect when a button is dragged over the dock and dropped. The
  /// [onWillAccept] callback is used to check if the data being dragged is
  /// a [DockButton] and the [onAcceptWithDetails] callback is used to check
  /// for intersections with other buttons. The [onLeave] callback is used
  /// to reset the button positions when the button is dragged out of the
  /// dock.
  ///
  /// The [builder] callback is used to create the dock item widget. The
  /// widget is a [TweenAnimationBuilder] that animates the button's scale
  /// and y position based on the mouse's proximity to the button. The
  /// [curve] parameter is set to [Curves.easeOutCubic] to create a smooth
  /// animation effect.
  ///
  /// The [child] parameter is set to a [DockButtonWidget] which represents
  /// the dock button. The [onDragStarted], [onDragEnd], [onDragCompleted],
  /// and [onDraggableCanceled] callbacks are used to update the dock's
  /// state when the button is dragged.
  ///
  /// The method returns a list of widgets which represent the dock items.
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

      items.add(
        DragTarget<DockButton>(
          onWillAccept: (data) => data != null,
          onAcceptWithDetails: (details) {
            _checkIntersections(details.offset);
          },
          onLeave: (_) => _arrangeButtons(),
          builder: (context, candidateData, rejectedData) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: yOffset),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, animatedOffset, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: scale),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
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

  /// Updates the state of the dock with the current mouse position.

  /// This function is called whenever the mouse is moved over the dock. It
  /// updates the state of the dock by setting the [_mousePosition] to the
  /// current mouse position.
  ///
  /// The [_mousePosition] is used to determine which button is currently
  /// being hovered over. When the [_mousePosition] is updated, the dock is
  /// re-rendered to reflect the new hover state.
  void _updateMousePosition(PointerHoverEvent event) {
    if (!_isDisposed && mounted) {
      setState(() => _mousePosition = event.position);
    }
  }

  /// Returns the index of the button at the given [mousePosition] if it is
  /// within the bounds of the dock, or -1 if it is not.
  ///
  /// The method iterates over the list of dock buttons and checks if the
  /// [mousePosition] is within the bounds of each button. The bounds are
  /// calculated based on the button's width and the spacing between buttons.
  /// The method returns the index of the button if the [mousePosition] is
  /// within its bounds, or -1 if it is not.
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