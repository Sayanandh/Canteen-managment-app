import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static String? _token;
  static const int timeoutDuration = 30; // seconds

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  static Future<Map<String, dynamic>> testConnection() async {
    print('Testing connection to server: ${ApiEndpoints.baseUrl}');
    try {
      print('Sending health check request...');
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.health),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: timeoutDuration));

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Health check successful: $data');
        return {
          'success': true,
          'message': data['message'] ?? 'Connection successful!',
          'serverUrl': ApiEndpoints.baseUrl,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        print('Health check failed: $errorBody');
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Server is not responding correctly. Status code: ${response.statusCode}',
          'serverUrl': ApiEndpoints.baseUrl,
        };
      }
    } on TimeoutException catch (e) {
      print('Connection timeout: $e');
      return {
        'success': false,
        'message': 'Connection timed out. Please check if the server is running at: ${ApiEndpoints.baseUrl}',
        'serverUrl': ApiEndpoints.baseUrl,
      };
    } on http.ClientException catch (e) {
      print('Connection error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.message}. Please check your internet connection and server URL: ${ApiEndpoints.baseUrl}',
        'serverUrl': ApiEndpoints.baseUrl,
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'serverUrl': ApiEndpoints.baseUrl,
      };
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    print('Attempting login for user: $username');
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: timeoutDuration));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Login failed. Please check your credentials.',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection and try again.',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.message}. Please check your internet connection and try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    print('Attempting registration for user: ${userData['username']}');
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    print('Fetching user profile');
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.userProfile),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch profile.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> getMealPlan() async {
    print('Fetching meal plan');
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.mealPlan),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
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

  static Future<Map<String, dynamic>> getMenu() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.menu),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch menu.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyMeal(String qrUuid, String mealType) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + '/meal/verify'),
        headers: _getHeaders(),
        body: jsonEncode({
          'qr_uuid': qrUuid,
          'meal_type': mealType,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
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

  static Future<Map<String, dynamic>> getQrCode() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.qrCode),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
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

  static Future<Map<String, dynamic>> getMenuItems() async {
    print('Fetching menu items');
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.menuItems),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch menu items.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> getTransactions() async {
    print('Fetching transactions');
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.transactions),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch transactions.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> addBalance(double amount) async {
    print('Adding balance: $amount');
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.addBalance),
        headers: _getHeaders(),
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
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

  static Future<Map<String, dynamic>> getUserQRCode(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/qrcode/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
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

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
} 