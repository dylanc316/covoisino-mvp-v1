import 'package:covoisino/core/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';
import '../ui/auth_screen.dart';
import '../ui/home_screen.dart';
import '../main.dart'; // For AppLocalizations

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Wait for both auth and localization to be ready
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) {
        // Ensure localization is initialized
        if (AppLocalizations.of(context) == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show loading indicator while initial auth state is being determined
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check both auth state and user data
        if (auth.currentUser != null &&
            auth.currentUser!.name.isNotEmpty &&
            auth.currentUser!.email.isNotEmpty) {
          return const HomeScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}
