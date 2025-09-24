import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promotion.dart';

class PromotionsProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<Promotion> _promotions = [];
  bool _isLoading = false;
  String _selectedCategory = 'Все';

  List<Promotion> get promotions => _selectedCategory == 'Все'
      ? _promotions
      : _promotions.where((p) => p.category == _selectedCategory).toList();

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => ['Все', 'Акции', 'События'];

  Future<void> loadPromotions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('promotions')
          .select()
          .order('created_at', ascending: false);

      _promotions = response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      print('Error loading promotions: $e');
      _promotions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
