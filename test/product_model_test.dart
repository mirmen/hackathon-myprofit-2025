import 'package:flutter_test/flutter_test.dart';
import 'package:coffeebook/models/product.dart';

void main() {
  group('Product Model Tests', () {
    // Тестовые данные для создания продукта
    late Map<String, dynamic> productData;

    setUp(() {
      // Подготовка тестовых данных
      productData = {
        'id': 'product123',
        'title': 'Тестовая Книга',
        'author': 'Тестовый Автор',
        'type': 'Книги',
        'price': 29.99,
        'rating': 4.5,
        'image_url': 'https://example.com/book.jpg',
        'description': 'Тестовое описание книги',
        'options': ['твердая обложка', 'электронная версия'],
        'is_book': true,
        'created_at': '2023-01-01T00:00:00.000Z',
      };
    });

    /// Тест создания продукта из JSON
    test('Создание продукта из JSON', () {
      // Создаем продукт из JSON данных
      final product = Product.fromJson(productData);

      // Проверяем, что все поля корректно заполнены
      expect(product.id, 'product123');
      expect(product.title, 'Тестовая Книга');
      expect(product.author, 'Тестовый Автор');
      expect(product.type, 'Книги');
      expect(product.price, 29.99);
      expect(product.rating, 4.5);
      expect(product.imageUrl, 'https://example.com/book.jpg');
      expect(product.description, 'Тестовое описание книги');
      expect(product.options, ['твердая обложка', 'электронная версия']);
      expect(product.isBook, true);
      expect(product.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    /// Тест преобразования продукта в JSON
    test('Преобразование продукта в JSON', () {
      // Создаем продукт
      final product = Product.fromJson(productData);

      // Преобразуем обратно в JSON
      final json = product.toJson();

      // Проверяем, что все поля корректно сериализованы
      expect(json['id'], 'product123');
      expect(json['title'], 'Тестовая Книга');
      expect(json['author'], 'Тестовый Автор');
      expect(json['type'], 'Книги');
      expect(json['price'], 29.99);
      expect(json['rating'], 4.5);
      expect(json['image_url'], 'https://example.com/book.jpg');
      expect(json['description'], 'Тестовое описание книги');
      expect(json['options'], ['твердая обложка', 'электронная версия']);
      expect(json['is_book'], true);
      expect(json['created_at'], '2023-01-01T00:00:00.000Z');
    });

    /// Тест метода copyWith
    test('Метод copyWith продукта', () {
      // Создаем продукт
      final product = Product.fromJson(productData);

      // Создаем копию с измененным названием
      final updatedProduct = product.copyWith(title: 'Обновленная Книга');

      // Проверяем, что название изменилось
      expect(updatedProduct.title, 'Обновленная Книга');
      // Проверяем, что остальные поля остались без изменений
      expect(updatedProduct.id, product.id);
      expect(updatedProduct.author, product.author);
      expect(updatedProduct.price, product.price);
    });

    /// Тест создания продукта с минимальными данными
    test('Создание продукта с минимальными данными', () {
      // Минимальные данные продукта
      final minimalData = {
        'id': 'product456',
        'title': 'Минимальный Продукт',
        'author': 'Автор',
        'type': 'Другое',
        'price': 0.0,
        'rating': 0.0,
        'image_url': '',
        'description': '',
        'options': [],
        'is_book': false,
        'created_at': '2023-06-01T00:00:00.000Z',
      };

      // Создаем продукт с минимальными данными
      final product = Product.fromJson(minimalData);

      // Проверяем, что продукт создан корректно
      expect(product.id, 'product456');
      expect(product.title, 'Минимальный Продукт');
      expect(product.price, 0.0);
      expect(product.rating, 0.0);
      expect(product.imageUrl, '');
      expect(product.description, '');
      expect(product.options, []);
      expect(product.isBook, false);
    });
  });
}
