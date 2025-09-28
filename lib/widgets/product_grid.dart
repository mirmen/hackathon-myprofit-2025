import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../utils/responsive_system.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridCount = ResponsiveSystem.getGridCount(context);
    final spacing = ResponsiveSystem.spacingMedium(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio:
            ResponsiveSystem.getGridItemWidth(context) /
            (ResponsiveSystem.getGridItemWidth(context) *
                1.2), // Адаптивное соотношение
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}
