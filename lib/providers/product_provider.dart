import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

/// Провайдер для управления продуктами
/// Загружает, фильтрует и предоставляет доступ к каталогу продуктов
class ProductProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Все продукты из базы данных
  List<Product> _products = [];

  /// Отфильтрованные продукты (по категории и поиску)
  List<Product> _filteredProducts = [];

  /// Выбранная категория для фильтрации
  String _selectedCategory = 'Все';

  /// Поисковый запрос
  String _searchQuery = '';

  /// Геттеры для доступа к данным
  List<Product> get products => List.unmodifiable(_filteredProducts);
  List<Product> get allProducts => List.unmodifiable(_products);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Список уникальных категорий продуктов
  List<String> get categories => [
    'Все',
    ..._products.map((p) => p.type).toSet(),
  ];

  /// Флаг загрузки данных продуктов
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Загрузка всех продуктов из базы данных
  /// Выполняет запрос к таблице products и применяет фильтры
  Future<void> loadProducts() async {
    print('🔄 Начало загрузки продуктов...');
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Делаем запрос к таблице products...');

      List<dynamic> response = [];

      // Сначала пробуем без явного указания схемы
      try {
        print('🚀 Пробуем запрос без указания схемы...');
        response = await _client.from('products').select();
        print('📊 Результат первого запроса: ${response.length} элементов');
      } catch (e) {
        print('❌ Первый запрос не удался: $e');
      }

      // Если пусто, пробуем с явным указанием схемы public
      if (response.isEmpty) {
        try {
          print(
            '⚠️ Первый запрос вернул пусто, пробуем с явной схемой public...',
          );
          response = await _client.schema('public').from('products').select();
          print('📊 Результат второго запроса: ${response.length} элементов');
        } catch (e) {
          print('❌ Второй запрос тоже не удался: $e');
        }
      }

      print('✅ Ответ от Supabase получен');
      print('📊 Сырые данные: $response');
      print('📈 Количество элементов: ${response.length}');

      if (response.isEmpty) {
        print('⚠️ В базе нет продуктов!');
        _products = [];
        _filteredProducts = [];
      } else {
        print('🔄 Конвертация данных в объекты Product...');
        _products = response
            .map<Product>(
              (json) => Product.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        print('✅ Загружено ${_products.length} продуктов');

        // Применяем фильтры (категории и поиск)
        _applyFilters();
        print(
          '✅ Фильтры применены, ${_filteredProducts.length} продуктов после фильтрации',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Ошибка при загрузке продуктов: $e');
      print('📍 Stack trace: $stackTrace');
      _products = [];
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      print('🏁 Загрузка продуктов завершена');
      notifyListeners();
    }
  }

  /// Установка выбранной категории
  /// @param category - новая категория для фильтрации
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
      notifyListeners();
    }
  }

  /// Установка поискового запроса
  /// @param query - новый поисковый запрос
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
      notifyListeners();
    }
  }

  /// Применение фильтров к списку продуктов
  /// Фильтрует по категории и поисковому запросу
  void _applyFilters() {
    List<Product> filtered = _products;

    // Фильтрация по категории
    if (_selectedCategory != 'Все') {
      filtered = filtered
          .where((product) => product.type == _selectedCategory)
          .toList();
    }

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.title.toLowerCase().contains(lowercaseQuery) ||
            product.author.toLowerCase().contains(lowercaseQuery) ||
            product.type.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    _filteredProducts = filtered;
  }

  /// Получение продукта по ID
  /// @param id - ID продукта для поиска
  /// @return Product если найден, null если не найден или произошла ошибка
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _client
          .schema('public')
          .from('products')
          .select()
          .eq('id', id)
          .single();
      return Product.fromJson(response);
    } catch (e) {
      print('Ошибка при получении продукта по ID: $e');
      return null;
    }
  }

  /// Получение продуктов с высоким рейтингом (4.7 и выше)
  /// @return список продуктов с высоким рейтингом
  List<Product> getFeaturedProducts() {
    return _products.where((product) => product.rating >= 4.7).toList();
  }

  /// Получение новых продуктов (3 самых новых)
  /// @return список из 3 новых продуктов
  List<Product> getNewProducts() {
    // Сортируем по дате создания по убыванию и берем первые 3
    final sorted = List<Product>.from(_products)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  /// Очистка всех фильтров
  /// Сбрасывает категорию и поисковый запрос к значениям по умолчанию
  void clearFilters() {
    _selectedCategory = 'Все';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }
}
