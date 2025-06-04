import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myfinance/screens/auth_screen.dart';
import 'package:myfinance/theme/app_theme.dart';
import 'package:myfinance/services/auth_service.dart';
import 'package:myfinance/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFinance 50/25/25',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: _authService.authStateChanges,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          // If user is logged in, show dashboard, otherwise show auth screen
          return snapshot.hasData ? DashboardScreen() : AuthScreen();
        },
      ),
    );
  }
}

// Firebase configuration options
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
