import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/club.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class AdminClubsScreen extends StatefulWidget {
  @override
  _AdminClubsScreenState createState() => _AdminClubsScreenState();
}

class _AdminClubsScreenState extends State<AdminClubsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Управление клубами',
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
          if (adminProvider.isLoadingClubs) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await adminProvider.loadClubs();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsivePadding(context, 16),
              ),
              itemCount: adminProvider.clubs.length + 1,
              itemBuilder: (context, index) {
                if (index == adminProvider.clubs.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.responsivePadding(context, 16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showClubFormDialog(context, null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.responsivePadding(
                            context,
                            24,
                          ),
                          vertical: ResponsiveUtils.responsivePadding(
                            context,
                            16,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Добавить новый клуб',
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                final club = adminProvider.clubs[index];
                return _buildClubCard(context, club, adminProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildClubCard(
    BuildContext context,
    Club club,
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
                if (club.imageUrl != null && club.imageUrl!.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(club.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Icon(Icons.group, color: AppColors.primary),
                  ),
                SizedBox(width: ResponsiveUtils.responsivePadding(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.title,
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
                        club.description,
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            14,
                          ),
                          color: AppColors.textLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 8),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${club.membersCount} участников',
                            style: GoogleFonts.montserrat(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                12,
                              ),
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.wifi,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${club.onlineCount} онлайн',
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
                      _showClubFormDialog(context, club);
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
                      _confirmDeleteClub(context, club, adminProvider);
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

  void _showClubFormDialog(BuildContext context, Club? club) {
    final titleController = TextEditingController(text: club?.title ?? '');
    final descriptionController = TextEditingController(
      text: club?.description ?? '',
    );
    final imageUrlController = TextEditingController(
      text: club?.imageUrl ?? '',
    );
    final membersCountController = TextEditingController(
      text: club?.membersCount.toString() ?? '0',
    );
    final onlineCountController = TextEditingController(
      text: club?.onlineCount.toString() ?? '0',
    );
    final typeController = TextEditingController(text: club?.type ?? 'book');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            club == null ? 'Добавить клуб' : 'Изменить клуб',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Название', titleController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('Описание', descriptionController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('URL изображения', imageUrlController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField(
                  'Количество участников',
                  membersCountController,
                  TextInputType.number,
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField(
                  'Количество онлайн',
                  onlineCountController,
                  TextInputType.number,
                ),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('Тип (book/coffee)', typeController),
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
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    typeController.text.isEmpty) {
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
                final membersCount =
                    int.tryParse(membersCountController.text) ?? 0;
                final onlineCount =
                    int.tryParse(onlineCountController.text) ?? 0;

                bool success;
                if (club == null) {
                  // For new clubs, include all fields
                  final clubData = {
                    'id': 'club_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'image_url': imageUrlController.text,
                    'members_count': membersCount,
                    'online_count': onlineCount,
                    'type': typeController.text,
                    'created_at': DateTime.now().toIso8601String(),
                  };
                  success = await adminProvider.addClub(clubData);
                } else {
                  // For updates, only send the fields that can be changed
                  final updateData = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'image_url': imageUrlController.text,
                    'members_count': membersCount,
                    'online_count': onlineCount,
                    'type': typeController.text,
                  };
                  success = await adminProvider.updateClub(club.id, updateData);
                }

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        club == null
                            ? 'Клуб успешно добавлен'
                            : 'Клуб успешно обновлен',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при сохранении клуба'),
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

  void _confirmDeleteClub(
    BuildContext context,
    Club club,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Удалить клуб?',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить "${club.title}"? Это действие нельзя отменить.',
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
                final success = await adminProvider.deleteClub(club.id);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Клуб успешно удален'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении клуба'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
}
