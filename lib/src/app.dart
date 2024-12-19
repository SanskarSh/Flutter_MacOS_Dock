import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_macos_docks/src/config/constants.dart';
import 'package:flutter_macos_docks/src/widgets/dock.dart';

/// Root class
///
/// Features:
///         - Theme of the app
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    /// Get system theme
    final isPlatformDark =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? darkTheme : lightTheme;

    /// animated_theme_switcher package
    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const Dock(),
        );
      },
    );
  }
}
