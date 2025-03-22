class ApiEndpoints {
  // For Android Emulator use: http://10.0.2.2:5000/api
  // For Physical Device use: http://192.168.1.8:5000/api
  // For Web use: http://localhost:5000/api
  static const String baseUrl = 'http://192.168.1.8:5000/api';
  
  // Health check endpoint
  static const String health = '/health';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  static const String changePassword = '/users/password/change';
  static const String mealPlan = '/users/meal-plan';
  
  // QR Code endpoints
  static const String qrCode = '/qrcode';
  static const String regenerateQr = '/qrcode/regenerate';
  
  // Meal endpoints
  static const String meals = '/meals';
  static const String mealHistory = '/meals/history';
  
  // Menu endpoints
  static const String menu = '/menu';
  static const String menuItems = '/menu/items';
  
  // Transaction endpoints
  static const String transactions = '/transactions';
  static const String addBalance = '/balance/add';
  
  // Admin endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminTransactions = '/admin/transactions';
} 