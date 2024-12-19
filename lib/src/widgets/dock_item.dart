import 'package:flutter/material.dart';
import 'package:flutter_macos_docks/src/config/constants.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

/// DockItems class
///
/// Features:
///         - Hover effect
///         - Drag and drop
///         - ReorderableGridView
///         - AnimatedContainer
///         - GestureDetector
class DockItems extends StatelessWidget {
  DockItems({super.key, required List<IconData> icons}) {
    iconListNotifier.value = icons;
  }

  /// Max vertical scale when hovered or dragged
  static const double maxScale = 1.3;

  @override
  Widget build(BuildContext context) {
    /// Used to track the position of the icons
    return ValueListenableBuilder<List<IconData>>(
      valueListenable: iconListNotifier,
      builder: (context, icons, _) {
        /// Used to track size of the dock
        return ValueListenableBuilder<double>(
          valueListenable: dockSizeNotifier,
          builder: (context, dockSize, _) {
            final iconSize = dockSize * 0.6;
            return Listener(
              onPointerMove: (event) {
                if (isDraggingNotifier.value) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(event.position);
                  final iconWidth = iconSize + spaceBetweenIcons;
                  final hoveredIndex = (localPosition.dx / iconWidth).floor();
                  hoveredIndexNotifier.value =
                      hoveredIndex.clamp(0, icons.length - 1);
                }
              },
              child: SizedBox(
                height: dockSize,
                child: Center(
                  child: MouseRegion(
                    hitTestBehavior: HitTestBehavior.translucent,

                    /// Increase dock size when hovered on the dock
                    onEnter: (_) {
                      dockSizeNotifier.value = dockSize;
                      dockSizeNotifier.value = initDockSize * 1.1;
                    },

                    onHover: (event) {
                      if (!isDraggingNotifier.value) {
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final localPosition = box.globalToLocal(event.position);
                        final iconWidth = iconSize + spaceBetweenIcons;
                        final hoveredIndex =
                            (localPosition.dx / iconWidth).floor();
                        hoveredIndexNotifier.value =
                            hoveredIndex.clamp(0, icons.length - 1);
                      }
                    },

                    /// Reset dock
                    onExit: (_) {
                      if (!isDraggingNotifier.value) {
                        dockSizeNotifier.value = initDockSize;
                        hoveredIndexNotifier.value = -1;
                      }
                    },
                    child: AnimatedContainer(
                      duration: animationDuration,
                      curve: animationCurve,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanDown: (_) {
                          if (isDraggingNotifier.value) {
                            hoveredIndexNotifier.value = -1;
                          }
                        },

                        /// reorderable_grid package
                        /// Provides a jump and space between the icons when dragged effect
                        child: _buildIconList(
                          icons,
                          iconSize,

                          /// Generate dynamic list of _buildDockItem
                          child: List.generate(
                            icons.length,
                            (index) => _buildDockIcon(
                              icon: icons[index],
                              index: index,
                              iconSize: iconSize,
                              totalIcons: icons.length,
                              key: ValueKey('dock_item_$index'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconList(List<IconData> icons, double iconSize,
      {required List<Widget> child}) {
    return ReorderableGridView.count(
      crossAxisCount: icons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: spaceBetweenIcons,
      childAspectRatio: 1.0,
      onReorderStart: (index) {
        isDraggingNotifier.value = true;
        hoveredIndexNotifier.value = index;
      },

      /// Scale vertically up on drag
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: maxScale,
              child: child,
            );
          },
          child: child,
        );
      },

      children: child,

      onReorder: (oldIndex, newIndex) {
        final adjustedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;

        /// New list with modified elements
        final List<IconData> newList = List.from(icons);
        final item = newList.removeAt(oldIndex);
        newList.insert(adjustedNewIndex, item);

        /// Updating icon list
        iconListNotifier.value = newList;
        isDraggingNotifier.value = false;
        hoveredIndexNotifier.value = -1;
      },
    );
  }

  /// Builds an Single dock item with animation, scaling, and styling effects.
  Widget _buildDockIcon({
    required IconData icon,
    required int index,
    required double iconSize,
    required int totalIcons,
    required Key key,
  }) {
    /// Calculate the scale of the icon based on the distance from the hovered index
    double _calculateScale(int index, int? hoveredIndex) {
      if (hoveredIndex == null || hoveredIndex < 0) return 1.0;

      /// 1.0 to maxScale(1.3)
      final distance = (index - hoveredIndex).abs();
      if (distance == 0) return maxScale;
      if (distance == 1) return 1.0 + (maxScale - 1.0) * 0.6;
      if (distance == 2) return 1.0 + (maxScale - 1.0) * 0.3;
      if (distance == 3) return 1.0 + (maxScale - 1.0) * 0.1;
      return 1.0;
    }

    /// Track the active icon
    return ValueListenableBuilder<int?>(
      key: key,
      valueListenable: hoveredIndexNotifier,
      builder: (context, hoverIndex, _) {
        /// Current theme
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        /// Icon size
        final scale = _calculateScale(index, hoverIndex);

        /// Icon bg color
        final Color iconBackgroundColor = isDarkMode
            ? Colors.grey[800]!
            // : Colors.primaries[icon.hashCode % Colors.primaries.length];  /// Random color
            : Colors.blueGrey[400]!;

        final Color shadowColor = isDarkMode
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.2);

        return SizedBox(
          width: iconSize,
          height: iconSize * 1.7,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: scale),
              duration: animationDuration,
              curve: animationCurve,
              builder: (context, value, child) {
                /// Scale vertically up on hover
                return Transform.translate(
                  offset: Offset(0, -(iconSize * (value - 1)) / 2),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..scale(value)
                      ..translate(0.0, 0.0),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        /// 20% of icon size
                        borderRadius: BorderRadius.circular(iconSize * 0.2),
                        color: iconBackgroundColor,

                        boxShadow: scale > 1.0
                            ? [
                                BoxShadow(
                                  /// Opacity of shadow increases gradually
                                  color: shadowColor
                                      .withOpacity(0.2 * (value - 1)),

                                  /// Blur and Spread radius increases gradually
                                  blurRadius: 8 * value,
                                  spreadRadius: 1 * value,
                                  offset: Offset(0, 2 * value),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.white,

                          /// 50% of icon bg
                          size: iconSize * 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
