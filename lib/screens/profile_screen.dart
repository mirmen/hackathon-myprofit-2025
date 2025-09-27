import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_utils.dart';
import 'auth_screen.dart';

/// Экран профиля пользователя
/// Отображает информацию о пользователе, статистику и настройки
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Загрузка данных пользователя при инициализации экрана
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<UserProvider>().loadUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Профиль',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.currentUser != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _showLogoutDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, child) {
          // Если пользователь не авторизован, показываем приглашение войти
          if (authProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Войдите в аккаунт',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Чтобы видеть профиль и делать покупки',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AuthScreen()),
                      );
                    },
                    child: const Text('Войти'),
                  ),
                ],
              ),
            );
          }

          // Показываем индикатор загрузки пока данные пользователя загружаются
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.currentUser;
          // Если данные пользователя не загрузились, показываем ошибку
          if (user == null) {
            return const Center(child: Text('Ошибка загрузки профиля'));
          }

          // Основной контент профиля
          return SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
            child: Column(
              children: [
                // Шапка профиля с аватаром и основной информацией
                Card(
                  child: Padding(
                    padding: ResponsiveUtils.getResponsivePadding(
                      context,
                      all: 20,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppConstants.primaryColor,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.manrope(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Участник с ${_formatDate(user.memberSince)}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Бонусные баллы пользователя
                Card(
                  child: Padding(
                    padding: ResponsiveUtils.getResponsivePadding(
                      context,
                      all: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.stars, color: AppConstants.goldColor),
                            const SizedBox(width: 8),
                            Text(
                              'Бонусные баллы',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${user.bonusPoints} из ${user.bonusPointsGoal}',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            Text(
                              '${(user.bonusProgress * 100).toInt()}%',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: user.bonusProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Информация о книгообмене
                        Row(
                          children: [
                            Icon(
                              Icons.autorenew,
                              size: 16,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Книгообмен активен',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to book exchange screen
                              },
                              child: Text('Обменять книги'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Карточки быстрой статистики
                Row(
                  children: [
                    Expanded(
                      child: Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return _buildStatCard(
                            'В корзине',
                            '${cartProvider.itemCount}',
                            Icons.shopping_cart,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favoritesProvider, child) {
                          return _buildStatCard(
                            'Избранное',
                            '${favoritesProvider.favoriteProductIds.length}',
                            Icons.favorite,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Статистика чтения
                Row(
                  children: [
                    Expanded(
                      child: _buildStreakCard(
                        'Текущая серия',
                        '${user.currentStreak}',
                        'дней',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStreakCard(
                        'Лучшая серия',
                        '${user.longestStreak}',
                        'дней',
                        AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Цитаты',
                        '${user.quotesCount}',
                        Icons.format_quote,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Настройки приложения
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.book),
                        title: const Text('Мои книги'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to user's book collection
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Фото цитат'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to quote photos screen
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Уведомления'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            // TODO: Implement notifications toggle
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Помощь и поддержка'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to help screen
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('О приложении'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to about screen
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Создание карточки со статистикой
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppConstants.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Создание карточки серии чтения
  Widget _buildStreakCard(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
        child: Column(
          children: [
            Icon(Icons.local_fire_department, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              subtitle,
              style: GoogleFonts.manrope(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  /// Форматирование даты в удобочитаемый формат
  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Показ диалога подтверждения выхода из аккаунта
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              context.read<UserProvider>().clearUser();
              context.read<CartProvider>().loadCart();
              context.read<FavoritesProvider>().loadFavorites();
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
