import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/meal_plan.dart';
import '../models/menu_item.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  MealPlan? _mealPlan;
  List<MenuItem> _menuItems = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  MealPlan? get mealPlan => _mealPlan;
  List<MenuItem> get menuItems => _menuItems;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    setLoading(true);
    try {
      final response = await ApiService.login(username, password);
      if (response['success']) {
        _currentUser = User.fromJson(response['data']['user'] as Map<String, dynamic>);
        if (_currentUser != null) {
          await _fetchMealPlan();
          await _fetchTransactions();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in login: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    setLoading(true);
    try {
      final response = await ApiService.register(userData);
      if (response['success']) {
        _currentUser = User.fromJson(response['data']['user'] as Map<String, dynamic>);
        await _fetchMealPlan();
        await _fetchTransactions();
      }
      return response;
    } catch (e, stackTrace) {
      debugPrint('Error in register: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}'
      };
    } finally {
      setLoading(false);
    }
  }

  Future<void> _fetchMealPlan() async {
    if (_currentUser == null) return;
    try {
      final response = await ApiService.getMealPlan();
      if (response['success']) {
        _mealPlan = MealPlan.fromJson(response['data'] as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching meal plan: $e');
    }
  }

  Future<void> fetchMenu() async {
    setLoading(true);
    try {
      final response = await ApiService.getMenu();
      if (response['success']) {
        final items = (response['data']['items'] as List<dynamic>)
            .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
            .toList();
        _menuItems = items;
        notifyListeners();
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> _fetchTransactions() async {
    if (_currentUser == null) return;
    try {
      final response = await ApiService.getTransactions();
      if (response['success']) {
        final transactions = (response['data']['transactions'] as List<dynamic>)
            .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList();
        _transactions = transactions;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> verifyMeal(String qrUuid, String mealType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.verifyMeal(qrUuid, mealType);
      if (response['success']) {
        await _fetchMealPlan();
      } else {
        _error = response['message'] as String;
      }
    } catch (e) {
      _error = 'Failed to verify meal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBalance(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.addBalance(amount);
      if (response['success']) {
        await _fetchTransactions();
        final profileResponse = await ApiService.getProfile();
        if (profileResponse['success']) {
          _currentUser = User.fromJson(profileResponse['data'] as Map<String, dynamic>);
          notifyListeners();
        }
      } else {
        _error = response['message'] as String;
      }
    } catch (e) {
      _error = 'Failed to add balance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _mealPlan = null;
    _transactions = [];
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchMealPlan(),
        fetchMenu(),
        _fetchTransactions(),
      ]);
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }
} 