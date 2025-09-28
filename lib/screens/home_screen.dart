import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/event.dart';
import '../models/promotion.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../providers/promotions_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';
import '../utils/cached_image_widget.dart';
import 'product_detail_screen.dart';
import 'auth_screen.dart';
import 'category_products_screen.dart';
import 'collection_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<PromotionsProvider>().loadPromotions();
      context.read<EventsProvider>().loadEvents();

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

  // Единая система измерений
  double _getBaseUnit(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide * 0.02;
  }

  double _spacing(BuildContext context, double multiplier) {
    return _getBaseUnit(context) * multiplier;
  }

  double _fontSize(BuildContext context, double multiplier) {
    return _getBaseUnit(context) * multiplier;
  }

  double _iconSize(BuildContext context, double multiplier) {
    return _getBaseUnit(context) * multiplier;
  }

  double _borderRadius(BuildContext context, double multiplier) {
    return _getBaseUnit(context) * multiplier;
  }

  int _getGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              _buildSearchSection(),
              _buildSpeciallyForYouSection(),
              _buildCollectionsSection(),
              _buildCategoriesSection(),
              _buildEventsSection(),
              _buildNewsFeedExcerpt(),
            ],
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
      toolbarHeight: _spacing(context, 12),
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _spacing(context, 4),
          vertical: _spacing(context, 2),
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
                      fontSize: _fontSize(context, 2.6),
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: _spacing(context, 0.5)),
                  Text(
                    'Откройте мир кофе',
                    style: GoogleFonts.montserrat(
                      fontSize: _fontSize(context, 1.4),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Container(
                  margin: EdgeInsets.only(right: _spacing(context, 2)),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(_spacing(context, 1.5)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            _borderRadius(context, 3),
                          ),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: _spacing(context, 1),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.onSurface,
                          size: _iconSize(context, 2),
                        ),
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(_spacing(context, 0.8)),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: GoogleFonts.montserrat(
                                fontSize: _fontSize(context, 1),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: _spacing(context, 2),
        vertical: _spacing(context, 1),
      ),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(_borderRadius(context, 2)),
            border: Border.all(color: AppColors.divider, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: _spacing(context, 1),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.montserrat(
              fontSize: _fontSize(context, 1.5),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Поиск кофе, книг...',
              hintStyle: GoogleFonts.montserrat(
                fontSize: _fontSize(context, 1.5),
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(_spacing(context, 1)),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: _iconSize(context, 2.2),
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.textLight,
                        size: _iconSize(context, 2),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ProductProvider>().setSearchQuery('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: _spacing(context, 2),
                vertical: _spacing(context, 1.5),
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

  Widget _buildCategoriesSection() {
    final productProvider = context.watch<ProductProvider>();
    final Set<String> uniqueTypes = productProvider.allProducts
        .map((product) => product.type)
        .toSet();

    final categories = uniqueTypes.map((type) {
      return {'name': type, 'icon': _getIconForType(type)};
    }).toList();

    return SliverPadding(
      padding: EdgeInsets.all(_spacing(context, 2)),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Категории'),
            SizedBox(height: _spacing(context, 2)),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getGridCount(context),
                crossAxisSpacing: _spacing(context, 1.5),
                mainAxisSpacing: _spacing(context, 1.5),
                childAspectRatio: 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  category['name'] as String,
                  category['icon'] as IconData,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(categoryName: name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_borderRadius(context, 2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _spacing(context, 0.5),
              offset: Offset(0, _spacing(context, 0.25)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(_spacing(context, 2)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: _iconSize(context, 3),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: _spacing(context, 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _spacing(context, 1)),
              child: Text(
                name,
                style: GoogleFonts.montserrat(
                  fontSize: _fontSize(context, 1.3),
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    final eventsProvider = context.watch<EventsProvider>();
    final upcomingEvents = eventsProvider.events
        .where((event) => event.dateTime.isAfter(DateTime.now()))
        .take(5)
        .toList();

    if (upcomingEvents.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.all(_spacing(context, 2)),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Мероприятия', onSeeAll: () {}),
            SizedBox(height: _spacing(context, 1.5)),
            SizedBox(
              height: _spacing(context, 15),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingEvents.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(upcomingEvents[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      width: _spacing(context, 28),
      margin: EdgeInsets.only(right: _spacing(context, 1.5)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_borderRadius(context, 2)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: EdgeInsets.all(_spacing(context, 1.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEventTypeIcon(event.eventType),
                  color: AppColors.primary,
                  size: _iconSize(context, 2),
                ),
                SizedBox(width: _spacing(context, 1)),
                Expanded(
                  child: Text(
                    event.title,
                    style: GoogleFonts.montserrat(
                      fontSize: _fontSize(context, 1.6),
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: _spacing(context, 1)),
            Text(
              event.description,
              style: GoogleFonts.montserrat(
                fontSize: _fontSize(context, 1.4),
                color: AppColors.textLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: _iconSize(context, 1.6),
                  color: AppColors.textLight,
                ),
                SizedBox(width: _spacing(context, 0.5)),
                Text(
                  _formatEventDate(event.dateTime),
                  style: GoogleFonts.montserrat(
                    fontSize: _fontSize(context, 1.2),
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                if (event.location != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: _iconSize(context, 1.6),
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: _spacing(context, 0.5)),
                      Text(
                        event.location!,
                        style: GoogleFonts.montserrat(
                          fontSize: _fontSize(context, 1.2),
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsFeedExcerpt() {
    final promotionsProvider = context.watch<PromotionsProvider>();
    final latestPromotions = promotionsProvider.promotions.take(3).toList();

    if (latestPromotions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.all(_spacing(context, 2)),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Новости и акции',
              onSeeAll: () {
                Navigator.pushNamed(context, '/news_feed');
              },
            ),
            SizedBox(height: _spacing(context, 1.5)),
            Column(
              children: latestPromotions.map((promotion) {
                return _buildPromotionExcerpt(promotion);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionExcerpt(Promotion promotion) {
    return Container(
      margin: EdgeInsets.only(bottom: _spacing(context, 1.5)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_borderRadius(context, 2)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: EdgeInsets.all(_spacing(context, 1.5)),
        child: Row(
          children: [
            Container(
              width: _spacing(context, 6),
              height: _spacing(context, 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_borderRadius(context, 1)),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: AppColors.primary,
                size: _iconSize(context, 3),
              ),
            ),
            SizedBox(width: _spacing(context, 1.5)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _spacing(context, 1),
                      vertical: _spacing(context, 0.3),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        _borderRadius(context, 0.5),
                      ),
                    ),
                    child: Text(
                      promotion.category,
                      style: GoogleFonts.montserrat(
                        fontSize: _fontSize(context, 1),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: _spacing(context, 0.5)),
                  Text(
                    promotion.title,
                    style: GoogleFonts.montserrat(
                      fontSize: _fontSize(context, 1.4),
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _spacing(context, 0.3)),
                  Text(
                    promotion.subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: _fontSize(context, 1.2),
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciallyForYouSection() {
    final productProvider = context.watch<ProductProvider>();
    final Set<String> uniqueTypes = productProvider.allProducts
        .map((product) => product.type)
        .toSet();

    final List<Product> featuredProducts = [];
    for (var type in uniqueTypes) {
      final productsOfType = productProvider.allProducts
          .where((product) => product.type == type)
          .toList();

      if (productsOfType.isNotEmpty) {
        featuredProducts.add(productsOfType.first);
      }
      if (featuredProducts.length >= 4) break;
    }

    if (featuredProducts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.all(_spacing(context, 2)),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Специально для вас'),
            SizedBox(height: _spacing(context, 1.5)),
            SizedBox(
              height: _spacing(context, 18.5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedProductCard(featuredProducts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        width: 150.0,
        margin: const EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Фиксированная секция изображения
            Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
              ),
              child: product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              _getIconForType(product.type),
                              size: 20.0,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        _getIconForType(product.type),
                        size: 20.0,
                        color: AppColors.primary,
                      ),
                    ),
            ),

            // Компактная секция контента
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Название продукта
                  Text(
                    product.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.0),

                  // Автор
                  Text(
                    product.author,
                    style: GoogleFonts.montserrat(
                      fontSize: 9.0,
                      color: AppColors.textLight,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4.0),

                  // Цена и рейтинг
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} ₽',
                        style: GoogleFonts.montserrat(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 10.0,
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: GoogleFonts.montserrat(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsSection() {
    final collections = [
      {'name': 'Фэнтези', 'icon': Icons.auto_stories},
      {'name': 'Детективы', 'icon': Icons.search},
      {'name': 'Классика', 'icon': Icons.menu_book},
      {'name': 'Кофе', 'icon': Icons.local_cafe},
    ];

    return SliverPadding(
      padding: EdgeInsets.all(_spacing(context, 2)),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Подборки по жанрам'),
            SizedBox(height: _spacing(context, 1.5)),
            SizedBox(
              height: _spacing(context, 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return _buildCollectionCard(
                    collection['name'] as String,
                    collection['icon'] as IconData,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetailScreen(
              collectionName: name,
              collectionType: 'books',
            ),
          ),
        );
      },
      child: Container(
        width: _spacing(context, 14),
        margin: EdgeInsets.only(right: _spacing(context, 1.5)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_borderRadius(context, 2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _spacing(context, 0.5),
              offset: Offset(0, _spacing(context, 0.25)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(_spacing(context, 1.5)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: _iconSize(context, 3),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: _spacing(context, 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _spacing(context, 1)),
              child: Text(
                name,
                style: GoogleFonts.montserrat(
                  fontSize: _fontSize(context, 1.3),
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            SizedBox(height: _spacing(context, 0.5)),
            Text(
              'Топ-10',
              style: GoogleFonts.montserrat(
                fontSize: _fontSize(context, 1.1),
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: _fontSize(context, 2.2),
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Все',
              style: GoogleFonts.montserrat(
                fontSize: _fontSize(context, 1.4),
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  // Helper methods
  IconData _getIconForType(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('книга') || typeLower.contains('книги')) {
      return Icons.menu_book_rounded;
    } else if (typeLower.contains('кофе')) {
      return Icons.local_cafe_rounded;
    } else if (typeLower.contains('чай')) {
      return Icons.local_drink_rounded;
    } else if (typeLower.contains('десерт') || typeLower.contains('выпечка')) {
      return Icons.cake_rounded;
    } else if (typeLower.contains('мероприятие')) {
      return Icons.event_rounded;
    } else if (typeLower.contains('подар') || typeLower.contains('сувенир')) {
      return Icons.card_giftcard_rounded;
    } else {
      return Icons.category_rounded;
    }
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'workshop':
        return Icons.build_rounded;
      case 'meeting':
        return Icons.groups_rounded;
      case 'competition':
        return Icons.emoji_events_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _formatEventDate(DateTime dateTime) {
    final difference = dateTime.difference(DateTime.now()).inDays;
    if (difference == 0) return 'Сегодня';
    if (difference == 1) return 'Завтра';
    if (difference > 1 && difference <= 7) return 'Через $difference дней';
    return '${dateTime.day}.${dateTime.month}';
  }
}
