import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/language_selection.dart';
import 'auth/login_screen.dart';
import 'farmer/farmer_dashboard.dart';
import 'manufacturer/manufacturer_dashboard.dart'; // Renamed from processor
import 'admin/admin_dashboard.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/language_provider.dart';
import 'core/providers/bid_provider.dart';
import 'core/providers/auth_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite database
  await DatabaseService().database;
  
  runApp(const AgriWasteApp());
}

class AgriWasteApp extends StatelessWidget {
  const AgriWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => BidProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AppInitializer(),
    );
  }
}

/// Initializes app and checks auth state
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'Agri Waste to Fertilizer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: _getInitialScreen(authProvider),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/farmer-dashboard': (context) => const FarmerDashboard(),
            '/manufacturer-dashboard': (context) => const ManufacturerDashboard(),
            '/processor-dashboard': (context) => const ManufacturerDashboard(), // Backward compatibility
            '/admin-dashboard': (context) => const AdminDashboard(),
          },
        );
      },
    );
  }

  Widget _getInitialScreen(AuthProvider authProvider) {
    // Show loading while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If authenticated, navigate to appropriate dashboard
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final role = authProvider.currentUser!.role;
      if (role == 'farmer') {
        return const FarmerDashboard();
      } else if (role == 'manufacturer' || role == 'processor') {
        return const ManufacturerDashboard();
      } else if (role == 'admin') {
        return const AdminDashboard();
      }
    }

    // Otherwise show language selection
    return const LanguageSelectionScreen();
  }
}
