import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reading_challenge.dart';

/// Провайдер для управления_reading челленджами
/// Обрабатывает загрузку, создание и участие в_reading челленджах
class ReadingChallengesProvider extends ChangeNotifier {
  /// Клиент Supabase для взаимодействия с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список_reading челленджей
  List<ReadingChallenge> _challenges = [];

  /// Флаг загрузки данных
  bool _isLoading = false;

  /// Геттеры для доступа к данным
  List<ReadingChallenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

  /// Загрузка всех_reading челленджей из базы данных
  /// Сортирует по дате создания в обратном порядке (новые первыми)
  Future<void> loadChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('reading_challenges')
          .select()
          .order('created_at', ascending: false);

      _challenges = response
          .map((json) => ReadingChallenge.fromJson(json))
          .toList();
    } catch (e) {
      print('Ошибка при загрузке_reading челленджей: $e');
      _challenges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Присоединение пользователя к_reading челленджу
  /// @param challengeId - ID_reading челленджа
  /// @param userId - ID пользователя
  /// @return true если успешно, false если произошла ошибка
  Future<bool> joinChallenge(String challengeId, String userId) async {
    try {
      // Добавляем пользователя в участники
      await _client
          .from('reading_challenges')
          .update({
            'participants': Supabase.instance.client.rpc(
              'array_append',
              params: {'array': 'participants', 'value': userId},
            ),
          })
          .eq('id', challengeId);

      // Создаем запись о прогрессе пользователя
      await _client.from('user_challenge_progress').insert({
        'user_id': userId,
        'challenge_id': challengeId,
        'books_read': 0,
        'books_completed': [],
        'last_updated': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Ошибка при присоединении к_reading челленджу: $e');
      return false;
    }
  }

  /// Обновление прогресса пользователя в_reading челлендже
  /// @param challengeId - ID_reading челленджа
  /// @param userId - ID пользователя
  /// @param bookId - ID книги, которую пользователь завершил
  /// @return true если успешно, false если произошла ошибка
  Future<bool> updateProgress(
    String challengeId,
    String userId,
    String bookId,
  ) async {
    try {
      // Получаем текущий прогресс пользователя в_reading челлендже
      final response = await _client
          .from('user_challenge_progress')
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .single();

      final currentProgress = UserChallengeProgress.fromJson(response);

      // Проверяем, не завершена ли уже эта книга
      if (!currentProgress.booksCompleted.contains(bookId)) {
        final updatedProgress = currentProgress.copyWith(
          booksRead: currentProgress.booksRead + 1,
          booksCompleted: [...currentProgress.booksCompleted, bookId],
          lastUpdated: DateTime.now(),
        );

        await _client
            .from('user_challenge_progress')
            .update(updatedProgress.toJson())
            .eq('user_id', userId)
            .eq('challenge_id', challengeId);
      }

      return true;
    } catch (e) {
      print('Ошибка при обновлении прогресса в_reading челлендже: $e');
      return false;
    }
  }

  /// Создание нового_reading челленджа
  /// @param title - название_reading челленджа
  /// @param description - описание
  /// @param bookIds - список ID книг для чтения
  /// @param targetBooks - целевое количество книг для завершения
  /// @param bonusPoints - бонусные баллы за завершение
  /// @param creatorId - ID создателя_reading челленджа
  /// @return true если успешно, false если произошла ошибка
  Future<bool> createChallenge({
    required String title,
    required String description,
    required List<String> bookIds,
    required int targetBooks,
    required int bonusPoints,
    required String creatorId,
  }) async {
    try {
      final newChallenge = {
        'title': title,
        'description': description,
        'book_ids': bookIds,
        'target_books': targetBooks,
        'bonus_points': bonusPoints,
        'created_at': DateTime.now().toIso8601String(),
        'participants': [creatorId],
        'user_progress': {creatorId: 0},
      };

      await _client.from('reading_challenges').insert(newChallenge);
      return true;
    } catch (e) {
      print('Ошибка при создании_reading челленджа: $e');
      return false;
    }
  }

  /// Получение_reading челленджа по ID
  /// @param challengeId - ID_reading челленджа для получения
  /// @return ReadingChallenge если найден, null если не найден или произошла ошибка
  Future<ReadingChallenge?> getChallengeById(String challengeId) async {
    try {
      final response = await _client
          .from('reading_challenges')
          .select()
          .eq('id', challengeId)
          .single();

      return ReadingChallenge.fromJson(response);
    } catch (e) {
      print('Ошибка при получении_reading челленджа: $e');
      return null;
    }
  }

  /// Получение прогресса пользователя в_reading челлендже
  /// @param challengeId - ID_reading челленджа
  /// @param userId - ID пользователя
  /// @return UserChallengeProgress если найден, null если не найден или произошла ошибка
  Future<UserChallengeProgress?> getUserProgress(
    String challengeId,
    String userId,
  ) async {
    try {
      final response = await _client
          .from('user_challenge_progress')
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .single();

      return UserChallengeProgress.fromJson(response);
    } catch (e) {
      print('Ошибка при получении прогресса пользователя: $e');
      return null;
    }
  }
}
