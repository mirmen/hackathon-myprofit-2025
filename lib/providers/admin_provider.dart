import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/promotion.dart';
import '../models/club.dart';
import '../models/user.dart' as AppUser;

/// Провайдер для административных функций
/// Управляет загрузкой, добавлением, обновлением и удалением данных из Supabase
class AdminProvider extends ChangeNotifier {
  /// Клиент Supabase для взаимодействия с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  // Данные о продуктах
  List<Product> _products = [];
  bool _isLoadingProducts = false;

  // Данные об акциях
  List<Promotion> _promotions = [];
  bool _isLoadingPromotions = false;

  // Данные о клубах
  List<Club> _clubs = [];
  bool _isLoadingClubs = false;

  // Данные о пользователях
  List<AppUser.User> _users = [];
  bool _isLoadingUsers = false;

  // Геттеры для доступа к данным
  List<Product> get products => _products;
  bool get isLoadingProducts => _isLoadingProducts;

  List<Promotion> get promotions => _promotions;
  bool get isLoadingPromotions => _isLoadingPromotions;

  List<Club> get clubs => _clubs;
  bool get isLoadingClubs => _isLoadingClubs;

  List<AppUser.User> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers;

  /// Загрузка всех продуктов из базы данных
  /// Сортирует по дате создания в обратном порядке (новые первыми)
  Future<void> loadProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      _products = response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке продуктов: $e');
      _products = [];
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Добавление нового продукта в базу данных
  /// @param productData - данные продукта в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      await _client.from('products').insert(productData);
      await loadProducts(); // Обновляем список после добавления
      return true;
    } catch (e) {
      print('Ошибка при добавлении продукта: $e');
      return false;
    }
  }

  /// Обновление существующего продукта
  /// @param productId - ID продукта для обновления
  /// @param updates - данные для обновления в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Удаляем поля, которые не должны обновляться
      // ID и дата создания являются неизменяемыми
      final updateData = Map<String, dynamic>.from(updates);
      updateData.removeWhere(
        (key, value) => key == 'id' || key == 'created_at',
      );

      await _client.from('products').update(updateData).eq('id', productId);
      await loadProducts(); // Обновляем список после изменения
      return true;
    } catch (e) {
      print('Ошибка при обновлении продукта: $e');
      return false;
    }
  }

  /// Удаление продукта из базы данных
  /// @param productId - ID продукта для удаления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
      await loadProducts(); // Обновляем список после удаления
      return true;
    } catch (e) {
      print('Ошибка при удалении продукта: $e');
      return false;
    }
  }

  /// Загрузка всех акций из базы данных
  /// Сортирует по дате создания в обратном порядке (новые первыми)
  Future<void> loadPromotions() async {
    _isLoadingPromotions = true;
    notifyListeners();

    try {
      final response = await _client
          .from('promotions')
          .select()
          .order('created_at', ascending: false);

      _promotions = response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке акций: $e');
      _promotions = [];
    } finally {
      _isLoadingPromotions = false;
      notifyListeners();
    }
  }

  /// Добавление новой акции в базу данных
  /// @param promotionData - данные акции в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addPromotion(Map<String, dynamic> promotionData) async {
    try {
      await _client.from('promotions').insert(promotionData);
      await loadPromotions(); // Обновляем список после добавления
      return true;
    } catch (e) {
      print('Ошибка при добавлении акции: $e');
      return false;
    }
  }

  /// Обновление существующей акции
  /// @param promotionId - ID акции для обновления
  /// @param updates - данные для обновления в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updatePromotion(
    String promotionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Удаляем поля, которые не должны обновляться
      // ID и дата создания являются неизменяемыми
      final updateData = Map<String, dynamic>.from(updates);
      updateData.removeWhere(
        (key, value) => key == 'id' || key == 'created_at',
      );

      await _client.from('promotions').update(updateData).eq('id', promotionId);
      await loadPromotions(); // Обновляем список после изменения
      return true;
    } catch (e) {
      print('Ошибка при обновлении акции: $e');
      return false;
    }
  }

  /// Удаление акции из базы данных
  /// @param promotionId - ID акции для удаления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> deletePromotion(String promotionId) async {
    try {
      await _client.from('promotions').delete().eq('id', promotionId);
      await loadPromotions(); // Обновляем список после удаления
      return true;
    } catch (e) {
      print('Ошибка при удалении акции: $e');
      return false;
    }
  }

  /// Загрузка всех клубов из базы данных
  /// Сортирует по дате создания в обратном порядке (новые первыми)
  Future<void> loadClubs() async {
    _isLoadingClubs = true;
    notifyListeners();

    try {
      final response = await _client
          .from('clubs')
          .select()
          .order('created_at', ascending: false);

      _clubs = response.map((json) => Club.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке клубов: $e');
      _clubs = [];
    } finally {
      _isLoadingClubs = false;
      notifyListeners();
    }
  }

  /// Добавление нового клуба в базу данных
  /// @param clubData - данные клуба в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addClub(Map<String, dynamic> clubData) async {
    try {
      await _client.from('clubs').insert(clubData);
      await loadClubs(); // Обновляем список после добавления
      return true;
    } catch (e) {
      print('Ошибка при добавлении клуба: $e');
      return false;
    }
  }

  /// Обновление существующего клуба
  /// @param clubId - ID клуба для обновления
  /// @param updates - данные для обновления в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updateClub(String clubId, Map<String, dynamic> updates) async {
    try {
      // Удаляем поля, которые не должны обновляться
      // ID и дата создания являются неизменяемыми
      final updateData = Map<String, dynamic>.from(updates);
      updateData.removeWhere(
        (key, value) => key == 'id' || key == 'created_at',
      );

      await _client.from('clubs').update(updateData).eq('id', clubId);
      await loadClubs(); // Обновляем список после изменения
      return true;
    } catch (e) {
      print('Ошибка при обновлении клуба: $e');
      return false;
    }
  }

  /// Удаление клуба из базы данных
  /// @param clubId - ID клуба для удаления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> deleteClub(String clubId) async {
    try {
      await _client.from('clubs').delete().eq('id', clubId);
      await loadClubs(); // Обновляем список после удаления
      return true;
    } catch (e) {
      print('Ошибка при удалении клуба: $e');
      return false;
    }
  }

  /// Загрузка всех пользователей из базы данных
  /// Сортирует по дате регистрации в обратном порядке (новые первыми)
  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
      final response = await _client
          .from('profiles')
          .select()
          .order('member_since', ascending: false);

      _users = response.map((json) => AppUser.User.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке пользователей: $e');
      _users = [];
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  /// Обновление данных пользователя
  /// @param userId - ID пользователя для обновления
  /// @param updates - данные для обновления в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Удаляем поля, которые не должны обновляться
      // ID и дата регистрации являются неизменяемыми
      final updateData = Map<String, dynamic>.from(updates);
      updateData.removeWhere(
        (key, value) => key == 'id' || key == 'member_since',
      );

      await _client.from('profiles').update(updateData).eq('id', userId);
      await loadUsers(); // Обновляем список после изменения
      return true;
    } catch (e) {
      print('Ошибка при обновлении пользователя: $e');
      return false;
    }
  }

  /// Удаление пользователя из базы данных
  /// Важно: это также удалит пользователя из системы аутентификации из-за CASCADE ограничения
  /// @param userId - ID пользователя для удаления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> deleteUser(String userId) async {
    try {
      // Важно: Это также удалит пользователя из auth.users из-за CASCADE ограничения
      await _client.from('profiles').delete().eq('id', userId);
      await loadUsers(); // Обновляем список после удаления
      return true;
    } catch (e) {
      print('Ошибка при удалении пользователя: $e');
      return false;
    }
  }
}
