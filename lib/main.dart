import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/character_controller.dart';
import 'models/user_model.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'views/navigation_root.dart';
import 'views/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users_box');

  // Inisialisasi controller global secara permanen agar selalu tersedia di seluruh layar
  Get.put(CharacterController(), permanent: true);

  final bool isLoggedIn = await LocalStorageService.isLoggedIn();

  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.spaceDark,
        primaryColor: AppTheme.portalGreen,
        canvasColor: AppTheme.surfaceCard,
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.portalGreen,
          secondary: AppTheme.portalBlue,
          surface: AppTheme.surfaceCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.surfaceCard,
          foregroundColor: AppTheme.portalGreen,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppTheme.portalGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppTheme.surfaceCardLight,
          contentTextStyle: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const NavigationRoot() : const LoginPage(),
    );
  }
}
