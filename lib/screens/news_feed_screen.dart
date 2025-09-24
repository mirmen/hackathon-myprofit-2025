import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/promotions_provider.dart';
import '../models/promotion.dart';
import '../utils/app_utils.dart';
import '../utils/cached_image_widget.dart';

class NewsFeedScreen extends StatefulWidget {
  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionsProvider>().loadPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Новости и акции',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<PromotionsProvider>(
        builder: (context, promotionsProvider, child) {
          if (promotionsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Categories
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: promotionsProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = promotionsProvider.categories[index];
                    final isSelected =
                        promotionsProvider.selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) =>
                            promotionsProvider.setCategory(category),
                      ),
                    );
                  },
                ),
              ),

              // Promotions list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => promotionsProvider.loadPromotions(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: promotionsProvider.promotions.length,
                    itemBuilder: (context, index) {
                      final promotion = promotionsProvider.promotions[index];
                      return PromotionCard(promotion: promotion);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({Key? key, required this.promotion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promotion.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedImageWidget(
                imageUrl: promotion.imageUrl!,
                width: double.infinity,
                height: 200,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        promotion.category,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppUtils.timeAgo(promotion.createdAt),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  promotion.title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promotion.subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.primaryColor,
                  ),
                ),
                if (promotion.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    promotion.description!,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
