import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static String? _token;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return data;
      } else {
        return {
          'success': false,
          'message': 'Login failed. Please check your credentials.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('Starting registration process...');
      print('Sending registration data: ${userData.toString()}');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print('Registration response status code: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        print('Registration successful, token received');
        return data;
      } else {
        final data = jsonDecode(response.body);
        print('Registration failed with error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      print('Registration error: $e');
      print('Error stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'message': 'Network error. Please check your internet connection and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getMealPlan(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/$userId/meal-plan'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch meal plan.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<List<dynamic>> getMenu() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.meals),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['meals'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> verifyMeal(String qrUuid, String mealType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/meals/verify'),
        headers: _getHeaders(),
        body: jsonEncode({
          'qr_uuid': qrUuid,
          'meal_type': mealType,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Meal verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to verify meal.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> addBalance(String userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/users/$userId/add-balance'),
        headers: _getHeaders(),
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Balance added successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add balance.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> getTransactions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/$userId/transactions'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch transactions.',
          'transactions': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
        'transactions': [],
      };
    }
  }

  static Future<Map<String, dynamic>> getUserQRCode(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/$userId/qr-code'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch QR code.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }
} 