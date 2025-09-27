import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/club.dart';

/// Провайдер для управления клубами
/// Загружает, фильтрует и управляет членством в клубах
class ClubsProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список всех клубов
  List<Club> _clubs = [];

  /// Флаг загрузки данных клубов
  bool _isLoading = false;

  /// Выбранный тип клубов для фильтрации
  String _selectedType = 'all';

  /// Геттер для получения отфильтрованных клубов
  /// Если выбран тип "all", возвращает все клубы
  /// Иначе возвращает клубы только выбранного типа
  List<Club> get clubs => _selectedType == 'all'
      ? _clubs
      : _clubs.where((c) => c.type == _selectedType).toList();

  /// Геттеры для доступа к состоянию провайдера
  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;

  /// Список доступных типов клубов
  List<String> get types => ['all', 'book', 'coffee'];

  /// Загрузка клубов из базы данных
  /// Сортирует клубы по количеству участников по убыванию (популярные первыми)
  Future<void> loadClubs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('clubs')
          .select()
          .order('members_count', ascending: false);

      _clubs = response.map((json) => Club.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке клубов: $e');
      _clubs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Установка выбранного типа клубов
  /// @param type - новый тип для фильтрации
  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Присоединение пользователя к клубу
  /// @param clubId - ID клуба для присоединения
  /// @return true если успешно, false если произошла ошибка
  Future<bool> joinClub(String clubId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Проверяем авторизацию пользователя
      if (userId == null) return false;

      await _client.from('club_members').insert({
        'user_id': userId,
        'club_id': clubId,
      });

      return true;
    } catch (e) {
      print('Ошибка при присоединении к клубу: $e');
      return false;
    }
  }

  /// Покидание клуба пользователем
  /// @param clubId - ID клуба для выхода
  /// @return true если успешно, false если произошла ошибка
  Future<bool> leaveClub(String clubId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Проверяем авторизацию пользователя
      if (userId == null) return false;

      await _client
          .from('club_members')
          .delete()
          .eq('user_id', userId)
          .eq('club_id', clubId);

      return true;
    } catch (e) {
      print('Ошибка при выходе из клуба: $e');
      return false;
    }
  }

  /// Проверка, является ли пользователь участником клуба
  /// @param clubId - ID клуба для проверки
  /// @return true если пользователь участник, false если нет или произошла ошибка
  Future<bool> isUserMember(String clubId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Проверяем авторизацию пользователя
      if (userId == null) return false;

      final response = await _client
          .from('club_members')
          .select()
          .eq('user_id', userId)
          .eq('club_id', clubId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Ошибка при проверке членства в клубе: $e');
      return false;
    }
  }
}
