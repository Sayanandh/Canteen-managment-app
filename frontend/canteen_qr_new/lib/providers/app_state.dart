import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/meal_plan.dart';
import '../models/menu_item.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  MealPlan? _mealPlan;
  List<MenuItem> _menuItems = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  MealPlan? get mealPlan => _mealPlan;
  List<MenuItem> get menuItems => _menuItems;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    setLoading(true);
    try {
      final response = await ApiService.login(username, password);
      _currentUser = User.fromJson(response['user']);
      if (_currentUser != null) {
        await _fetchMealPlan();
        await _fetchTransactions();
      }
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    setLoading(true);
    try {
      final response = await ApiService.register(userData);
      if (response['success'] == true) {
        _currentUser = User.fromJson(response['user']);
        await _fetchMealPlan();
        await _fetchTransactions();
      }
      return response;
    } catch (e, stackTrace) {
      print('Error in register: $e');
      print('Stack trace: $stackTrace');
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
      final response = await ApiService.getMealPlan(_currentUser!.id.toString());
      _mealPlan = MealPlan.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching meal plan: $e');
    }
  }

  Future<void> fetchMenu() async {
    setLoading(true);
    try {
      final response = await ApiService.getMenu();
      _menuItems = response.map((item) => MenuItem.fromJson(item)).toList();
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> _fetchTransactions() async {
    if (_currentUser == null) return;
    try {
      final response = await ApiService.getTransactions(_currentUser!.id.toString());
      if (response['success']) {
        _transactions = (response['transactions'] as List)
            .map((item) => Transaction.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> verifyMeal(String qrUuid, String mealType) async {
    setLoading(true);
    try {
      await ApiService.verifyMeal(qrUuid, mealType);
      await _fetchMealPlan();
      await _fetchTransactions();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addBalance(double amount) async {
    if (_currentUser == null) return;
    setLoading(true);
    try {
      await ApiService.addBalance(_currentUser!.id.toString(), amount);
      await _fetchTransactions();
      // Update current user to reflect new balance
      final response = await ApiService.getMealPlan(_currentUser!.id.toString());
      _currentUser = User.fromJson(response['user']);
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    _mealPlan = null;
    _transactions = [];
    notifyListeners();
  }
} 