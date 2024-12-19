import 'package:flutter/material.dart';
import 'package:flutter_macos_docks/src/config/constants.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// DockContainer class - Glassmorphic dock with resize functionality
///
/// Features:
///         - Resize with vertical drag at the top border
///         - Glassmorphic effect using glassmorphism package
///         - Responsive width of docs
///         - GestureDetector
///
/// Builds background for the dock
class DockContainer extends StatelessWidget {
  const DockContainer({super.key});

  /// Calculate dock width
  /// dockSizeNotifier.value = Height of the dock
  /// 60% of Dock Height = Width of a single icon
  ///
  /// (Icon width + space between icons) * number of icons + 32(16px/each side)
  /// = Total width of the dock
  double get dockWidth =>
      (dockSizeNotifier.value * 0.6 + spaceBetweenIcons) *
          iconListNotifier.value.length +
      32;

  @override
  Widget build(BuildContext context) {
    // Current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<double>(
      valueListenable: dockSizeNotifier,
      builder: (context, dockSize, _) {
        /// Prevents dock size exceeding the screen width
        /// Otherwise icons look ugly
        final screenSize = MediaQuery.of(context).size;
        final resizePossible = dockWidth < screenSize.width - 32;

        /// Resize the dock vertically
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: resizePossible
              ? (_) {
                  isDraggingNotifier.value = true;
                }
              : null,

          /// Change dock height
          /// Height constraints between 60 and 150(hmm..)
          onVerticalDragUpdate: resizePossible
              ? (details) {
                  final newHeight = dockSizeNotifier.value - details.delta.dy;
                  dockSizeNotifier.value = newHeight.clamp(40.0, 150);
                  initDockSize = dockSizeNotifier.value;
                }
              : null,
          onVerticalDragEnd: resizePossible
              ? (_) {
                  isDraggingNotifier.value = false;
                }
              : null,
          child: Stack(
            /// Some use..
            clipBehavior: Clip.none,

            alignment: Alignment.bottomCenter,
            children: [
              _buildDockContainer(dockSize, isDarkMode),

              /// Resize area
              Positioned(
                /// (2 * 22.9%)
                top: -dockSize * 0.229,
                left: 0,
                right: 0,
                child: MouseRegion(
                  cursor: resizePossible
                      ? SystemMouseCursors.resizeUpDown
                      : SystemMouseCursors.basic,
                  child: SizedBox(
                    height: dockSize * 0.229 * 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AnimatedContainer _buildDockContainer(double dockSize, bool isDarkMode) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: GlassmorphicContainer(
        height: dockSize,
        width: dockWidth,
        borderRadius: dockSize * 0.229,
        blur: 10,
        alignment: Alignment.bottomCenter,
        border: 1,

        /// Background gradient
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDarkMode ? Colors.black : Colors.white).withOpacity(0.1),
            (isDarkMode ? Colors.black : Colors.white).withOpacity(0.1),
          ],
          stops: const [0.1, 1],
        ),

        /// Border gradient
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDarkMode ? Colors.black : Colors.white).withOpacity(0.5),
            (isDarkMode ? Colors.black : Colors.white).withOpacity(0.5),
          ],
        ),
      ),
    );
  }
}
