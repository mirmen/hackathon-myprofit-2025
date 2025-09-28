// responsive_system.dart
import 'package:flutter/material.dart';

class ResponsiveSystem {
  static double getBaseUnit(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide * 0.02; // 2% от короткой стороны экрана
  }

  // Единая система spacing
  static double spacingExtraSmall(BuildContext context) =>
      getBaseUnit(context) * 0.5;
  static double spacingSmall(BuildContext context) => getBaseUnit(context);
  static double spacingMedium(BuildContext context) =>
      getBaseUnit(context) * 1.5;
  static double spacingLarge(BuildContext context) => getBaseUnit(context) * 2;
  static double spacingExtraLarge(BuildContext context) =>
      getBaseUnit(context) * 3;

  // Единая система радиусов
  static double borderRadiusSmall(BuildContext context) =>
      getBaseUnit(context) * 0.75;
  static double borderRadiusMedium(BuildContext context) =>
      getBaseUnit(context);
  static double borderRadiusLarge(BuildContext context) =>
      getBaseUnit(context) * 1.5;

  // Единая система иконок
  static double iconSizeSmall(BuildContext context) =>
      getBaseUnit(context) * 1.5;
  static double iconSizeMedium(BuildContext context) =>
      getBaseUnit(context) * 2;
  static double iconSizeLarge(BuildContext context) =>
      getBaseUnit(context) * 2.5;

  // Адаптивная сетка
  static int getGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }

  static double getGridItemWidth(BuildContext context) {
    final spacing = spacingMedium(context);
    final gridCount = getGridCount(context);
    final availableWidth =
        MediaQuery.of(context).size.width - (spacing * (gridCount + 1));
    return availableWidth / gridCount;
  }
}
