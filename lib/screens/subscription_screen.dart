import 'package:coffeebook/models/subscription.dart';
import 'package:coffeebook/providers/subscriptions_provider.dart';
import 'package:coffeebook/providers/user_provider.dart';
import 'package:coffeebook/theme/app_theme.dart';
import 'package:coffeebook/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionsProvider>().loadSubscriptionPlans();
    });
  }

  void _subscribeToPlan(String planId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Подтвердить подписку',
          style: GoogleFonts.manrope(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите оформить эту подписку?',
          style: GoogleFonts.manrope(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: GoogleFonts.manrope(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<SubscriptionsProvider>()
                  .subscribeToPlan(planId);
              if (success) {
                // Reload user data to update subscriptions
                await context.read<UserProvider>().loadUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Подписка успешно оформлена!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка при оформлении подписки'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(
              'Подтвердить',
              style: GoogleFonts.manrope(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsProvider = context.watch<SubscriptionsProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 350;
    final padding = width < 350 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          'Абонементы на кофе',
          style: GoogleFonts.manrope(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              isSmallScreen ? 16 : 18,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: subscriptionsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите абонемент на кофе',
                    style: GoogleFonts.manrope(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        isSmallScreen ? 16 : 18,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: padding),
                  Text(
                    'Абонементы действуют в течение 30 дней с момента активации',
                    style: GoogleFonts.manrope(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        isSmallScreen ? 12 : 14,
                      ),
                      color: AppColors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: padding * 1.5),
                  if (subscriptionsProvider.subscriptionPlans.isEmpty)
                    Center(
                      child: Text(
                        'Абонементы временно недоступны',
                        style: GoogleFonts.manrope(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            16,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            subscriptionsProvider.subscriptionPlans.length,
                        itemBuilder: (context, index) {
                          final plan =
                              subscriptionsProvider.subscriptionPlans[index];
                          final isActive =
                              user?.activeSubscriptions.contains(plan.id) ??
                              false;
                          return _buildSubscriptionCard(
                            plan: plan,
                            isActive: isActive,
                            isSmallScreen: isSmallScreen,
                            onTap: () => _subscribeToPlan(plan.id),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubscriptionCard({
    required SubscriptionPlan plan,
    required bool isActive,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSpacing.responsive(context, AppSpacing.medium),
        ),
      ),
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isActive ? null : onTap,
        borderRadius: BorderRadius.circular(
          AppSpacing.responsive(context, AppSpacing.medium),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.title,
                    style: GoogleFonts.manrope(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        isSmallScreen ? 18 : 20,
                      ),
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (plan.isPopular)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Популярный',
                        style: GoogleFonts.manrope(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            isSmallScreen ? 10 : 12,
                          ),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${plan.cups} чашек в месяц',
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 14 : 16,
                  ),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              if (plan.description != null)
                Text(
                  plan.description!,
                  style: GoogleFonts.manrope(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                      context,
                      isSmallScreen ? 12 : 14,
                    ),
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
                ),
              SizedBox(height: 8),
              Text(
                'Включает:',
                style: GoogleFonts.manrope(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    isSmallScreen ? 14 : 16,
                  ),
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 4),
              ...plan.includedDrinks.map(
                (drink) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        drink,
                        style: GoogleFonts.manrope(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            isSmallScreen ? 12 : 14,
                          ),
                          color: AppColors.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.price,
                    style: GoogleFonts.manrope(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        isSmallScreen ? 18 : 20,
                      ),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        'Активен',
                        style: GoogleFonts.manrope(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            isSmallScreen ? 12 : 14,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.responsive(context, AppSpacing.small),
                          ),
                        ),
                      ),
                      child: Text(
                        'Оформить',
                        style: GoogleFonts.manrope(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            isSmallScreen ? 12 : 14,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
