import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_exchange.dart';

/// Провайдер для управления обменом книгами
/// Обрабатывает загрузку, добавление и управление предложениями обмена книгами
class BookExchangeProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список предложений обмена книгами
  List<BookExchange> _exchanges = [];

  /// Флаг загрузки данных обмена
  bool _isLoading = false;

  /// Геттеры для доступа к данным
  List<BookExchange> get exchanges => _exchanges;
  bool get isLoading => _isLoading;

  /// Загрузка всех предложений обмена книгами
  /// Сортирует по дате создания в обратном порядке (новые первыми)
  Future<void> loadExchanges() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('book_exchanges')
          .select()
          .order('created_at', ascending: false);

      _exchanges = response.map((json) => BookExchange.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке предложений обмена: $e');
      _exchanges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузка предложений обмена конкретного пользователя
  /// @param userId - ID пользователя для загрузки его предложений
  Future<void> loadUserExchanges(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('book_exchanges')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _exchanges = response.map((json) => BookExchange.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при загрузке предложений пользователя: $e');
      _exchanges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Добавление нового предложения обмена книгами
  /// @param userId - ID пользователя, добавляющего предложение
  /// @param bookTitle - название книги
  /// @param bookAuthor - автор книги
  /// @param bookImageUrl - URL изображения книги (опционально)
  /// @param condition - состояние книги
  /// @param bonusPoints - количество бонусных баллов за обмен
  /// @return true если успешно, false если произошла ошибка
  Future<bool> addBookExchange({
    required String userId,
    required String bookTitle,
    required String bookAuthor,
    String? bookImageUrl,
    required String condition,
    required int bonusPoints,
  }) async {
    try {
      final newExchange = {
        'user_id': userId,
        'book_title': bookTitle,
        'book_author': bookAuthor,
        'book_image_url': bookImageUrl,
        'condition': condition,
        'status': 'available',
        'bonus_points': bonusPoints,
      };

      await _client.from('book_exchanges').insert(newExchange);
      return true;
    } catch (e) {
      print('Ошибка при добавлении предложения обмена: $e');
      return false;
    }
  }

  /// Запрос на обмен книгой
  /// @param exchangeId - ID предложения обмена
  /// @param requestingUserId - ID пользователя, запрашивающего обмен
  /// @return true если успешно, false если произошла ошибка
  Future<bool> requestBookExchange(
    String exchangeId,
    String requestingUserId,
  ) async {
    try {
      await _client
          .from('book_exchanges')
          .update({'status': 'requested', 'requested_by': requestingUserId})
          .eq('id', exchangeId);

      return true;
    } catch (e) {
      print('Ошибка при запросе обмена книгой: $e');
      return false;
    }
  }

  /// Завершение обмена книгой
  /// @param exchangeId - ID предложения обмена
  /// @return true если успешно, false если произошла ошибка
  Future<bool> completeBookExchange(String exchangeId) async {
    try {
      await _client
          .from('book_exchanges')
          .update({
            'status': 'completed',
            'exchanged_at': DateTime.now().toIso8601String(),
          })
          .eq('id', exchangeId);

      return true;
    } catch (e) {
      print('Ошибка при завершении обмена книгой: $e');
      return false;
    }
  }

  /// Отмена запроса на обмен книгой
  /// @param exchangeId - ID предложения обмена
  /// @return true если успешно, false если произошла ошибка
  Future<bool> cancelBookExchange(String exchangeId) async {
    try {
      await _client
          .from('book_exchanges')
          .update({'status': 'available', 'requested_by': null})
          .eq('id', exchangeId);

      return true;
    } catch (e) {
      print('Ошибка при отмене обмена книгой: $e');
      return false;
    }
  }
}
