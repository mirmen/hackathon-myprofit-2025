import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/auth_screen.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class AuthPromptDialog extends StatelessWidget {
  final String title;
  final String message;

  const AuthPromptDialog({Key? key, required this.title, required this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context, all: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.coffee, size: 40, color: AppColors.primary),
            ),

            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),

            // Title
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: ResponsiveUtils.responsivePadding(context, 12)),

            // Message
            Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: ResponsiveUtils.responsivePadding(context, 24)),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textLight,
                      side: BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: ResponsiveUtils.getResponsivePadding(
                        context,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Отмена',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          14,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: ResponsiveUtils.responsivePadding(context, 12)),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Close dialog first

                      // Navigate to auth screen
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: ResponsiveUtils.getResponsivePadding(
                        context,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Войти',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          14,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
