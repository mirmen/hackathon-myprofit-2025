import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promotion.dart';

/// Провайдер для управления акциями и промо-активностями
/// Загружает и фильтрует список акций из базы данных
class PromotionsProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список всех акций
  List<Promotion> _promotions = [];

  /// Флаг загрузки данных акций
  bool _isLoading = false;

  /// Выбранная категория для фильтрации акций
  String _selectedCategory = 'Все';

  /// Геттер для получения отфильтрованных акций
  /// Если выбрана категория "Все", возвращает все акции
  /// Иначе возвращает акции только выбранной категории
  List<Promotion> get promotions => _selectedCategory == 'Все'
      ? _promotions
      : _promotions.where((p) => p.category == _selectedCategory).toList();

  /// Геттеры для доступа к состоянию провайдера
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  /// Список доступных категорий акций
  List<String> get categories => ['Все', 'Акции', 'События'];

  /// Загрузка акций из базы данных
  /// Сортирует акции по дате создания в обратном порядке (новые первыми)
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
      print('Ошибка при загрузке акций: $e');
      _promotions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Установка выбранной категории акций
  /// @param category - новая категория для фильтрации
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
