import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        // For demo purposes, we'll create a mock user
        _user = User(
          id: '1',
          name: 'John Doe',
          email: 'john.doe@example.com',
          role: 'student',
          balance: 500.0,
        );
        _isLoggedIn = true;
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      
      if (response['access_token'] != null) {
        _user = User(
          id: response['user']['id'].toString(),
          name: response['user']['full_name'],
          email: response['user']['email'],
          role: response['user']['role'],
          balance: response['user']['balance'].toDouble(),
        );
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return response;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return {'error': _error};
      }
    } catch (e) {
      _error = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return {'error': _error};
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, we'll create a mock user
      await Future.delayed(const Duration(seconds: 1));

      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _user = User(
          id: '1',
          name: name,
          email: email,
          role: role,
          balance: 0.0,
        );
        _isLoggedIn = true;

        // Save user to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', 'logged_in');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear user data
      _user = null;
      _isLoggedIn = false;

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, we'll just update the balance
      await Future.delayed(const Duration(seconds: 1));

      if (_user != null) {
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: _user!.role,
          balance: _user!.balance + 10.0, // Add 10 to balance for demo
          profileImage: _user!.profileImage,
        );
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFunds(double amount) async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.addBalance(_user!.id.toString(), amount);
      
      if (response['success']) {
        await refreshUserProfile();
        return true;
      } else {
        _error = response['message'];
        return false;
      }
    } catch (e) {
      _error = 'Failed to add funds';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 