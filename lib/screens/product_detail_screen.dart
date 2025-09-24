// product_detail_screen.dart (полный код с исправлениями)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../utils/cached_image_widget.dart';
import '../utils/app_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedOption = '';
  int quantity = 1;
  bool isDescriptionExpanded = false;
  Product? product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      AppUtils.showErrorSnackBar(context, 'Авторизуйтесь для просмотра');
      return;
    }
    try {
      product = await context.read<ProductProvider>().getProductById(
        widget.productId,
      );
      if (product != null) {
        selectedOption = product!.options.isNotEmpty
            ? product!.options.first
            : 'Стандарт';
        setState(() {});
      } else {
        AppUtils.showErrorSnackBar(context, 'Продукт не найден');
      }
    } catch (e) {
      AppUtils.showErrorSnackBar(context, 'Ошибка загрузки продукта: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = AppUtils.isSmallScreen(context);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer2<CartProvider, FavoritesProvider>(
      builder: (context, cartProvider, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(product!.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: screenHeight * 0.35,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProductCachedImage(
                    imageUrl: product!.imageUrl,
                    productType: product!.type,
                    width: double.infinity,
                    height: screenHeight * 0.35,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      final success = await favoritesProvider.toggleFavorite(
                        product!.id,
                      );
                      if (success) {
                        AppUtils.showSnackBar(
                          context,
                          isFavorite
                              ? 'Удалено из избранного'
                              : 'Добавлено в избранное',
                        );
                      }
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(
                    AppUtils.getResponsivePadding(
                      context,
                      AppConstants.paddingMedium,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.title,
                        style: GoogleFonts.manrope(
                          fontSize: AppUtils.getResponsiveFontSize(context, 24),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 8),
                      ),
                      Text(
                        product!.author,
                        style: GoogleFonts.manrope(
                          fontSize: AppUtils.getResponsiveFontSize(context, 16),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 8),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppConstants.goldColor,
                            size: AppUtils.getResponsiveFontSize(context, 18),
                          ),
                          SizedBox(width: 4),
                          Text(
                            AppUtils.formatRating(product!.rating),
                            style: GoogleFonts.manrope(
                              fontSize: AppUtils.getResponsiveFontSize(
                                context,
                                16,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 16),
                      ),
                      Text(
                        AppUtils.formatPrice(product!.price),
                        style: GoogleFonts.manrope(
                          fontSize: AppUtils.getResponsiveFontSize(context, 22),
                          fontWeight: FontWeight.w700,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 24),
                      ),
                      Text(
                        'Вариант',
                        style: GoogleFonts.manrope(
                          fontSize: AppUtils.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedOption,
                            isExpanded: true,
                            items: product!.options.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option,
                                  style: GoogleFonts.manrope(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedOption = value);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 24),
                      ),
                      Text(
                        'Количество',
                        style: GoogleFonts.manrope(
                          fontSize: AppUtils.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove,
                                color: quantity > 1
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                              ),
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                            ),
                            Text(
                              '$quantity',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: AppConstants.primaryColor,
                              ),
                              onPressed: () => setState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 24),
                      ),
                      ExpansionPanelList(
                        expansionCallback: (panelIndex, isExpanded) =>
                            setState(() => isDescriptionExpanded = !isExpanded),
                        children: [
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) => ListTile(
                              title: Text(
                                'Описание',
                                style: GoogleFonts.manrope(
                                  fontSize: AppUtils.getResponsiveFontSize(
                                    context,
                                    16,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                product!.description,
                                style: GoogleFonts.manrope(fontSize: 14),
                              ),
                            ),
                            isExpanded: isDescriptionExpanded,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppUtils.getResponsivePadding(context, 32),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cartProvider.isLoading
                              ? null
                              : () async {
                                  final success = await cartProvider.addToCart(
                                    product!,
                                    selectedOption,
                                    quantity,
                                  );
                                  if (success) {
                                    AppUtils.showSuccessSnackBar(
                                      context,
                                      'Товар добавлен в корзину',
                                    );
                                  } else {
                                    AppUtils.showErrorSnackBar(
                                      context,
                                      'Ошибка при добавлении в корзину',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: cartProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_basket, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'В корзину',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
