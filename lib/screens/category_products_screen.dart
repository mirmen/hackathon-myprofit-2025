import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({Key? key, required this.categoryName})
    : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [_buildSliverAppBar(), _buildProductsSection()],
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
      automaticallyImplyLeading: false, // We'll handle leading manually
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.onSurface,
          size: ResponsiveUtils.responsiveIconSize(context, 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: Padding(
        padding: ResponsiveUtils.getResponsivePadding(
          context,
          horizontal: AppSpacing.responsive(context, AppSpacing.medium),
          vertical: ResponsiveUtils.heightPercentage(context, 2),
        ),
        child: Row(
          children: [
            // Add spacing to account for the back button
            SizedBox(width: ResponsiveUtils.responsiveIconSize(context, 30)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.categoryName,
                    style: GoogleFonts.montserrat(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.heightPercentage(context, 1),
                  ),
                  Text(
                    'Все товары категории',
                    style: GoogleFonts.montserrat(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Filter products by category
        final categoryProducts = productProvider.allProducts
            .where((product) => product.type == widget.categoryName)
            .toList();

        if (categoryProducts.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  horizontal: AppSpacing.responsive(context, AppSpacing.large),
                  vertical: AppSpacing.responsive(context, AppSpacing.medium),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: ResponsiveUtils.getResponsivePadding(
                        context,
                        all: AppSpacing.responsive(context, AppSpacing.small),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.category_outlined,
                        size: ResponsiveUtils.responsiveIconSize(context, 48),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.heightPercentage(context, 3),
                    ),
                    Text(
                      'Нет товаров в категории',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          22,
                        ),
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.heightPercentage(context, 1),
                    ),
                    Text(
                      'В этой категории пока нет товаров',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.heightPercentage(context, 4),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Назад к категориям'),
                      style: ElevatedButton.styleFrom(
                        padding: ResponsiveUtils.getResponsivePadding(
                          context,
                          horizontal: AppSpacing.responsive(
                            context,
                            AppSpacing.medium,
                          ),
                          vertical: AppSpacing.responsive(
                            context,
                            AppSpacing.small,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.only(
            top: ResponsiveUtils.heightPercentage(context, 3),
            left: ResponsiveUtils.widthPercentage(context, 5),
            right: ResponsiveUtils.widthPercentage(context, 5),
            bottom: ResponsiveUtils.heightPercentage(context, 5),
          ),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getProductColumnCount(),
              crossAxisSpacing: ResponsiveUtils.widthPercentage(context, 4),
              mainAxisSpacing: ResponsiveUtils.heightPercentage(context, 2),
              childAspectRatio:
                  0.83, // Адаптивное соотношение для гибких карточек
            ),
            itemCount: categoryProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: categoryProducts[index]);
            },
          ),
        );
      },
    );
  }

  int _getProductColumnCount() {
    final mediaQuery = MediaQuery.of(context);
    final deviceWidth = mediaQuery.size.width;

    if (deviceWidth < 360) {
      return 1; // Very small screens
    } else if (deviceWidth < 600) {
      return 2; // Small to medium screens
    } else if (deviceWidth < 900) {
      return 3; // Tablets
    } else {
      return 4; // Large screens
    }
  }
}
