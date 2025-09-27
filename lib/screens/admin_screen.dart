import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';
import 'admin_products_screen.dart';
import 'admin_promotions_screen.dart';
import 'admin_clubs_screen.dart';
import 'admin_users_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Панель администратора',
          style: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(
              context,
              horizontal: 24,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добро пожаловать в панель администратора',
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 16),
                ),
                Text(
                  'Здесь вы можете управлять контентом приложения',
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 32),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.book,
                  title: 'Управление книгами',
                  subtitle: 'Добавить, удалить или изменить книги',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProductsScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 16),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.coffee,
                  title: 'Управление продуктами',
                  subtitle: 'Управление кофе и десертами',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProductsScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 16),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.local_offer,
                  title: 'Управление акциями',
                  subtitle: 'Создать или изменить акции',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminPromotionsScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 16),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.group,
                  title: 'Управление клубами',
                  subtitle: 'Создать или изменить клубы',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminClubsScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 16),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.group,
                  title: 'Управление пользователями',
                  subtitle: 'Просмотр и управление пользователями',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminUsersScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 16),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.settings,
                  title: 'Настройки приложения',
                  subtitle: 'Общие настройки и конфигурации',
                  onTap: () {
                    // TODO: Navigate to app settings
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(
            context,
            horizontal: 20,
            vertical: 20,
          ),
          child: Row(
            children: [
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context, all: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              SizedBox(width: ResponsiveUtils.responsivePadding(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          18,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsivePadding(context, 4),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          14,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
