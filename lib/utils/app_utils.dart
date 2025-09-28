import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_prompt_dialog.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF8C6A4B);
  static const Color secondaryColor = Color(0xFFCD9F68);
  static const Color backgroundColor = Color(0xFFF8F5F1);
  static const Color textPrimaryColor = Color(0xFF2E2E2E);
  static const Color goldColor = Color(0xFFFFD700);

  // Strings
  static const String appName = 'CoffeeBook';
  static const String cartKey = 'cart_items';
  static const String favoritesKey = 'favorite_products';

  // Base sizes (will be scaled responsively)
  static const double baseBorderRadius = 12.0;
  static const double baseCardElevation = 2.0;
  static const double basePaddingSmall = 8.0;
  static const double basePaddingMedium = 16.0;
  static const double basePaddingLarge = 24.0;

  // Get responsive sizes
  static double borderRadius(BuildContext context) =>
      ResponsiveUtils.responsivePadding(context, baseBorderRadius);
  static double cardElevation(BuildContext context) =>
      ResponsiveUtils.responsiveSize(context, baseCardElevation);
  static double paddingSmall(BuildContext context) =>
      ResponsiveUtils.responsivePadding(context, basePaddingSmall);
  static double paddingMedium(BuildContext context) =>
      ResponsiveUtils.responsivePadding(context, basePaddingMedium);
  static double paddingLarge(BuildContext context) =>
      ResponsiveUtils.responsivePadding(context, basePaddingLarge);
}

// Точки останова размера экрана
enum ScreenSize { small, medium, large, extraLarge }

class ResponsiveUtils {
  // ФИКСИРОВАННЫЕ значения для предотвращения ЛЮБЫХ переполнений
  static const double _minPhoneWidth = 320.0;
  static const double _maxPhoneWidth = 500.0;

  // Получить размеры экрана
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Получить соотношение пикселей устройства
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Получить отступы безопасной области
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Получить вставки области просмотра (клавиатура и т.д.)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  // Определить тип экрана по ширине
  static ScreenSize getScreenType(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return ScreenSize.small;
    if (width < 411) return ScreenSize.medium;
    if (width < 768) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 360 && width < 411;
  }

