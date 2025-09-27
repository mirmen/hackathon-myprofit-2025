import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../utils/app_utils.dart';
import '../models/product.dart';

/// Провайдер для управления корзиной покупок
/// Обрабатывает добавление, удаление, обновление количества товаров в корзине
class CartProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список товаров в корзине
  List<CartItem> _cartItems = [];

  /// Флаг загрузки данных корзины
  bool _isLoading = false;

  /// Геттер для проверки состояния загрузки
  bool get isLoading => _isLoading;

  /// Геттеры для доступа к данным корзины
  List<CartItem> get cartItems => _cartItems;

  /// Общее количество товаров в корзине
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Общая стоимость товаров в корзине
  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  /// Загрузка корзины текущего пользователя из базы данных
  /// Проверяет авторизацию и загружает актуальные данные
  Future<void> loadCart() async {
    // Если пользователь не авторизован, очищаем корзину
    if (_client.auth.currentUser == null) {
      if (_cartItems.isNotEmpty) {
        _cartItems = [];
        notifyListeners();
      }
      return;
    }

    final wasLoading = _isLoading;
    _isLoading = true;
    if (!wasLoading) {
      notifyListeners();
    }

    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId);
      final newItems = response.map((json) => CartItem.fromJson(json)).toList();

      // Обновляем только если данные действительно изменились
      // Это предотвращает ненужные перерисовки интерфейса
      bool itemsChanged = !const ListEquality().equals(_cartItems, newItems);
      if (itemsChanged) {
        _cartItems = newItems;
      }

      _isLoading = false;

      // Уведомляем слушателей только если состояние изменилось
      if (wasLoading || itemsChanged) {
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка при загрузке корзины: $e');
      bool hadItems = _cartItems.isNotEmpty;
      if (hadItems) {
        _cartItems = [];
      }
      _isLoading = false;

      // Уведомляем только если было изменение
      if (wasLoading || hadItems) {
        notifyListeners();
      }
    }
  }

  /// Добавление товара в корзину
  /// @param context - контекст для проверки аутентификации
  /// @param product - продукт для добавления
  /// @param selectedOption - выбранная опция продукта
  /// @param quantity - количество товара
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addToCart(
    BuildContext context,
    Product product,
    String selectedOption,
    int quantity,
  ) async {
    // Проверяем аутентификацию перед добавлением
    if (!AppUtils.isUserAuthenticated(context)) {
      final authResult = await AppUtils.requireAuthentication(
        context,
        title: 'Добавление в корзину',
        message: 'Для добавления товаров в корзину необходимо войти в аккаунт',
      );
      if (!authResult) {
        return false;
      }
      // Перезагружаем корзину после аутентификации
      await loadCart();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      // Проверяем, существует ли уже такой товар с такой опцией в корзине
      final existingResponse = await _client
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', userId)
          .eq('product_id', product.id)
          .eq('selected_option', selectedOption)
          .maybeSingle();

      if (existingResponse != null) {
        // Если товар уже есть, увеличиваем количество
        await _client
            .from('cart_items')
            .update({'quantity': existingResponse['quantity'] + quantity})
            .eq('id', existingResponse['id']);
      } else {
        // Если товара нет, добавляем новый элемент
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
      print('Ошибка при добавлении в корзину: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Удаление товара из корзины
  /// @param itemId - ID элемента корзины для удаления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> removeFromCart(String itemId) async {
    // Проверяем авторизацию
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _client.from('cart_items').delete().eq('id', itemId);
      await loadCart();
      return true;
    } catch (e) {
      print('Ошибка при удалении из корзины: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновление количества товара в корзине
  /// @param itemId - ID элемента корзины для обновления
  /// @param newQuantity - новое количество товара
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updateQuantity(String itemId, int newQuantity) async {
    // Проверяем авторизацию
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Если количество <= 0, удаляем товар из корзины
      if (newQuantity <= 0) {
        return await removeFromCart(itemId);
      }
      // Обновляем количество товара
      await _client
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', itemId);
      await loadCart();
      return true;
    } catch (e) {
      print('Ошибка при обновлении количества: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очистка всей корзины
  /// @return true если успешно, false если произошла ошибка
  Future<bool> clearCart() async {
    // Проверяем авторизацию
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      // Удаляем все элементы корзины текущего пользователя
      await _client.from('cart_items').delete().eq('user_id', userId);
      _cartItems.clear();
      return true;
    } catch (e) {
      print('Ошибка при очистке корзины: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
