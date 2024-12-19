import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_macos_docks/src/config/constants.dart';
import 'package:flutter_macos_docks/src/widgets/dock_container.dart';
import 'package:flutter_macos_docks/src/widgets/dock_item.dart';

/// Dock class
///
/// Features:
///         - Theme switcher[dark/light]
///         - Background image
///         - Call DockContainer
///         - Call DockItems
///
/// Used stack to prevent the DockItems form getting clipped when resized
class Dock extends StatelessWidget {
  const Dock({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ThemeSwitchingArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: buildIconToSwitchTheme(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isDarkMode
                    ? 'assets/background/dark.png'
                    : 'assets/background/light.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ValueListenableBuilder<double>(
              valueListenable: dockSizeNotifier,
              builder: (context, dockSize, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DockContainer(),
                    Positioned(
                      bottom: dockSize * 0,
                      left: 16,
                      right: 16,
                      child: DockItems(
                        icons: iconListNotifier.value,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ThemeSwitcher buildIconToSwitchTheme() {
    return ThemeSwitcher.withTheme(
      builder: (_, switcher, theme) {
        return IconButton(
          onPressed: () {
            switcher.changeTheme(
              theme:
                  theme.brightness == Brightness.light ? darkTheme : lightTheme,
            );
          },
          icon: Icon(
            theme.brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode,
            color: theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          tooltip: 'Toggle theme',
        );
      },
    );
  }
}
