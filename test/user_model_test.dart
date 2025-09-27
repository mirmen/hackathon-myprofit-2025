import 'package:flutter_test/flutter_test.dart';
import 'package:coffeebook/models/user.dart';

void main() {
  group('User Model Tests', () {
    // Тестовые данные для создания пользователя
    late Map<String, dynamic> userData;

    setUp(() {
      // Подготовка тестовых данных
      userData = {
        'id': 'user123',
        'name': 'Тестовый Пользователь',
        'email': 'test@example.com',
        'avatar_url': 'https://example.com/avatar.jpg',
        'member_since': '2023-01-01T00:00:00.000Z',
        'bonus_points': 150,
        'bonus_points_goal': 1000,
        'active_subscriptions': ['premium', 'gold'],
        'status': 'active',
        'role': 'user',
        'current_streak': 5,
        'longest_streak': 10,
        'quotes_count': 3,
      };
    });

    /// Тест создания пользователя из JSON
    test('Создание пользователя из JSON', () {
      // Создаем пользователя из JSON данных
      final user = User.fromJson(userData);

      // Проверяем, что все поля корректно заполнены
      expect(user.id, 'user123');
      expect(user.name, 'Тестовый Пользователь');
      expect(user.email, 'test@example.com');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.memberSince, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(user.bonusPoints, 150);
      expect(user.bonusPointsGoal, 1000);
      expect(user.activeSubscriptions, ['premium', 'gold']);
      expect(user.status, 'active');
      expect(user.role, 'user');
      expect(user.currentStreak, 5);
      expect(user.longestStreak, 10);
      expect(user.quotesCount, 3);
    });

    /// Тест преобразования пользователя в JSON
    test('Преобразование пользователя в JSON', () {
      // Создаем пользователя
      final user = User.fromJson(userData);

      // Преобразуем обратно в JSON
      final json = user.toJson();

      // Проверяем, что все поля корректно сериализованы
      expect(json['id'], 'user123');
      expect(json['name'], 'Тестовый Пользователь');
      expect(json['email'], 'test@example.com');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
      expect(json['member_since'], '2023-01-01T00:00:00.000Z');
      expect(json['bonus_points'], 150);
      expect(json['bonus_points_goal'], 1000);
      expect(json['active_subscriptions'], ['premium', 'gold']);
      expect(json['status'], 'active');
      expect(json['role'], 'user');
      expect(json['current_streak'], 5);
      expect(json['longest_streak'], 10);
      expect(json['quotes_count'], 3);
    });

    /// Тест вычисляемых свойств пользователя
    test('Вычисляемые свойства пользователя', () {
      // Создаем пользователя
      final user = User.fromJson(userData);

      // Проверяем вычисляемые свойства
      // Прогресс бонусных баллов = 150/1000 = 0.15
      expect(user.bonusProgress, 0.15);
      // Оставшиеся баллы до цели = 1000 - 150 = 850
      expect(user.bonusPointsLeft, 850);
    });

    /// Тест метода copyWith
    test('Метод copyWith пользователя', () {
      // Создаем пользователя
      final user = User.fromJson(userData);

      // Создаем копию с измененным именем
      final updatedUser = user.copyWith(name: 'Обновленный Пользователь');

      // Проверяем, что имя изменилось
      expect(updatedUser.name, 'Обновленный Пользователь');
      // Проверяем, что остальные поля остались без изменений
      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
      expect(updatedUser.bonusPoints, user.bonusPoints);
    });

    /// Тест создания пользователя с минимальными данными
    test('Создание пользователя с минимальными данными', () {
      // Минимальные данные пользователя
      final minimalData = {
        'id': 'user456',
        'name': 'Минимальный Пользователь',
        'email': 'minimal@example.com',
        'member_since': '2023-06-01T00:00:00.000Z',
        'bonus_points': 0,
        'bonus_points_goal': 1000,
        'active_subscriptions': [],
        'status': 'active',
        'role': 'user',
      };

      // Создаем пользователя с минимальными данными
      final user = User.fromJson(minimalData);

      // Проверяем, что пользователь создан корректно
      expect(user.id, 'user456');
      expect(user.name, 'Минимальный Пользователь');
      expect(user.email, 'minimal@example.com');
      expect(user.avatarUrl, null);
      expect(user.bonusPoints, 0);
      expect(user.activeSubscriptions, []);
      expect(user.currentStreak, 0); // Значение по умолчанию
      expect(user.longestStreak, 0); // Значение по умолчанию
      expect(user.quotesCount, 0); // Значение по умолчанию
    });
  });
}
