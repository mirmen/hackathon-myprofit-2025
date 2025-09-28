import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  // Добавляем методы для responsive размеров из home_screen.dart
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Используем responsive размеры
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        // Адаптивные размеры
        final imageHeight = cardHeight * 0.55; // Чуть больше для изображения
        final titleSize = _fontSize(context, 1.3); // ~9-10 px
        final authorSize = _fontSize(context, 1.1); // ~8-9 px
        final priceSize = _fontSize(context, 1.3); // ~9-10 px
        final ratingSize = _fontSize(context, 1.0); // ~7-8 px

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productId: product.id),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_borderRadius(context, 2)),
              border: Border.all(color: AppColors.divider, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: _spacing(context, 0.5),
                  offset: Offset(0, _spacing(context, 0.25)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Секция изображения
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(_borderRadius(context, 2)),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[200]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: imageHeight,
                                color: Colors.grey[200],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                color: AppUtils.getColorForProductType(
                                  product.type,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(
                                    _borderRadius(context, 2),
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      AppUtils.getIconForProductType(
                                        product.type,
                                      ),
                                      size: _iconSize(context, 2),
                                      color: AppUtils.getColorForProductType(
                                        product.type,
                                      ),
                                    ),
                                    SizedBox(height: _spacing(context, 0.5)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: _spacing(context, 1),
                                      ),
                                      child: Text(
                                        product.title,
                                        style: GoogleFonts.montserrat(
                                          fontSize: authorSize,
                                          fontWeight: FontWeight.w500,
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
                          },
                        ),
                      ),
                      // Бейдж "NEW"
                      if (DateTime.now().difference(product.createdAt).inDays <=
                          7)
                        Positioned(
                          top: _spacing(context, 1),
                          left: _spacing(context, 1),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _spacing(context, 0.8),
                              vertical: _spacing(context, 0.4),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                _borderRadius(context, 0.8),
                              ),
                            ),
                            child: Text(
                              'NEW',
                              style: GoogleFonts.montserrat(
                                fontSize: ratingSize * 0.8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Секция контента
                Padding(
                  padding: EdgeInsets.all(_spacing(context, 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: GoogleFonts.montserrat(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _spacing(context, 0.3)),
                      Text(
                        product.author,
                        style: GoogleFonts.montserrat(
                          fontSize: authorSize,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _spacing(context, 0.3)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppUtils.formatPrice(product.price),
                            style: GoogleFonts.montserrat(
                              fontSize: priceSize,
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
                                Icons.star,
                                color: AppConstants.goldColor,
                                size: _iconSize(context, 1.2),
                              ),
                              SizedBox(width: _spacing(context, 0.3)),
                              Text(
                                AppUtils.formatRating(product.rating),
                                style: GoogleFonts.montserrat(
                                  fontSize: ratingSize,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface,
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
      },
    );
  }
}
