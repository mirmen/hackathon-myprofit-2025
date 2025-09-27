# Тесты для CoffeeBook

Этот каталог содержит unit-тесты для приложения CoffeeBook.

## Структура тестов

- [user_model_test.dart](user_model_test.dart) - Тесты для модели пользователя
- [product_model_test.dart](product_model_test.dart) - Тесты для модели продукта
- [product_provider_test.dart](product_provider_test.dart) - Тесты для провайдера продуктов
- [user_provider_test.dart](user_provider_test.dart) - Тесты для провайдера пользователей (в разработке)

## Запуск тестов

Для запуска всех тестов выполните:

```bash
flutter test
```

Для запуска конкретного теста:

```bash
flutter test test/user_model_test.dart
```

## Генерация моков

Если вы добавили новые моки, выполните:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Написание тестов

Тесты написаны с использованием:
- `flutter_test` - основной фреймворк для тестирования Flutter
- `mockito` - библиотека для создания моков

### Пример теста модели

```dart
test('Создание пользователя из JSON', () {
  // Подготовка тестовых данных
  final userData = {
    'id': 'user123',
    'name': 'Тестовый Пользователь',
    // ... другие поля
  };

  // Выполнение теста
  final user = User.fromJson(userData);

  // Проверка результатов
  expect(user.id, 'user123');
  expect(user.name, 'Тестовый Пользователь');
});
```