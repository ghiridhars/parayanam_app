import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/book_selection_screen.dart';
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
      home: AppConfig.isDemoMode
          ? const _DemoModeInitializer()
          : const LoginScreen(),
    );
  }
}

/// Widget that loads demo user profile and navigates to BookSelectionScreen
class _DemoModeInitializer extends StatefulWidget {
  const _DemoModeInitializer();

  @override
  State<_DemoModeInitializer> createState() => _DemoModeInitializerState();
}

class _DemoModeInitializerState extends State<_DemoModeInitializer> {
  final DataService _dataService = DataService();
  UserProfile? _demoProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDemoProfile();
  }

  Future<void> _loadDemoProfile() async {
    final profile = await _dataService.getCurrentUserProfile();
    setState(() {
      _demoProfile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_demoProfile == null) {
      // Fallback to login screen if demo profile couldn't be loaded
      return const LoginScreen();
    }

    return BookSelectionScreen(userProfile: _demoProfile!);
  }
}
