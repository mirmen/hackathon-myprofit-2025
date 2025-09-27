import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser;

/// Провайдер для управления профилем пользователя
/// Загружает, обновляет и управляет данными текущего пользователя
class UserProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Текущий пользователь приложения
  AppUser.User? _currentUser;

  /// Флаг загрузки данных пользователя
  bool _isLoading = false;

  /// Геттеры для доступа к данным
  AppUser.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  /// Загрузка профиля текущего пользователя из базы данных
  /// Выполняет запрос к таблице profiles по ID текущего пользователя
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser?.id;
      // Если пользователь не авторизован, очищаем данные
      if (userId == null) {
        _currentUser = null;
        return;
      }

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = AppUser.User.fromJson(response);
    } catch (e) {
      print('Ошибка при загрузке профиля пользователя: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновление профиля пользователя
  /// @param updates - данные для обновления в формате Map
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Проверяем, что пользователь авторизован
      if (userId == null) return false;

      await _client.from('profiles').update(updates).eq('id', userId);

      await loadUserProfile(); // Перезагружаем профиль после обновления
      return true;
    } catch (e) {
      print('Ошибка при обновлении профиля: $e');
      return false;
    }
  }

  /// Добавление бонусных баллов пользователю
  /// @param points - количество баллов для добавления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addBonusPoints(int points) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Проверяем, что пользователь авторизован и данные загружены
      if (userId == null || _currentUser == null) return false;

      // Вычисляем новое количество баллов
      final newPoints = _currentUser!.bonusPoints + points;

      await _client
          .from('profiles')
          .update({'bonus_points': newPoints})
          .eq('id', userId);

      await loadUserProfile(); // Перезагружаем профиль для обновления данных
      return true;
    } catch (e) {
      print('Ошибка при добавлении бонусных баллов: $e');
      return false;
    }
  }

  /// Очистка данных пользователя
  /// Используется при выходе из аккаунта
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
