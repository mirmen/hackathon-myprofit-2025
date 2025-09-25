import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/cached_image_widget.dart';
import '../utils/app_utils.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid.dart';
import 'product_detail_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Все';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();

      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<CartProvider>().loadCart();
        context.read<FavoritesProvider>().loadFavorites();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<ProductProvider>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return _buildLoadingState();
              }
              if (productProvider.allProducts.isEmpty) {
                return _buildEmptyState(productProvider);
              }

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(),
                  _buildSearchSection(),
                  _buildFeaturedSection(productProvider),
                  _buildOrganizedCategoriesSection(productProvider),
                  _buildNewProductsSection(productProvider),
                  _buildAllProductsSection(productProvider),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveUtils.heightPercentage(context, 12),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: ResponsiveUtils.getAppBarHeight(context),
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: ResponsiveUtils.getResponsivePadding(
          context,
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Каталог',
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsivePadding(context, 4),
                  ),
                  Text(
                    'Откройте мир кофе',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            // Keep only one action button in the app bar
            Container(
              margin: EdgeInsets.only(
                right: ResponsiveUtils.responsivePadding(context, 8),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
                icon: Container(
                  padding: ResponsiveUtils.getResponsivePadding(
                    context,
                    all: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.responsivePadding(context, 12),
                    ),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.onSurface,
                    size: ResponsiveUtils.responsiveIconSize(context, 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverPadding(
      padding: ResponsiveUtils.getResponsiveMargin(
        context,
        horizontal: 16,
        vertical: 12,
      ),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getPadding(
                context,
                small: 12,
                medium: 14,
                large: 16,
                extraLarge: 18,
              ),
            ),
            border: Border.all(color: AppColors.divider, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Поиск кофе, книг...',
              prefixIcon: Padding(
                padding: ResponsiveUtils.getResponsivePadding(context, all: 12),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: ResponsiveUtils.responsiveIconSize(context, 22),
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.textLight,
                        size: ResponsiveUtils.responsiveIconSize(context, 20),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ProductProvider>().setSearchQuery('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: ResponsiveUtils.getResponsiveMargin(
                context,
                horizontal: 18,
                vertical: 14,
              ),
            ),
            onChanged: (query) {
              context.read<ProductProvider>().setSearchQuery(query);
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizedCategoriesSection(ProductProvider productProvider) {
    // Group products by type
    final Map<String, List<Product>> productsByType = {};
    for (var product in productProvider.allProducts) {
      if (!productsByType.containsKey(product.type)) {
        productsByType[product.type] = [];
      }
      productsByType[product.type]!.add(product);
    }

    // Map categories to icons
    final categoryIcons = {
      'Кофе': Icons.local_cafe_rounded,
      'Книги': Icons.menu_book_rounded,
      'Десерты': Icons.cake_rounded,
    };

    return SliverPadding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.responsivePadding(context, 24),
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(
                context,
                horizontal: 20,
              ),
              child: Text(
                'Категории',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
            ...productsByType.entries.map((entry) {
              final type = entry.key;
              final products = entry.value;
              final icon = categoryIcons[type] ?? Icons.category_rounded;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: ResponsiveUtils.getResponsivePadding(
                      context,
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: AppColors.primary,
                          size: ResponsiveUtils.responsiveIconSize(context, 20),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.responsivePadding(context, 8),
                        ),
                        Text(
                          type,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            productProvider.setCategory(type);
                          },
                          child: Text(
                            'Смотреть всё',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsivePadding(context, 12),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSize(context, 240),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: ResponsiveUtils.getResponsivePadding(
                        context,
                        horizontal: 20,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: ResponsiveUtils.responsivePadding(
                              context,
                              16,
                            ),
                          ),
                          child: SizedBox(
                            width: ResponsiveUtils.responsiveSize(context, 180),
                            child: ProductCard(product: products[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsivePadding(context, 24),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(ProductProvider productProvider) {
    final featuredProducts = productProvider.getFeaturedProducts();
    if (featuredProducts.isEmpty)
      return SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.responsivePadding(context, 32),
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(
                context,
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Рекомендуемое',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Смотреть всё',
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
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
            SizedBox(
              height: ResponsiveUtils.responsiveSize(context, 240),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  horizontal: 20,
                ),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: ResponsiveUtils.responsivePadding(context, 16),
                    ),
                    child: SizedBox(
                      width: ResponsiveUtils.responsiveSize(context, 180),
                      child: ProductCard(product: featuredProducts[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewProductsSection(ProductProvider productProvider) {
    final newProducts = productProvider.getNewProducts();
    if (newProducts.isEmpty)
      return SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.responsivePadding(context, 32),
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(
                context,
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Новинки',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Смотреть всё',
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
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
            SizedBox(
              height: ResponsiveUtils.responsiveSize(context, 240),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  horizontal: 20,
                ),
                itemCount: newProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: ResponsiveUtils.responsivePadding(context, 16),
                    ),
                    child: SizedBox(
                      width: ResponsiveUtils.responsiveSize(context, 180),
                      child: ProductCard(product: newProducts[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProductsSection(ProductProvider productProvider) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.responsivePadding(context, 32),
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(
                context,
                horizontal: 20,
              ),
              child: Text(
                'Все товары',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(
                context,
                horizontal: 20,
              ),
              child: ProductGrid(
                products: productProvider.products,
                screenWidth: MediaQuery.of(context).size.width,
                screenHeight: MediaQuery.of(context).size.height,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: ResponsiveUtils.responsiveSize(context, 3),
          ),
          SizedBox(height: ResponsiveUtils.responsivePadding(context, 16)),
          Text(
            'Загрузка каталога...',
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ProductProvider productProvider) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context, all: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context, all: 24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: ResponsiveUtils.responsiveIconSize(context, 64),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 24)),
            Text(
              'Каталог пуст',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 8)),
            Text(
              'Проверьте подключение к интернету\nи наличие данных в базе',
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.responsivePadding(context, 32)),
            ElevatedButton.icon(
              onPressed: () => productProvider.loadProducts(),
              icon: Icon(
                Icons.refresh,
                size: ResponsiveUtils.responsiveIconSize(context, 20),
              ),
              label: Text('Обновить'),
              style: ElevatedButton.styleFrom(
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
