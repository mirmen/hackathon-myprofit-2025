import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CartItem> get cartItems => _cartItems;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId);
      _cartItems = response.map((json) => CartItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(
    Product product,
    String selectedOption,
    int quantity,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      final existingResponse = await _client
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', userId)
          .eq('product_id', product.id)
          .eq('selected_option', selectedOption)
          .maybeSingle();

      if (existingResponse != null) {
        await _client
            .from('cart_items')
            .update({'quantity': existingResponse['quantity'] + quantity})
            .eq('id', existingResponse['id']);
      } else {
        await _client.from('cart_items').insert({
          'user_id': userId,
          'product_id': product.id,
          'title': product.title,
          'author': product.author,
          'type': product.type,
          'price': product.price,
          'image_url': product.imageUrl,
          'selected_option': selectedOption,
          'quantity': quantity,
        });
      }
      await loadCart();
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromCart(String itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.from('cart_items').delete().eq('id', itemId);
      await loadCart();
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuantity(String itemId, int newQuantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (newQuantity <= 0) {
        return await removeFromCart(itemId);
      }
      await _client
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', itemId);
      await loadCart();
      return true;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('cart_items').delete().eq('user_id', userId);
      _cartItems.clear();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInCart(String productId, String selectedOption) {
    return _cartItems.any(
      (item) =>
          item.productId == productId && item.selectedOption == selectedOption,
    );
  }

  CartItem? getCartItem(String productId, String selectedOption) {
    try {
      return _cartItems.firstWhere(
        (item) =>
            item.productId == productId &&
            item.selectedOption == selectedOption,
      );
    } catch (e) {
      return null;
    }
  }

  void updateCartItems(List<CartItem> items) {
    _cartItems = items;
    notifyListeners();
  }
}
