import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_exchange.dart';

class BookExchangeProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<BookExchange> _exchanges = [];
  bool _isLoading = false;

  List<BookExchange> get exchanges => _exchanges;
  bool get isLoading => _isLoading;

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
      print('Error loading book exchanges: $e');
      _exchanges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      print('Error loading user book exchanges: $e');
      _exchanges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      print('Error adding book exchange: $e');
      return false;
    }
  }

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
      print('Error requesting book exchange: $e');
      return false;
    }
  }

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
      print('Error completing book exchange: $e');
      return false;
    }
  }

  Future<bool> cancelBookExchange(String exchangeId) async {
    try {
      await _client
          .from('book_exchanges')
          .update({'status': 'available', 'requested_by': null})
          .eq('id', exchangeId);

      return true;
    } catch (e) {
      print('Error canceling book exchange: $e');
      return false;
    }
  }
}
