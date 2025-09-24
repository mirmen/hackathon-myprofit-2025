import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser;

class UserProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  AppUser.User? _currentUser;
  bool _isLoading = false;

  AppUser.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser?.id;
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
      print('Error loading user profile: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('profiles').update(updates).eq('id', userId);

      await loadUserProfile(); // Reload profile after update
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> addBonusPoints(int points) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null || _currentUser == null) return false;

      final newPoints = _currentUser!.bonusPoints + points;

      await _client
          .from('profiles')
          .update({'bonus_points': newPoints})
          .eq('id', userId);

      await loadUserProfile();
      return true;
    } catch (e) {
      print('Error adding bonus points: $e');
      return false;
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
