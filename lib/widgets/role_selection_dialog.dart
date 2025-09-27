import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class RoleSelectionDialog extends StatelessWidget {
  final String userName;

  const RoleSelectionDialog({Key? key, required this.userName})
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
            // Иконка
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),

            // Заголовок
            Text(
              'Выбор режима входа',
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: ResponsiveUtils.responsivePadding(context, 8)),

            // Сообщение
            Text(
              'Здравствуйте, $userName!\nВы вошли как администратор.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
            ),

            SizedBox(height: ResponsiveUtils.responsivePadding(context, 24)),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop('user');
                    },
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
                      'Обычный вход',
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
                      Navigator.of(context).pop('admin');
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
                      'Панель админа',
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
