import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class AdminProductsScreen extends StatefulWidget {
  @override
  _AdminProductsScreenState createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Управление продуктами',
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
          if (adminProvider.isLoadingProducts) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await adminProvider.loadProducts();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsivePadding(context, 16),
              ),
              itemCount: adminProvider.products.length + 1,
              itemBuilder: (context, index) {
                if (index == adminProvider.products.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.responsivePadding(context, 16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showProductFormDialog(context, null);
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
                        'Добавить новый продукт',
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

                final product = adminProvider.products[index];
                return _buildProductCard(context, product, adminProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
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
                if (product.imageUrl.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
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
                    child: Icon(Icons.image, color: AppColors.primary),
                  ),
                SizedBox(width: ResponsiveUtils.responsivePadding(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
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
                        product.author,
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
                        '${product.price.toStringAsFixed(2)} ₽',
                        style: GoogleFonts.montserrat(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            14,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
                      _showProductFormDialog(context, product);
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
                      _confirmDeleteProduct(context, product, adminProvider);
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

  void _showProductFormDialog(BuildContext context, Product? product) {
    final titleController = TextEditingController(text: product?.title ?? '');
    final authorController = TextEditingController(text: product?.author ?? '');
    final priceController = TextEditingController(
      text: product?.price.toStringAsFixed(2) ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final imageUrlController = TextEditingController(
      text: product?.imageUrl ?? '',
    );
    final typeController = TextEditingController(text: product?.type ?? '');
    bool isBook = product?.isBook ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                product == null ? 'Добавить продукт' : 'Изменить продукт',
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
                    _buildTextField('Автор', authorController),
                    SizedBox(
                      height: ResponsiveUtils.responsivePadding(context, 12),
                    ),
                    _buildTextField(
                      'Цена',
                      priceController,
                      TextInputType.number,
                    ),
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
                    _buildTextField('Тип', typeController),
                    SizedBox(
                      height: ResponsiveUtils.responsivePadding(context, 12),
                    ),
                    Row(
                      children: [
                        Text(
                          'Книга:',
                          style: GoogleFonts.montserrat(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.responsivePadding(context, 12),
                        ),
                        Switch(
                          value: isBook,
                          onChanged: (value) {
                            setState(() {
                              isBook = value;
                            });
                          },
                        ),
                      ],
                    ),
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
                        authorController.text.isEmpty ||
                        priceController.text.isEmpty) {
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
                    final price = double.tryParse(priceController.text) ?? 0.0;

                    bool success;
                    if (product == null) {
                      // For new products, include all fields
                      final productData = {
                        'id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
                        'title': titleController.text,
                        'author': authorController.text,
                        'type': typeController.text.isEmpty
                            ? 'book'
                            : typeController.text,
                        'price': price,
                        'rating': 0.0,
                        'image_url': imageUrlController.text,
                        'description': descriptionController.text,
                        'options': ['Стандарт'],
                        'is_book': isBook,
                        'created_at': DateTime.now().toIso8601String(),
                      };
                      success = await adminProvider.addProduct(productData);
                    } else {
                      // For updates, only send the fields that can be changed
                      final updateData = {
                        'title': titleController.text,
                        'author': authorController.text,
                        'type': typeController.text,
                        'price': price,
                        'image_url': imageUrlController.text,
                        'description': descriptionController.text,
                        'is_book': isBook,
                      };
                      success = await adminProvider.updateProduct(
                        product.id,
                        updateData,
                      );
                    }

                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            product == null
                                ? 'Продукт успешно добавлен'
                                : 'Продукт успешно обновлен',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка при сохранении продукта'),
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

  void _confirmDeleteProduct(
    BuildContext context,
    Product product,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Удалить продукт?',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить "${product.title}"? Это действие нельзя отменить.',
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
                final success = await adminProvider.deleteProduct(product.id);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Продукт успешно удален'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении продукта'),
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
