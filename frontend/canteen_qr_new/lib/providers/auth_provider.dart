import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:canteen_qr_new/services/logger_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool get isAuthenticated => _token != null;
  
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  static const String baseUrl = 'http://localhost:5000/api';  // Change this for production

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _user = data['user'];
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(_user));
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.error('Login error', e);
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    _token = prefs.getString('token');
    _user = json.decode(prefs.getString('user') ?? '{}');
    notifyListeners();
    return true;
  }
} 