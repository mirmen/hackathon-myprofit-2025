import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';

/// Провайдер для управления подписками
/// Загружает планы подписок и обрабатывает оформление подписок
class SubscriptionsProvider extends ChangeNotifier {
  /// Клиент Supabase для работы с базой данных
  final SupabaseClient _client = Supabase.instance.client;

  /// Список доступных планов подписок
  List<SubscriptionPlan> _subscriptionPlans = [];

  /// Флаг загрузки данных подписок
  bool _isLoading = false;

  /// Геттеры для доступа к данным
  List<SubscriptionPlan> get subscriptionPlans => _subscriptionPlans;
  bool get isLoading => _isLoading;

  /// Загрузка планов подписок из базы данных
  /// Сортирует планы по ID
  Future<void> loadSubscriptionPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('subscription_plans')
          .select()
          .order('id');

      _subscriptionPlans = response
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      print('Ошибка при загрузке планов подписок: $e');
      _subscriptionPlans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Оформление подписки на определенный план
  /// @param planId - ID плана подписки для оформления
  /// @return true если успешно, false если произошла ошибка
  Future<bool> subscribeToPlan(String planId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Проверяем авторизацию пользователя
      if (userId == null) return false;

      // Логика оформления подписки
      // Пока просто обновляем активные подписки пользователя
      await _client
          .from('profiles')
          .update({
            'active_subscriptions': [planId],
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Ошибка при оформлении подписки: $e');
      return false;
    }
  }
}
