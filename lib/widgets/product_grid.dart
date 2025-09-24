// product_grid.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final double screenWidth;

  const ProductGrid({Key? key, required this.products, required this.screenWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = screenWidth > 600
        ? 3
        : screenWidth > 400
        ? 2
        : 2;
    final childAspectRatio = screenWidth > 600
        ? 0.65
        : screenWidth > 400
        ? 0.7
        : 0.72;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 16,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
        );
      },
    );
  }
}
