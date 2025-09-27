import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/promotion.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class AdminPromotionsScreen extends StatefulWidget {
  @override
  _AdminPromotionsScreenState createState() => _AdminPromotionsScreenState();
}

class _AdminPromotionsScreenState extends State<AdminPromotionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Управление акциями',
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
          if (adminProvider.isLoadingPromotions) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await adminProvider.loadPromotions();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsivePadding(context, 16),
              ),
              itemCount: adminProvider.promotions.length + 1,
              itemBuilder: (context, index) {
                if (index == adminProvider.promotions.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.responsivePadding(context, 16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showPromotionFormDialog(context, null);
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
                        'Добавить новую акцию',
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

                final promotion = adminProvider.promotions[index];
                return _buildPromotionCard(context, promotion, adminProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotionCard(
    BuildContext context,
    Promotion promotion,
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
                if (promotion.imageUrl != null &&
                    promotion.imageUrl!.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(promotion.imageUrl!),
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
                    child: Icon(Icons.local_offer, color: AppColors.primary),
                  ),
                SizedBox(width: ResponsiveUtils.responsivePadding(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.title,
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
                        promotion.subtitle,
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
                      if (promotion.category.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.responsivePadding(
                              context,
                              8,
                            ),
                            vertical: ResponsiveUtils.responsivePadding(
                              context,
                              4,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            promotion.category,
                            style: GoogleFonts.montserrat(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                12,
                              ),
                              color: AppColors.primary,
                            ),
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
                      _showPromotionFormDialog(context, promotion);
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
                      _confirmDeletePromotion(
                        context,
                        promotion,
                        adminProvider,
                      );
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

  void _showPromotionFormDialog(BuildContext context, Promotion? promotion) {
    final titleController = TextEditingController(text: promotion?.title ?? '');
    final subtitleController = TextEditingController(
      text: promotion?.subtitle ?? '',
    );
    final descriptionController = TextEditingController(
      text: promotion?.description ?? '',
    );
    final imageUrlController = TextEditingController(
      text: promotion?.imageUrl ?? '',
    );
    final linkController = TextEditingController(text: promotion?.link ?? '');
    final categoryController = TextEditingController(
      text: promotion?.category ?? 'Акции',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            promotion == null ? 'Добавить акцию' : 'Изменить акцию',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Заголовок', titleController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('Подзаголовок', subtitleController),
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
                _buildTextField('Ссылка', linkController),
                SizedBox(
                  height: ResponsiveUtils.responsivePadding(context, 12),
                ),
                _buildTextField('Категория', categoryController),
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
                    subtitleController.text.isEmpty) {
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

                bool success;
                if (promotion == null) {
                  // For new promotions, include all fields
                  final promotionData = {
                    'id': 'promo_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'description': descriptionController.text,
                    'image_url': imageUrlController.text,
                    'link': linkController.text,
                    'category': categoryController.text,
                    'created_at': DateTime.now().toIso8601String(),
                  };
                  success = await adminProvider.addPromotion(promotionData);
                } else {
                  // For updates, only send the fields that can be changed
                  final updateData = {
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'description': descriptionController.text,
                    'image_url': imageUrlController.text,
                    'link': linkController.text,
                    'category': categoryController.text,
                  };
                  success = await adminProvider.updatePromotion(
                    promotion.id,
                    updateData,
                  );
                }

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        promotion == null
                            ? 'Акция успешно добавлена'
                            : 'Акция успешно обновлена',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при сохранении акции'),
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

  void _confirmDeletePromotion(
    BuildContext context,
    Promotion promotion,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Удалить акцию?',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить "${promotion.title}"? Это действие нельзя отменить.',
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
                final success = await adminProvider.deletePromotion(
                  promotion.id,
                );
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Акция успешно удалена'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении акции'),
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
