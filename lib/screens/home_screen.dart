import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/cached_image_widget.dart';
import '../utils/app_utils.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AuthScreen()),
        );
        return;
      }
      context.read<ProductProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  Future<void> _refresh() async {
    await context.read<ProductProvider>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = AppUtils.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Каталог",
          style: GoogleFonts.manrope(
            fontSize: AppUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(4);
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            if (productProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (productProvider.allProducts.isEmpty) {
              return Center(
                child: Text(
                  'Нет продуктов',
                  style: GoogleFonts.manrope(fontSize: 16),
                ),
              );
            }

            // Поиск
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Поиск...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) =>
                          productProvider.setSearchQuery(query),
                    ),
                  ),
                  // Категории
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = productProvider.categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected:
                                productProvider.selectedCategory == category,
                            onSelected: (_) =>
                                productProvider.setCategory(category),
                          ),
                        );
                      },
                    ),
                  ),
                  // Featured
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Рекомендуемое',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productProvider.getFeaturedProducts().length,
                      itemBuilder: (context, index) {
                        final product = productProvider
                            .getFeaturedProducts()[index];
                        // ProductCard или ваш виджет
                        return SizedBox(
                          width: 150,
                          child: ProductCard(product: product),
                        ); // Предполагаю, что вы адаптировали ProductCard для Product
                      },
                    ),
                  ),
                  // New
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Новинки',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productProvider.getNewProducts().length,
                      itemBuilder: (context, index) {
                        final product = productProvider.getNewProducts()[index];
                        return SizedBox(
                          width: 150,
                          child: ProductCard(product: product),
                        );
                      },
                    ),
                  ),
                  // All products grid
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Все товары',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return ProductCard(
                        product: product,
                      ); // Адаптируйте ProductCard для Product object
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
