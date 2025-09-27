import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coffeebook/providers/user_provider.dart';
import 'package:coffeebook/models/user.dart' as AppUser;

// Генерация моков
@GenerateMocks([
  SupabaseClient,
  GoTrueClient,
  PostgrestFilterBuilder,
  PostgrestQueryBuilder,
])
import 'user_provider_test.mocks.dart';

void main() {
  group('UserProvider Tests', () {
    // Моки для зависимостей
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuthClient;
    late MockPostgrestQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late UserProvider userProvider;

    setUp(() {
      // Создание моков
      mockSupabaseClient = MockSupabaseClient();
      mockAuthClient = MockGoTrueClient();
      mockQueryBuilder = MockPostgrestQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();

      // Настройка мока Supabase клиента
      when(mockSupabaseClient.auth).thenReturn(mockAuthClient);
      when(mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenReturn(mockFilterBuilder);

      // Создание провайдера
      userProvider = UserProvider();
    });

    /// Тест загрузки профиля пользователя когда пользователь авторизован
    test(
      'Загрузка профиля пользователя когда пользователь авторизован',
      () async {
        // Подготавливаем моки
        final userId = 'test-user-id';
        final userData = {
          'id': userId,
          'name': 'Тестовый Пользователь',
          'email': 'test@example.com',
          'member_since': '2023-01-01T00:00:00.000Z',
          'bonus_points': 100,
          'bonus_points_goal': 1000,
          'active_subscriptions': [],
          'status': 'active',
          'role': 'user',
        };

        // Настройка моков для успешного сценария
        when(mockAuthClient.currentUser).thenReturn(
          Session(
            accessToken: 'test-token',
            tokenType: 'Bearer',
            expiresIn: 3600,
            refreshToken: 'refresh-token',
            user: User(
              id: userId,
              email: 'test@example.com',
              appMetadata: {},
              userMetadata: {},
            ),
          ),
        );

        when(mockFilterBuilder.then(any)).thenAnswer((_) async => userData);

        // Выполняем тест
        await userProvider.loadUserProfile();

        // Проверяем результаты
        expect(userProvider.currentUser, isNotNull);
        expect(userProvider.currentUser!.id, userId);
        expect(userProvider.currentUser!.name, 'Тестовый Пользователь');
        expect(userProvider.isLoading, false);
      },
    );

    /// Тест загрузки профиля пользователя когда пользователь не авторизован
    test(
      'Загрузка профиля пользователя когда пользователь не авторизован',
      () async {
        // Настройка моков для сценария без авторизации
        when(mockAuthClient.currentUser).thenReturn(null);

        // Выполняем тест
        await userProvider.loadUserProfile();

        // Проверяем результаты
        expect(userProvider.currentUser, isNull);
        expect(userProvider.isLoading, false);
      },
    );

    /// Тест обновления профиля пользователя
    test('Обновление профиля пользователя', () async {
      // Подготавливаем моки
      final userId = 'test-user-id';
      final updates = {'name': 'Новое Имя'};

      when(mockAuthClient.currentUser).thenReturn(
        Session(
          accessToken: 'test-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
          refreshToken: 'refresh-token',
          user: User(
            id: userId,
            email: 'test@example.com',
            appMetadata: {},
            userMetadata: {},
          ),
        ),
      );

      // Мок для метода update
      final mockUpdateBuilder = MockPostgrestFilterBuilder();
      when(mockQueryBuilder.update(updates)).thenReturn(mockUpdateBuilder);
      when(mockUpdateBuilder.eq(any, any)).thenReturn(mockUpdateBuilder);
      when(mockUpdateBuilder.then(any)).thenAnswer((_) async => null);

      // Выполняем тест
      final result = await userProvider.updateProfile(updates);

      // Проверяем результаты
      expect(result, true);
      // Проверяем, что методы были вызваны с правильными параметрами
      verify(mockQueryBuilder.update(updates)).called(1);
      verify(mockUpdateBuilder.eq('id', userId)).called(1);
    });

    /// Тест добавления бонусных баллов
    test('Добавление бонусных баллов', () async {
      // Подготавливаем моки
      final userId = 'test-user-id';
      final pointsToAdd = 100;

      // Устанавливаем текущего пользователя
      final testUser = AppUser.User(
        id: userId,
        name: 'Тестовый Пользователь',
        email: 'test@example.com',
        memberSince: DateTime(2023, 1, 1),
        bonusPoints: 200,
        bonusPointsGoal: 1000,
        activeSubscriptions: [],
        status: 'active',
        role: 'user',
      );

      // Используем рефлексию для установки приватного поля
      // В реальных тестах лучше создать метод для установки тестовых данных
      userProvider.clearUser(); // Очищаем перед установкой

      when(mockAuthClient.currentUser).thenReturn(
        Session(
          accessToken: 'test-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
          refreshToken: 'refresh-token',
          user: User(
            id: userId,
            email: 'test@example.com',
            appMetadata: {},
            userMetadata: {},
          ),
        ),
      );

      // Мок для метода update
      final mockUpdateBuilder = MockPostgrestFilterBuilder();
      when(mockQueryBuilder.update(any)).thenReturn(mockUpdateBuilder);
      when(mockUpdateBuilder.eq(any, any)).thenReturn(mockUpdateBuilder);
      when(mockUpdateBuilder.then(any)).thenAnswer((_) async => null);

      // Выполняем тест
      final result = await userProvider.addBonusPoints(pointsToAdd);

      // Проверяем результаты
      expect(result, true);
      // Проверяем, что методы были вызваны
      verify(mockQueryBuilder.update(any)).called(1);
      verify(mockUpdateBuilder.eq('id', userId)).called(1);
    });

    /// Тест очистки данных пользователя
    test('Очистка данных пользователя', () {
      // Выполняем тест
      userProvider.clearUser();

      // Проверяем результаты
      expect(userProvider.currentUser, isNull);
    });
  });
}
