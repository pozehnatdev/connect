import 'package:connectapp/screens/signInScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectapp/services/auth_provider.dart';
import 'package:connectapp/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth state and navigate accordingly
    Future.delayed(Duration(seconds: 8), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoading) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Listen for auth state changes
          if (!authProvider.isLoading) {
            // Delayed navigation to prevent multiple navigations
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToNextScreen();
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Icon(
                  Icons.connect_without_contact,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 24),
                Text(
                  'Connect App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToNextScreen() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isSignedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    }
  }
}
