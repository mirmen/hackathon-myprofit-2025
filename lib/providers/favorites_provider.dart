import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_utils.dart';

/// Провайдер для управления избранными товарами
/// Обрабатывает добавление, удаление товаров в избранное
class FavoritesProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Множество ID избранных продуктов
  Set<String> _favoriteProductIds = {};

  /// Флаг загрузки данных избранного
  bool _isLoading = false;

  /// Геттер для проверки состояния загрузки
  bool get isLoading => _isLoading;

  /// Геттер для доступа к ID избранных продуктов
  Set<String> get favoriteProductIds => _favoriteProductIds;

  /// Загрузка списка избранных товаров текущего пользователя
  /// Выполняет запрос к таблице favorites по ID пользователя
  Future<void> loadFavorites() async {
    // Если пользователь не авторизован, очищаем список избранных
    if (_client.auth.currentUser == null) {
      _favoriteProductIds = {};
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId);
      // Преобразуем ответ в множество ID продуктов
      _favoriteProductIds = Set.from(response.map((e) => e['product_id']));
    } catch (e) {
      print('Ошибка при загрузке избранного: $e');
      _favoriteProductIds = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Переключение состояния избранного для товара
  /// Если товар был в избранном - удаляет, если не был - добавляет
  /// @param context - контекст для проверки аутентификации
  /// @param productId - ID продукта для переключения
  /// @return true если успешно, false если произошла ошибка
  Future<bool> toggleFavorite(BuildContext context, String productId) async {
    // Проверяем аутентификацию перед изменением избранного
    if (!AppUtils.isUserAuthenticated(context)) {
      final authResult = await AppUtils.requireAuthentication(
        context,
        title: 'Добавление в избранное',
        message: 'Для добавления в избранное необходимо войти в аккаунт',
      );
      if (!authResult) {
        return false;
      }
      // Перезагружаем избранное после аутентификации
      await loadFavorites();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      if (_favoriteProductIds.contains(productId)) {
        // Если товар уже в избранном, удаляем его
        await _client.from('favorites').delete().match({
          'user_id': userId,
          'product_id': productId,
        });
        _favoriteProductIds.remove(productId);
      } else {
        // Если товара нет в избранном, добавляем его
        await _client.from('favorites').insert({
          'user_id': userId,
          'product_id': productId,
        });
        _favoriteProductIds.add(productId);
      }
      return true;
    } catch (e) {
      print('Ошибка при переключении избранного: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Проверка, находится ли товар в избранном
  /// @param productId - ID продукта для проверки
  /// @return true если товар в избранном, false если нет
  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  /// Добавление товара в избранное
  /// @param context - контекст для проверки аутентификации
  /// @param productId - ID продукта для добавления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addToFavorites(BuildContext context, String productId) async {
    // Проверяем аутентификацию перед добавлением в избранное
    if (!AppUtils.isUserAuthenticated(context)) {
      final authResult = await AppUtils.requireAuthentication(
        context,
        title: 'Добавление в избранное',
        message: 'Для добавления в избранное необходимо войти в аккаунт',
      );
      if (!authResult) {
        return false;
      }
      // Перезагружаем избранное после аутентификации
      await loadFavorites();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });
      _favoriteProductIds.add(productId);
      return true;
    } catch (e) {
      print('Ошибка при добавлении в избранное: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Удаление товара из избранного
  /// @param productId - ID продукта для удаления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> removeFromFavorites(String productId) async {
    // Проверяем авторизацию
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('favorites').delete().match({
        'user_id': userId,
        'product_id': productId,
      });
      _favoriteProductIds.remove(productId);
      return true;
    } catch (e) {
      print('Ошибка при удалении из избранного: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очистка всего списка избранного
  /// @return true если успешно, false если произошла ошибка
  Future<bool> clearFavorites() async {
    // Проверяем авторизацию
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      // Удаляем все записи избранного для текущего пользователя
      await _client.from('favorites').delete().eq('user_id', userId);
      _favoriteProductIds.clear();
      return true;
    } catch (e) {
      print('Ошибка при очистке избранного: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