  static bool isLargeScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 411 && width < 768;
  }

  static bool isTablet(BuildContext context) {
    return getScreenWidth(context) >= 768;
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ методы (НИКАКИХ переполнений!)
  // Только фиксированные значения и минимальные адаптации

  static double responsive(BuildContext context, double value) {
    // Просто возвращаем базовое значение
    return value;
  }

  static double responsiveHeight(BuildContext context, double value) {
    return value;
  }

  static double responsiveSize(
    BuildContext context,
    double baseSize, {
    double? minSize,
    double? maxSize,
  }) {
    // Минимальная адаптация только для очень маленьких экранов
    final width = getScreenWidth(context);
    if (width < 350) {
      return baseSize * 0.9; // Максимум 10% уменьшение
    }
    return baseSize; // Все остальные - базовые размеры
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ ШРИФТЫ - НИКАКИХ переполнений!
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);

    // Use percentage-based scaling for better responsiveness
    if (screenWidth < 360) {
      return baseSize * 0.9; // Smaller screens get smaller text
    } else if (screenWidth > 768) {
      return baseSize * 1.1; // Larger screens get larger text
    }
    return baseSize; // Standard screens get base size
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ ОТСТУПЫ - НИКАКИХ переполнений!
  static double responsivePadding(BuildContext context, double basePadding) {
    final screenWidth = getScreenWidth(context);

    // Use percentage-based padding for better responsiveness
    if (screenWidth < 360) {
      return basePadding * 0.8; // Smaller screens get tighter padding
    } else if (screenWidth > 768) {
      return basePadding * 1.2; // Larger screens get looser padding
    }
    return basePadding; // Standard screens get base padding
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ ИКОНКИ - НИКАКИХ переполнений!
  static double responsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);

    // Use percentage-based icon sizing for better responsiveness
    if (screenWidth < 360) {
      return baseSize * 0.85; // Smaller screens get smaller icons
    } else if (screenWidth > 768) {
      return baseSize * 1.15; // Larger screens get larger icons
    }
    return baseSize; // Standard screens get base size
  }

  // Адаптивная ширина в процентах от ширины экрана
  static double widthPercentage(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  // Адаптивная высота в процентах от высоты экрана
  static double heightPercentage(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }

  // Высоты с учетом безопасной области
  static double availableHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final padding = getSafeAreaInsets(context);
    final viewInsets = getViewInsets(context);
    return screenHeight - padding.top - padding.bottom - viewInsets.bottom;
  }

  static double availableWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    final padding = getSafeAreaInsets(context);
    return screenWidth - padding.left - padding.right;
  }

  // Расчеты сеточного макета
  static int getGridColumns(BuildContext context) {
    final availableWidth = ResponsiveUtils.availableWidth(context);
    final minCardWidth = responsiveSize(context, 150);
    final spacing = responsivePadding(context, 12);
    final columns = ((availableWidth + spacing) / (minCardWidth + spacing))
        .floor();
    return columns.clamp(2, 4);
  }

  // Соотношение сторон карточки в зависимости от типа контента и размера экрана
  static double getCardAspectRatio(BuildContext context) {
    // Улучшенные соотношения сторон для лучшего дизайна и читаемости текста
    if (isTablet(context)) return 0.75;
    return isSmallScreen(context)
        ? 0.62
        : 0.67; // Обеспечить больше вертикального пространства для улучшенного дизайна
  }

  // АБСОЛЮТНО ФИКСИРОВАННЫЕ ВЫСОТЫ - НИКАКИХ переполнений!
  static double getAppBarHeight(BuildContext context) {
    final safePadding = getSafeAreaInsets(context).top;
    return 56.0 + safePadding; // Стандартная высота AppBar
  }

  static double getBottomNavHeight(BuildContext context) {
    final safePadding = getSafeAreaInsets(context).bottom;
    return 70.0 + safePadding; // ФИКСИРОВАННО!
  }

  static double getToolbarHeight(BuildContext context) {
    return kToolbarHeight; // ФИКСИРОВАННО!
  }

  // ФИКСИРОВАННЫЕ высоты кнопок
  static double getButtonHeight(
    BuildContext context, {
    String size = 'medium',
  }) {
    switch (size) {
      case 'small':
        return 36.0;
      case 'large':
        return 56.0;
      default:
        return 48.0;
    }
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ МЕТОДЫ ОТСТУПОВ/МАРЖИНА
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(
        responsivePadding(context, all),
      ); // НИКАКОЙ адаптации - только фиксированные значения!
    }

    return EdgeInsets.only(
      left: left != null
          ? responsivePadding(context, left)
          : (horizontal != null ? responsivePadding(context, horizontal) : 0),
      top: top != null
          ? responsivePadding(context, top)
          : (vertical != null ? responsivePadding(context, vertical) : 0),
      right: right != null
          ? responsivePadding(context, right)
          : (horizontal != null ? responsivePadding(context, horizontal) : 0),
      bottom: bottom != null
          ? responsivePadding(context, bottom)
          : (vertical != null ? responsivePadding(context, vertical) : 0),
    );
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(
        responsivePadding(context, all),
      ); // НИКАКОЙ адаптации!
    }

    return EdgeInsets.only(
      left: left != null
          ? responsivePadding(context, left)
          : (horizontal != null ? responsivePadding(context, horizontal) : 0),
      top: top != null
          ? responsivePadding(context, top)
          : (vertical != null ? responsivePadding(context, vertical) : 0),
      right: right != null
          ? responsivePadding(context, right)
          : (horizontal != null ? responsivePadding(context, horizontal) : 0),
      bottom: bottom != null
          ? responsivePadding(context, bottom)
          : (vertical != null ? responsivePadding(context, vertical) : 0),
    );
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ РАДИУСЫ СКРУГЛЕНИЯ
  static BorderRadius responsiveBorderRadius(
    BuildContext context,
    double radius,
  ) {
    return BorderRadius.circular(
      responsivePadding(context, radius),
    ); // НИКАКОЙ адаптации!
  }

  // ФИКСИРОВАННЫЕ ОГРАНИЧЕНИЯ - НИКАКИХ переполнений!
  static BoxConstraints getResponsiveConstraints(
    BuildContext context, {
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? double.infinity,
    );
  }

  // ФИКСИРОВАННЫЕ МЕТОДЫ (обратная совместимость)
  static double getFontSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
    required double extraLarge,
  }) {
    // Просто возвращаем medium для всех - НИКАКИХ переполнений!
    return responsiveFontSize(context, medium);
  }

  static double getPadding(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
    required double extraLarge,
  }) {
    return responsivePadding(context, medium); // ФИКСИРОВАННО!
  }

  static EdgeInsets getMargin(
    BuildContext context, {
    required EdgeInsets small,
    required EdgeInsets medium,
    required EdgeInsets large,
    required EdgeInsets extraLarge,
  }) {
    return medium; // ФИКСИРОВАННО!
  }

  static double getIconSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
    required double extraLarge,
  }) {
    return responsiveIconSize(context, medium); // ФИКСИРОВАННО!
  }
}

class AppUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: ResponsiveUtils.getResponsiveMargin(context, all: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // ФИКСИРОВАННО!
        ),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} ₽';
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static IconData getIconForProductType(String type) {
    final typeLower = type.toLowerCase();

    if (typeLower.contains('книга')) {
      return Icons.menu_book;
    } else if (typeLower.contains('кофе')) {
      return Icons.coffee;
    } else if (typeLower.contains('десерт') ||
        typeLower.contains('выпечка') ||
        typeLower.contains('торт') ||
        typeLower.contains('пирог')) {
      return Icons.cake;
    } else {
      return Icons.shopping_bag;
    }
  }

  static Color getColorForProductType(String type) {
    final typeLower = type.toLowerCase();

    if (typeLower.contains('книга')) {
      return const Color(0xFF8C6A4B);
    } else if (typeLower.contains('кофе')) {
      return const Color(0xFF6D4C41);
    } else if (typeLower.contains('десерт') || typeLower.contains('выпечка')) {
      return const Color(0xFFD7CCC8);
    } else {
      return Colors.grey;
    }
  }

  // Устаревшие методы для обратной совместимости
  static bool isSmallScreen(BuildContext context) {
    return ResponsiveUtils.isSmallScreen(context);
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    return ResponsiveUtils.responsiveFontSize(context, baseSize);
  }

  static double getResponsivePadding(BuildContext context, double basePadding) {
    return ResponsiveUtils.responsivePadding(context, basePadding);
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${_pluralize(difference.inDays ~/ 365, 'год', 'года', 'лет')} назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${_pluralize(difference.inDays ~/ 30, 'месяц', 'месяца', 'месяцев')} назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${_pluralize(difference.inDays, 'день', 'дня', 'дней')} назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${_pluralize(difference.inHours, 'час', 'часа', 'часов')} назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${_pluralize(difference.inMinutes, 'минуту', 'минуты', 'минут')} назад';
    } else {
      return 'только что';
    }
  }

  static String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) {
      return one;
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return few;
    } else {
      return many;
    }
  }

  // Вспомогательные методы аутентификации
  static bool isUserAuthenticated(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser != null;
  }

  static Future<bool> requireAuthentication(
    BuildContext context, {
    String title = 'Требуется авторизация',
    String message = 'Для выполнения этого действия необходимо войти в аккаунт',
  }) async {
    if (isUserAuthenticated(context)) {
      return true;
    }

    final result = await showAuthPrompt(
      context,
      title: title,
      message: message,
    );
    return result == true;
  }

  static Future<bool?> showAuthPrompt(
    BuildContext context, {
    String title = 'Требуется авторизация',
    String message = 'Для выполнения этого действия необходимо войти в аккаунт',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AuthPromptDialog(title: title, message: message),
    );
  }
}
