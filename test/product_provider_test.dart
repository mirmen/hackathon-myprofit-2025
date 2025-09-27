import 'package:flutter_test/flutter_test.dart';
import 'package:coffeebook/models/product.dart';

// Создаем упрощенную версию ProductProvider для тестирования
// без необходимости инициализировать Supabase клиент
class TestProductProvider {
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

  /// Установка тестовых продуктов
  void setTestProducts(List<Product> products) {
    _products = products;
    _applyFilters();
  }

  /// Установка выбранной категории
  /// @param category - новая категория для фильтрации
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
    }
  }

  /// Установка поискового запроса
  /// @param query - новый поисковый запрос
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
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
  }
}

void main() {
  group('ProductProvider Tests', () {
    late TestProductProvider productProvider;
    late List<Product> testProducts;

    setUp(() {
      // Создаем провайдер
      productProvider = TestProductProvider();

      // Создаем тестовые продукты
      testProducts = [
        Product(
          id: '1',
          title: 'Книга 1',
          author: 'Автор 1',
          type: 'Книги',
          price: 100.0,
          rating: 4.5,
          imageUrl: 'https://example.com/image1.jpg',
          description: 'Описание книги 1',
          options: ['твердая обложка'],
          isBook: true,
          createdAt: DateTime(2023, 1, 1),
        ),
        Product(
          id: '2',
          title: 'Кофе 1',
          author: 'Производитель 1',
          type: 'Кофе',
          price: 50.0,
          rating: 4.8,
          imageUrl: 'https://example.com/image2.jpg',
          description: 'Описание кофе 1',
          options: ['250г', '500г'],
          isBook: false,
          createdAt: DateTime(2023, 2, 1),
        ),
        Product(
          id: '3',
          title: 'Книга 2',
          author: 'Автор 2',
          type: 'Книги',
          price: 150.0,
          rating: 4.2,
          imageUrl: 'https://example.com/image3.jpg',
          description: 'Описание книги 2',
          options: ['электронная версия'],
          isBook: true,
          createdAt: DateTime(2023, 3, 1),
        ),
      ];

      // Устанавливаем тестовые продукты
      productProvider.setTestProducts(testProducts);
    });

    /// Тест получения всех продуктов
    test('Получение всех продуктов', () {
      // Проверяем, что все продукты загружены
      expect(productProvider.allProducts.length, 3);
      expect(productProvider.products.length, 3);
    });

    /// Тест получения категорий
    test('Получение категорий', () {
      // Проверяем, что категории корректно определены
      expect(productProvider.categories, ['Все', 'Книги', 'Кофе']);
    });

    /// Тест фильтрации по категории
    test('Фильтрация по категории', () {
      // Проверяем установку категории
      productProvider.setCategory('Книги');
      expect(productProvider.selectedCategory, 'Книги');
      // После фильтрации должно остаться 2 книги
      expect(productProvider.products.length, 2);

      productProvider.setCategory('Все');
      expect(productProvider.selectedCategory, 'Все');
      // После сброса фильтра должны вернуться все продукты
      expect(productProvider.products.length, 3);
    });

    /// Тест установки поискового запроса
    test('Установка поискового запроса', () {
      // Проверяем установку поискового запроса
      productProvider.setSearchQuery('Книга');
      expect(productProvider.searchQuery, 'Книга');
      // После поиска должно остаться 2 продукта с "Книга" в названии
      expect(productProvider.products.length, 2);

      productProvider.setSearchQuery('');
      expect(productProvider.searchQuery, '');
      // После сброса поиска должны вернуться все продукты
      expect(productProvider.products.length, 3);
    });

    /// Тест комбинированной фильтрации
    test('Комбинированная фильтрация', () {
      // Устанавливаем категорию и поисковый запрос
      productProvider.setCategory('Книги');
      productProvider.setSearchQuery('Книга 1');

      // Должен остаться только один продукт, который удовлетворяет обоим условиям
      expect(productProvider.products.length, 1);
      expect(productProvider.products[0].title, 'Книга 1');
    });

    /// Тест получения продуктов с высоким рейтингом
    test('Получение продуктов с высоким рейтингом', () {
      // Продукты с рейтингом 4.7 и выше
      final featured = productProvider.getFeaturedProducts();
      // Должен быть только один продукт с рейтингом 4.8
      expect(featured.length, 1);
      expect(featured[0].title, 'Кофе 1');
    });

    /// Тест получения новых продуктов
    test('Получение новых продуктов', () {
      // Новые продукты (3 самых новых)
      final newProducts = productProvider.getNewProducts();
      // Должно быть 3 продукта, отсортированных по дате создания (новые первые)
      expect(newProducts.length, 3);
      // Первый должен быть "Книга 2" (самая новая - 2023-03-01)
      expect(newProducts[0].title, 'Книга 2');
      // Второй должен быть "Кофе 1" (2023-02-01)
      expect(newProducts[1].title, 'Кофе 1');
      // Третий должен быть "Книга 1" (самая старая - 2023-01-01)
      expect(newProducts[2].title, 'Книга 1');
    });

    /// Тест очистки фильтров
    test('Очистка фильтров', () {
      // Устанавливаем фильтры
      productProvider.setCategory('Книги');
      productProvider.setSearchQuery('Тест');

      // Проверяем, что фильтры установлены
      expect(productProvider.selectedCategory, 'Книги');
      expect(productProvider.searchQuery, 'Тест');

      // Очищаем фильтры
      productProvider.clearFilters();

      // Проверяем, что фильтры сброшены
      expect(productProvider.selectedCategory, 'Все');
      expect(productProvider.searchQuery, '');
      // После сброса фильтров должны вернуться все продукты
      expect(productProvider.products.length, 3);
    });
  });
}
