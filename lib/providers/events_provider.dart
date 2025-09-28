import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/club.dart';

/// Провайдер для управления событиями клубов
class EventsProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список всех событий
  List<Event> _events = [];

  /// Флаг загрузки данных событий
  bool _isLoading = false;

  /// Геттеры для доступа к состоянию провайдера
  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  /// Загрузка событий из базы данных
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('events')
          .select()
          .order('date_time', ascending: true);

      _events = response.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке событий: $e');
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузка событий для конкретного клуба
  Future<List<Event>> loadEventsForClub(String clubId) async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('club_id', clubId)
          .order('date_time', ascending: true);

      return response.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке событий для клуба $clubId: $e');
      return [];
    }
  }

  /// Получение событий для клубов, в которых состоит пользователь
  Future<List<Event>> loadEventsForUserClubs(List<Club> userClubs) async {
    try {
      if (userClubs.isEmpty) return [];

      // Получаем ID клубов пользователя
      final clubIds = userClubs.map((club) => club.id).toList();

      final response = await _client
          .from('events')
          .select()
          .inFilter('club_id', clubIds)
          .order('date_time', ascending: true);

      return response.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке событий для клубов пользователя: $e');
      return [];
    }
  }
}
