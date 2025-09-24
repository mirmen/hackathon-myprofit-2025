// cart_screen.dart (исправленная версия)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/cart_item.dart';
import '../utils/app_utils.dart';
import '../utils/cached_image_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Stream<List<Map<String, dynamic>>>? _cartStream;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      context.read<CartProvider>().loadCart();
      _cartStream = Supabase.instance.client
          .from('cart_items')
          .stream(primaryKey: ['id'])
          .eq('user_id', authProvider.currentUser!.id);
    } else {
      // Handle not authenticated user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppUtils.showErrorSnackBar(
          context,
          'Авторизуйтесь для просмотра корзины',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Корзина",
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await AppUtils.showConfirmDialog(
                      context,
                      title: "Очистить корзину",
                      content:
                          "Вы уверены, что хотите удалить все товары из корзины?",
                    );
                    if (confirmed == true) {
                      await cartProvider.clearCart();
                      AppUtils.showSnackBar(context, "Корзина очищена");
                    }
                  },
                  tooltip: "Очистить корзину",
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart(context);
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _cartStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                AppUtils.showErrorSnackBar(context, 'Ошибка загрузки корзины');
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                final items = snapshot.data!
                    .map((json) => CartItem.fromJson(json))
                    .toList();
                cartProvider.updateCartItems(items);
              }
              return _buildCartWithItems(cartProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Здесь пока пусто",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Добавьте товары в корзину из каталога",
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () => DefaultTabController.of(context).animateTo(0),
                child: Text(
                  "В КАТАЛОГ",
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartWithItems(CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartProvider.cartItems[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) =>
                    cartProvider.removeFromCart(item.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    child: Row(
                      children: [
                        ProductCachedImage(
                          imageUrl: item.imageUrl,
                          productType: item.type,
                          width: AppUtils.isSmallScreen(context) ? 60 : 80,
                          height: AppUtils.isSmallScreen(context) ? 60 : 80,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius - 4,
                          ),
                        ),
                        SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.manrope(
                                  fontSize: AppUtils.getResponsiveFontSize(
                                    context,
                                    14,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.author,
                                style: GoogleFonts.manrope(
                                  fontSize: AppUtils.getResponsiveFontSize(
                                    context,
                                    12,
                                  ),
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.selectedOption,
                                style: GoogleFonts.manrope(
                                  fontSize: AppUtils.getResponsiveFontSize(
                                    context,
                                    12,
                                  ),
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppUtils.formatPrice(item.totalPrice),
                                style: GoogleFonts.manrope(
                                  fontSize: AppUtils.getResponsiveFontSize(
                                    context,
                                    16,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, size: 24),
                              onPressed: () => cartProvider.updateQuantity(
                                item.id,
                                item.quantity + 1,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, size: 24),
                              onPressed: () => cartProvider.updateQuantity(
                                item.id,
                                item.quantity - 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Итого',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppUtils.formatPrice(cartProvider.totalPrice),
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: cartProvider.isLoading
                      ? null
                      : () {
                          _showOrderConfirmation(cartProvider);
                        },
                  child: cartProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "ОФОРМИТЬ ЗАКАЗ",
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOrderConfirmation(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Подтверждение заказа",
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Оформить заказ на ${AppUtils.formatPrice(cartProvider.totalPrice)}?",
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Logic for order creation
              final client = Supabase.instance.client;
              final orderData = {
                'user_id': client.auth.currentUser!.id,
                'items': jsonEncode(
                  cartProvider.cartItems.map((e) => e.toJson()).toList(),
                ),
                'total_price': cartProvider.totalPrice,
                'status': 'pending',
              };
              // Uncomment when orders table is created
              // await client.from('orders').insert(orderData);
              await cartProvider.clearCart();
              AppUtils.showSuccessSnackBar(
                context,
                "Заказ оформлен! Сумма: ${AppUtils.formatPrice(cartProvider.totalPrice)}",
              );
            },
            child: const Text("Оформить"),
          ),
        ],
      ),
    );
  }
}
