import 'package:flutter/material.dart';

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

  // Sizes
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
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
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 400;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    return isSmallScreen(context) ? baseSize - 2 : baseSize;
  }

  static double getResponsivePadding(BuildContext context, double basePadding) {
    return isSmallScreen(context) ? basePadding - 4 : basePadding;
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
}
