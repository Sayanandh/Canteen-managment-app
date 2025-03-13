import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_code_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/app_state.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Canteen QR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/qr_code': (context) => const QRCodeScreen(),
          '/qr_scanner': (context) => const QRScannerScreen(),
          '/meals': (context) => const MealsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        home: const LoginScreen(),
      ),
    );
  }
}
