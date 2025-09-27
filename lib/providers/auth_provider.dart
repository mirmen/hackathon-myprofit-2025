import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Провайдер для управления аутентификацией пользователей
/// Обрабатывает регистрацию, вход и выход из аккаунта
class AuthProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с аутентификацией
  final SupabaseClient _client = Supabase.instance.client;

  /// Текущая сессия пользователя
  Session? _session;

  /// Геттер для получения текущего пользователя
  User? get currentUser => _session?.user;

  /// Конструктор провайдера
  /// Подписывается на изменения состояния аутентификации
  AuthProvider() {
    _client.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      notifyListeners();
    });
  }

  /// Регистрация нового пользователя
  /// @param email - email пользователя
  /// @param password - пароль пользователя
  /// @throws AuthException если регистрация не удалась
  Future<void> signUp(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  /// Вход пользователя в систему
  /// @param email - email пользователя
  /// @param password - пароль пользователя
  /// @throws AuthException если вход не удался
  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  /// Выход пользователя из системы
  /// Очищает текущую сессию и уведомляет слушателей об изменении
  Future<void> signOut() async {
    await _client.auth.signOut();
    _session = null;
    notifyListeners();
  }
}
