import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'authentication_screen.dart';

class AuthGate extends StatelessWidget {
  final WidgetBuilder authenticatedBuilder;

  const AuthGate({super.key, required this.authenticatedBuilder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to check sign-in status.')),
          );
        }

        if (snapshot.data == null) {
          return const AuthenticationScreen();
        }

        return authenticatedBuilder(context);
      },
    );
  }
}
