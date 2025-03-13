// Remove all unused imports
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart';
// import '../constants/app_constants.dart';
// import '../models/user_model.dart';

class AuthService {
  // Mock method to check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user') != null;
  }

  // Mock method to get token
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? 'mock_token';
  }

  // Mock method to get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      return {
        'id': '1',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'student',
        'balance': 500.0,
      };
    }
    
    return null;
  }

  // Mock method to login
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', 'logged_in');
      await prefs.setString('token', 'mock_token');
      
      return {
        'success': true,
        'user': {
          'id': '1',
          'name': 'John Doe',
          'email': email,
          'role': 'student',
          'balance': 500.0,
        },
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }
  }

  // Mock method to register
  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', 'logged_in');
      await prefs.setString('token', 'mock_token');
      
      return {
        'success': true,
        'user': {
          'id': '1',
          'name': name,
          'email': email,
          'role': role,
          'balance': 0.0,
        },
      };
    } else {
      return {
        'success': false,
        'message': 'Please fill all required fields',
      };
    }
  }

  // Mock method to logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
  }
} 