import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.3 : height! * 0.3)
            : 32,
        color: Colors.grey[400],
      ),
    );
  }
}

class ProductCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final String productType;
  final BorderRadius? borderRadius;

  const ProductCachedImage({
    Key? key,
    required this.imageUrl,
    required this.productType,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius,
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _getColorForType(productType),
          borderRadius: borderRadius,
        ),
        child: Icon(
          _getIconForType(productType),
          color: Colors.white,
          size: (width != null && height != null)
              ? (width! < height! ? width! * 0.4 : height! * 0.4)
              : 32,
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'книга':
        return const Color(0xFF8C6A4B);
      case 'кофе':
        return const Color(0xFF6D4C41);
      case 'десерт':
        return const Color(0xFFD7CCC8);
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'книга':
        return Icons.menu_book;
      case 'кофе':
        return Icons.coffee;
      case 'десерт':
        return Icons.cake;
      default:
        return Icons.shopping_bag;
    }
  }
}
