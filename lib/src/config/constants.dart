import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

/// Configuration for light and dark theme
final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.transparent,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.transparent,
);

/// Height of the dock
double initDockSize = 70.0;

/// Common constants
const double spaceBetweenIcons = 16.0;
const Duration animationDuration = Duration(milliseconds: 200);
const Curve animationCurve = Curves.fastOutSlowIn;

/// Used to resize the dock
final ValueNotifier<double> dockSizeNotifier = ValueNotifier<double>(70.0);
// Used to track the hover index
final ValueNotifier<int?> hoveredIndexNotifier = ValueNotifier<int?>(-1);

/// Used to track if the dock is being resized
final ValueNotifier<bool> isDraggingNotifier = ValueNotifier<bool>(false);

/// Used to track the position of the icons
final ValueNotifier<List<IconData>> iconListNotifier =
    ValueNotifier<List<IconData>>(
  [
    AntDesign.github_fill,
    BoxIcons.bxl_android,
    BoxIcons.bxl_react,
    Icons.logo_dev,
    BoxIcons.bxl_firebase,
    Bootstrap.git,
    AntDesign.gitlab_fill,
    Bootstrap.discord,
  ],
);
