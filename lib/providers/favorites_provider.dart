import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_utils.dart';

class FavoritesProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  Set<String> _favoriteProductIds = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Set<String> get favoriteProductIds => _favoriteProductIds;

  Future<void> loadFavorites() async {
    if (_client.auth.currentUser == null) {
      _favoriteProductIds = {};
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId);
      _favoriteProductIds = Set.from(response.map((e) => e['product_id']));
    } catch (e) {
      print('Error loading favorites: $e');
      _favoriteProductIds = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(BuildContext context, String productId) async {
    // Check authentication first
    if (!AppUtils.isUserAuthenticated(context)) {
      final authResult = await AppUtils.requireAuthentication(
        context,
        title: 'Добавление в избранное',
        message: 'Для добавления в избранное необходимо войти в аккаунт',
      );
      if (!authResult) {
        return false;
      }
      // Reload favorites after authentication
      await loadFavorites();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      if (_favoriteProductIds.contains(productId)) {
        await _client.from('favorites').delete().match({
          'user_id': userId,
          'product_id': productId,
        });
        _favoriteProductIds.remove(productId);
      } else {
        await _client.from('favorites').insert({
          'user_id': userId,
          'product_id': productId,
        });
        _favoriteProductIds.add(productId);
      }
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  Future<bool> addToFavorites(BuildContext context, String productId) async {
    // Check authentication first
    if (!AppUtils.isUserAuthenticated(context)) {
      final authResult = await AppUtils.requireAuthentication(
        context,
        title: 'Добавление в избранное',
        message: 'Для добавления в избранное необходимо войти в аккаунт',
      );
      if (!authResult) {
        return false;
      }
      // Reload favorites after authentication
      await loadFavorites();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });
      _favoriteProductIds.add(productId);
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromFavorites(String productId) async {
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('favorites').delete().match({
        'user_id': userId,
        'product_id': productId,
      });
      _favoriteProductIds.remove(productId);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clearFavorites() async {
    if (_client.auth.currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('favorites').delete().eq('user_id', userId);
      _favoriteProductIds.clear();
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
