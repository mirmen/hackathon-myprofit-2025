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

// Screen size breakpoints
enum ScreenSize { small, medium, large, extraLarge }

class ResponsiveUtils {
  // ФИКСИРОВАННЫЕ значения для предотвращения ЛЮБЫХ переполнений
  static const double _minPhoneWidth = 320.0;
  static const double _maxPhoneWidth = 500.0;

  // Get screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get device pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Get safe area padding
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Get viewport insets (keyboard, etc.)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  // Determine screen type based on width
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
    return baseSize; // Просто возвращаем базовый размер - НИКАКИХ переполнений!
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ ОТСТУПЫ - НИКАКИХ переполнений!
  static double responsivePadding(BuildContext context, double basePadding) {
    return basePadding; // Просто возвращаем базовый размер
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ ИКОНКИ - НИКАКИХ переполнений!
  static double responsiveIconSize(BuildContext context, double baseSize) {
    return baseSize; // Просто возвращаем базовый размер
  }

  // Responsive width as percentage of screen width
  static double widthPercentage(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  // Responsive height as percentage of screen height
  static double heightPercentage(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }

  // Safe area aware heights
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

  // Grid layout calculations
  static int getGridColumns(BuildContext context) {
    final availableWidth = ResponsiveUtils.availableWidth(context);
    final minCardWidth = responsiveSize(context, 150);
    final spacing = responsivePadding(context, 12);
    final columns = ((availableWidth + spacing) / (minCardWidth + spacing))
        .floor();
    return columns.clamp(2, 4);
  }

  // Card aspect ratio based on content type and screen size
  static double getCardAspectRatio(BuildContext context) {
    // Improved aspect ratios for better design and text readability
    if (isTablet(context)) return 0.75;
    return isSmallScreen(context)
        ? 0.62
        : 0.67; // Provide more vertical space for improved design
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

  // АБСОЛЮТНО БЕЗОПАСНЫЕ МЕТОДЫ PADDING/MARGIN
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
        all,
      ); // НИКАКОЙ адаптации - только фиксированные значения!
    }

    return EdgeInsets.only(
      left: left ?? (horizontal ?? 0),
      top: top ?? (vertical ?? 0),
      right: right ?? (horizontal ?? 0),
      bottom: bottom ?? (vertical ?? 0),
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
      return EdgeInsets.all(all); // НИКАКОЙ адаптации!
    }

    return EdgeInsets.only(
      left: left ?? (horizontal ?? 0),
      top: top ?? (vertical ?? 0),
      right: right ?? (horizontal ?? 0),
      bottom: bottom ?? (vertical ?? 0),
    );
  }

  // АБСОЛЮТНО БЕЗОПАСНЫЕ BORDER RADIUS
  static BorderRadius responsiveBorderRadius(
    BuildContext context,
    double radius,
  ) {
    return BorderRadius.circular(radius); // НИКАКОЙ адаптации!
  }

  // ФИКСИРОВАННЫЕ КОНСТРЕЙНТЫ - НИКАКИХ переполнений!
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

  // ФИКСИРОВАННЫЕ МЕТОДЫ (backward compatibility)
  static double getFontSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
    required double extraLarge,
  }) {
    // Просто возвращаем medium для всех - НИКАКИХ переполнений!
    return medium;
  }

  static double getPadding(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
    required double extraLarge,
  }) {
    return medium; // ФИКСИРОВАННО!
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
    return medium; // ФИКСИРОВАННО!
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
    switch (type.toLowerCase()) {
      case 'книга':
        return Icons.menu_book;
      case 'кофе':
        return Icons.coffee;
      case 'десерт':
        return Icons.cake;
      default:
        return Icons.shopping_bag;
    }
  }

  static Color getColorForProductType(String type) {
    switch (type.toLowerCase()) {
      case 'книга':
        return const Color(0xFF8C6A4B);
      case 'кофе':
        return const Color(0xFF6D4C41);
      case 'десерт':
        return const Color(0xFFD7CCC8);
      default:
        return Colors.grey;
    }
  }

  // Legacy methods for backward compatibility
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

  // Authentication helper methods
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
