import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

// Repositories
import 'repositories/auth_repository.dart';
import 'repositories/service_repository.dart';

// Cubits
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/service/service_cubit.dart';

// Routes
import 'routes/app_routes.dart';

// Utils
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local caching
  await Hive.initFlutter();

  runApp(const MotabaApp());
}

/// Root application widget with BLoC setup
class MotabaApp extends StatelessWidget {
  const MotabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories (singleton pattern)
    final authRepository = AuthRepository();
    final serviceRepository = ServiceRepository();

    return MultiRepositoryProvider(
      providers: [
        // Provide repositories for dependency injection
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ServiceRepository>.value(value: serviceRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // Provide Cubits for state management
          BlocProvider(create: (_) => AuthCubit(authRepository)),
          BlocProvider(create: (_) => ServiceCubit(serviceRepository)),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(),

              // Set initial route based on auth state
              initialRoute: state is AuthAuthenticated
                  ? AppRoutes.home
                  : AppRoutes.login,

              // Route generator for navigation
              onGenerateRoute: AppRoutes.generateRoute,

              // RTL support for Arabic
              locale: const Locale('ar', 'SA'),
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Build app theme with consistent styling
  ThemeData _buildTheme() {
    return ThemeData(
      // Primary color
      primaryColor: AppConstants.primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryBlue,
        primary: AppConstants.primaryBlue,
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppConstants.backgroundColor,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppConstants.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: AppConstants.primaryBlue,
            width: 2,
          ),
        ),
      ),

      // Use Material 3
      useMaterial3: true,

      // Font family (default system font, can be customized)
      fontFamily: 'Arial',
    );
  }
}
