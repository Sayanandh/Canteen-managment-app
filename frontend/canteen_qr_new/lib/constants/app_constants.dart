import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color constants
class AppColors {
  static const Color primary = Color(0xFF3F51B5);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color text = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}

/// App text style constants
class AppTextStyles {
  static final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static final TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static final TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

/// App spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// App border radius constants
class AppBorderRadius {
  static final BorderRadius sm = BorderRadius.circular(4);
  static final BorderRadius md = BorderRadius.circular(8);
  static final BorderRadius lg = BorderRadius.circular(12);
  static final BorderRadius xl = BorderRadius.circular(16);
  static final BorderRadius xxl = BorderRadius.circular(24);
  static final BorderRadius circular = BorderRadius.circular(100);
}

class ApiEndpoints {
  // For physical device access
  static const String baseUrl = 'http://192.168.1.89:5000/api';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/users';
  static const String meals = '/menu';
  static const String transactions = '/transactions';
  static const String qrCode = '/qrcode';
} 