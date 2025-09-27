import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/user.dart' as AppUser;
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Управление пользователями',
          style: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoadingUsers) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await adminProvider.loadUsers();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsivePadding(context, 16),
              ),
              itemCount: adminProvider.users.length,
              itemBuilder: (context, index) {
                final user = adminProvider.users[index];
                return _buildUserCard(context, user, adminProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    AppUser.User user,
    AdminProvider adminProvider,
  ) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.responsivePadding(context, 16),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.responsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.avatarUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          20,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                SizedBox(width: ResponsiveUtils.responsivePadding(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 4),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            14,
                          ),
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 4),
                      ),
                      Text(
                        'С нами с ${_formatDate(user.memberSince)}',
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            12,
                          ),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Бонусные баллы: ${user.bonusPoints}',
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            14,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 4),
                      ),
                      LinearProgressIndicator(
                        value: user.bonusProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 4),
                      ),
                      Text(
                        '${(user.bonusProgress * 100).toStringAsFixed(1)}% до следующей цели',
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            12,
                          ),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showUserFormDialog(context, user);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Изменить',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          14,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.responsivePadding(context, 12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _confirmDeleteUser(context, user, adminProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Удалить',
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

  void _showUserFormDialog(BuildContext context, AppUser.User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final avatarUrlController = TextEditingController(
      text: user.avatarUrl ?? '',
    );
    final bonusPointsController = TextEditingController(
      text: user.bonusPoints.toString(),
    );
    final bonusPointsGoalController = TextEditingController(
      text: user.bonusPointsGoal.toString(),
    );
    final statusController = TextEditingController(text: user.status);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Изменить пользователя',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Имя', nameController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('Email', emailController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('URL аватара', avatarUrlController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField(
                  'Бонусные баллы',
                  bonusPointsController,
                  TextInputType.number,
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField(
                  'Цель бонусных баллов',
                  bonusPointsGoalController,
                  TextInputType.number,
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('Статус', statusController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Пожалуйста, заполните все обязательные поля',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final adminProvider = context.read<AdminProvider>();
                final bonusPoints =
                    int.tryParse(bonusPointsController.text) ?? 0;
                final bonusPointsGoal =
                    int.tryParse(bonusPointsGoalController.text) ?? 1000;

                final userData = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'avatar_url': avatarUrlController.text,
                  'bonus_points': bonusPoints,
                  'bonus_points_goal': bonusPointsGoal,
                  'status': statusController.text,
                };

                final success = await adminProvider.updateUser(
                  user.id,
                  userData,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Пользователь успешно обновлен'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при обновлении пользователя'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Сохранить',
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _confirmDeleteUser(
    BuildContext context,
    AppUser.User user,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Удалить пользователя?',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить "${user.name}"? Это действие нельзя отменить и приведет к удалению всех данных пользователя.',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Show additional confirmation
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Подтверждение'),
                      content: Text(
                        'Это действие НЕВОЗМОЖНО отменить. Все данные пользователя будут удалены безвозвратно.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Отмена'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Удалить'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  final success = await adminProvider.deleteUser(user.id);
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Пользователь успешно удален'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка при удалении пользователя'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Удалить',
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
}
