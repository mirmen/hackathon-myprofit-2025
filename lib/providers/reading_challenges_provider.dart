import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reading_challenge.dart';

class ReadingChallengesProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<ReadingChallenge> _challenges = [];
  bool _isLoading = false;

  List<ReadingChallenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

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
      print('Error loading reading challenges: $e');
      _challenges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinChallenge(String challengeId, String userId) async {
    try {
      // Add user to participants
      await _client
          .from('reading_challenges')
          .update({
            'participants': Supabase.instance.client.rpc(
              'array_append',
              params: {'array': 'participants', 'value': userId},
            ),
          })
          .eq('id', challengeId);

      // Create user progress record
      await _client.from('user_challenge_progress').insert({
        'user_id': userId,
        'challenge_id': challengeId,
        'books_read': 0,
        'books_completed': [],
        'last_updated': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error joining challenge: $e');
      return false;
    }
  }

  Future<bool> updateProgress(
    String challengeId,
    String userId,
    String bookId,
  ) async {
    try {
      // Update user's progress in the challenge
      final response = await _client
          .from('user_challenge_progress')
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .single();

      final currentProgress = UserChallengeProgress.fromJson(response);

      // Check if book is already marked as completed
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
      print('Error updating challenge progress: $e');
      return false;
    }
  }

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
      print('Error creating challenge: $e');
      return false;
    }
  }

  Future<ReadingChallenge?> getChallengeById(String challengeId) async {
    try {
      final response = await _client
          .from('reading_challenges')
          .select()
          .eq('id', challengeId)
          .single();

      return ReadingChallenge.fromJson(response);
    } catch (e) {
      print('Error getting challenge: $e');
      return null;
    }
  }

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
      print('Error getting user progress: $e');
      return null;
    }
  }
}
