import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'core/constants/app_config.dart';
import 'services/data_service.dart';
import 'models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize demo mode if enabled
  if (AppConfig.isDemoMode) {
    final dataService = DataService();
    final demoProfile = UserProfile(
      email: AppConfig.demoUserEmail,
      name: AppConfig.demoUserName,
      passwordHash: 'demo-hash',
      createdAt: DateTime.now(),
    );
    await dataService.setDemoUser(demoProfile);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
