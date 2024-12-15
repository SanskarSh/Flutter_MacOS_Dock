import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A MacOS-style dock widget that provides smooth animations and scaling effects.
///
/// This widget creates a horizontal dock similar to MacOS, featuring:
/// * Smooth drag and drop reordering
/// * Scale animations on hover
/// * Slot-to-slot transitions
/// * Responsive scaling effects
class Dock<T> extends StatefulWidget {
  /// Creates a dock with the specified items and builder function.
  ///
  /// The [items] parameter specifies the list of items to display in the dock.
  /// The [builder] parameter defines how each item should be rendered.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// The list of items to be displayed in the dock.
  final List<T> items;

  /// A builder function that creates widgets for each item in the dock.
  ///
  /// This function is called for each item in [items] to create its visual
  /// representation.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with TickerProviderStateMixin {
  /// The current list of items in the dock.
  late final List<T> _items = widget.items.toList();

  /// Index of the currently dragged item, if any.
  int? _draggedIndex;

  /// Current position of the mouse hover.
  double? _dragPosition;

  /// Last recorded position during drag operation.
  double? _lastDragPosition;

  /// Controls the scale animation of dock items.
  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  /// Controls the position animation of dock items.
  late final AnimationController _positionController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  /// The total width allocated for each item, including margins.
  static const double _itemTotalWidth = 64.0;

  /// The maximum scale factor applied to items during hover/drag.
  static const double _maxScale = 1.2;

  @override
  void dispose() {
    _scaleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _handleHover,
      onExit: _handleExit,
      child: Container(
        width: 330,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              for (int i = 0; i < _items.length; i++)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  left: _calculateItemPosition(i),
                  child: Draggable<int>(
                    data: i,
                    feedback: _buildFeedback(i),
                    childWhenDragging: const SizedBox(),
                    onDragStarted: () => _onDragStart(i),
                    onDragUpdate: (details) => _onDragUpdate(details),
                    onDragEnd: (details) => _onDragEnd(),
                    child: DragTarget<int>(
                      onWillAccept: (data) => data != i,
                      onAccept: (data) => _reorderItems(data, i),
                      builder: (context, candidateData, rejectedData) {
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(
                            begin: 1.0,
                            end: _calculateScale(i),
                          ),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: widget.builder(_items[i]),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(int index) {
    return Transform.scale(
      scale: _maxScale,
      child: widget.builder(_items[index]),
    );
  }

  void _handleHover(PointerHoverEvent event) {
    setState(() {
      _dragPosition = event.localPosition.dx;
    });
  }

  void _handleExit(PointerExitEvent event) {
    setState(() {
      _dragPosition = null;
    });
  }

  void _onDragStart(int index) {
    setState(() {
      _draggedIndex = index;
      _lastDragPosition = index * _itemTotalWidth;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _lastDragPosition = (_lastDragPosition ?? 0) + details.delta.dx;
    });
  }

  void _onDragEnd() {
    setState(() {
      _draggedIndex = null;
      _lastDragPosition = null;
    });
  }

  void _reorderItems(int fromIndex, int toIndex) {
    setState(() {
      final item = _items.removeAt(fromIndex);
      _items.insert(toIndex, item);
    });
  }

  double _calculateItemPosition(int index) {
    if (_draggedIndex == index && _lastDragPosition != null) {
      return _lastDragPosition!;
    }
    return index * _itemTotalWidth;
  }

  double _calculateScale(int index) {
    if (_draggedIndex == index) return _maxScale;
    if (_dragPosition == null) return 1.0;

    final position = index * _itemTotalWidth;
    final distance = (position - _dragPosition!).abs();
    final maxDistance = _itemTotalWidth * 2;

    if (distance > maxDistance) return 1.0;

    return 1.0 + ((_maxScale - 1.0) * (1 - (distance / maxDistance)));
  }
}
