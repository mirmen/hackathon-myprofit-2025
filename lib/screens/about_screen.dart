import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'О приложении',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Кофебук',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Версия 1.0.0',
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            // Description
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.medium),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'О приложении',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Приложение "Кофебук" создано для любителей чтения, '
                      'которые хотят найти и приобрести лучшие книги, участвовать в книжных '
                      'мероприятиях и делиться своими впечатлениями с другими читателями.',
                      style: GoogleFonts.manrope(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Наше приложение предлагает:'
                      '\n• Широкий выбор книг различных жанров'
                      '\n• Удобный поиск и фильтрацию'
                      '\n• Систему бонусов и скидок'
                      '\n• Возможность участвовать в книжных клубах'
                      '\n• Фото цитат и обмен впечатлениями',
                      style: GoogleFonts.manrope(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Features
            Text(
              'Основные функции',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              Icons.shopping_cart,
              'Покупка книг',
              'Удобный процесс оформления заказов',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              Icons.groups,
              'Книжные клубы',
              'Обсуждение книг с другими читателями',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              Icons.card_giftcard,
              'Бонусная система',
              'Накопление и использование бонусов',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              Icons.camera_alt,
              'Фото цитат',
              'Сохранение любимых цитат из книг',
            ),
            const SizedBox(height: 24),
            // Developer Info
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.medium),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Разработчик',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© 2025 Кофебук\nВсе права защищены.',
                      style: GoogleFonts.manrope(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Legal
            Text(
              'Правовая информация',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildLegalCard('Политика конфиденциальности'),
            const SizedBox(height: 12),
            _buildLegalCard('Пользовательское соглашение'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalCard(String title) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.manrope(fontSize: 16)),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
