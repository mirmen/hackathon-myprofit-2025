// product_detail_screen.dart (полный код с исправлениями)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/cached_image_widget.dart';
import '../utils/app_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  String selectedOption = '';
  int quantity = 1;
  bool isDescriptionExpanded = false;
  Product? product;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _loadProduct();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final productProvider = context.read<ProductProvider>();
      final loadedProduct = await productProvider.getProductById(
        widget.productId,
      );

      if (loadedProduct != null) {
        setState(() {
          product = loadedProduct;
          selectedOption = loadedProduct.options.isNotEmpty
              ? loadedProduct.options.first
              : 'Стандарт';
          isLoading = false;
        });
        _animationController.forward();
      } else {
        _showErrorSnackBar('Продукт не найден');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка загрузки: $e');
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: ResponsiveUtils.getResponsiveMargin(context, all: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<CartProvider, FavoritesProvider>(
        builder: (context, cartProvider, favoritesProvider, child) {
          final isFavorite = favoritesProvider.isFavorite(product!.id);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(isFavorite, favoritesProvider),
                SliverPadding(
                  padding: ResponsiveUtils.getResponsivePadding(
                    context,
                    all: 20,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfo(),
                          SizedBox(height: 24),
                          _buildRatingSection(),
                          SizedBox(height: 24),
                          _buildOptionsSection(),
                          SizedBox(height: 24),
                          _buildQuantitySection(),
                          SizedBox(height: 24),
                          _buildDescriptionSection(),
                          SizedBox(height: 100), // Space for floating button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar(
    bool isFavorite,
    FavoritesProvider favoritesProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product!.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.network(
              product!.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      leading: Container(
        margin: ResponsiveUtils.getResponsiveMargin(context, all: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: ResponsiveUtils.getResponsiveMargin(context, all: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : AppColors.textLight,
            ),
            onPressed: () async {
              await favoritesProvider.toggleFavorite(context, product!.id);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.title,
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          product!.author,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 16),
        Text(
          AppUtils.formatPrice(product!.price),
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context, all: 8),
            decoration: BoxDecoration(
              color: Color(0xFFFFD700).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product!.rating.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Рейтинг товара',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    if (product!.options.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Варианты',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product!.options.map((option) {
            final isSelected = selectedOption == option;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = option;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 0 : 0.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  option,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Количество',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () {
                        setState(() {
                          quantity--;
                        });
                      }
                    : null,
                icon: Icon(Icons.remove, color: AppColors.onSurface),
              ),
              Container(
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  horizontal: 16,
                ),
                child: Text(
                  quantity.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon: Icon(Icons.add, color: AppColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: ResponsiveUtils.getResponsivePadding(context, all: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product!.description,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
                maxLines: isDescriptionExpanded ? null : 3,
                overflow: isDescriptionExpanded ? null : TextOverflow.ellipsis,
              ),
              if (product!.description.length > 100) ...[
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionExpanded = !isDescriptionExpanded;
                    });
                  },
                  child: Text(
                    isDescriptionExpanded ? 'Свернуть' : 'Показать больше',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingAddButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          width: double.infinity,
          margin: ResponsiveUtils.getResponsiveMargin(context, horizontal: 20),
          child: ElevatedButton(
            onPressed: () async {
              final success = await cartProvider.addToCart(
                context,
                product!,
                selectedOption,
                quantity,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Товар добавлен в корзину',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: ResponsiveUtils.getResponsiveMargin(
                      context,
                      all: 16,
                    ),
                  ),
                );
              } else {
                _showErrorSnackBar('Ошибка при добавлении в корзину');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: ResponsiveUtils.getResponsivePadding(
                context,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Добавить в корзину • ${AppUtils.formatPrice(product!.price * quantity)}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
