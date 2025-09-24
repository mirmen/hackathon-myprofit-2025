import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/club.dart';

class ClubsProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<Club> _clubs = [];
  bool _isLoading = false;
  String _selectedType = 'all';

  List<Club> get clubs => _selectedType == 'all'
      ? _clubs
      : _clubs.where((c) => c.type == _selectedType).toList();

  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;

  List<String> get types => ['all', 'book', 'coffee'];

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
      print('Error loading clubs: $e');
      _clubs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<bool> joinClub(String clubId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('club_members').insert({
        'user_id': userId,
        'club_id': clubId,
      });

      return true;
    } catch (e) {
      print('Error joining club: $e');
      return false;
    }
  }

  Future<bool> leaveClub(String clubId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client
          .from('club_members')
          .delete()
          .eq('user_id', userId)
          .eq('club_id', clubId);

      return true;
    } catch (e) {
      print('Error leaving club: $e');
      return false;
    }
  }

  Future<bool> isUserMember(String clubId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('club_members')
          .select()
          .eq('user_id', userId)
          .eq('club_id', clubId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking club membership: $e');
      return false;
    }
  }
}
