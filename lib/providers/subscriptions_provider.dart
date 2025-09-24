import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription.dart';

class SubscriptionsProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<SubscriptionPlan> _subscriptionPlans = [];
  bool _isLoading = false;

  List<SubscriptionPlan> get subscriptionPlans => _subscriptionPlans;
  bool get isLoading => _isLoading;

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
      print('Error loading subscription plans: $e');
      _subscriptionPlans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> subscribeToPlan(String planId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Add subscription logic here
      // For now, just update user's active subscriptions
      await _client
          .from('profiles')
          .update({
            'active_subscriptions': [planId],
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error subscribing to plan: $e');
      return false;
    }
  }
}
