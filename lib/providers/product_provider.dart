import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'Все';
  String _searchQuery = '';

  List<Product> get products => List.unmodifiable(_filteredProducts);
  List<Product> get allProducts => List.unmodifiable(_products);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => [
    'Все',
    ..._products.map((p) => p.type).toSet(),
  ];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<Product> filtered = _products;

    if (_selectedCategory != 'Все') {
      filtered = filtered
          .where((product) => product.type == _selectedCategory)
          .toList();
    }

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
      print('Error getting product by id: $e');
      return null;
    }
  }

  List<Product> getFeaturedProducts() {
    return _products.where((product) => product.rating >= 4.7).toList();
  }

  List<Product> getNewProducts() {
    // Sort by created_at desc, take 3
    final sorted = List<Product>.from(_products)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  void clearFilters() {
    _selectedCategory = 'Все';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }
}
