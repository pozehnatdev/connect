import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectapp/services/auth_provider.dart';
import 'package:connectapp/screens/home_screen.dart';
import 'package:connectapp/screens/signInScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 8), () {
      if (!mounted || _navigated) return;
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
          if (!authProvider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_navigated && mounted) _navigateToNextScreen();
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
    if (!mounted || _navigated) return;
    _navigated = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => authProvider.isSignedIn ? HomePage() : SignInScreen(),
      ),
    );
  }
}
