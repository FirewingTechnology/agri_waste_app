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
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Agri Waste to Fertilizer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const LanguageSelectionScreen(),
              '/login': (context) => const LoginScreen(),
              '/farmer-dashboard': (context) => const FarmerDashboard(),
              '/manufacturer-dashboard': (context) => const ManufacturerDashboard(),
              '/processor-dashboard': (context) => const ManufacturerDashboard(), // Backward compatibility
              '/admin-dashboard': (context) => const AdminDashboard(),
            },
          );
        },
      ),
    );
  }
}
