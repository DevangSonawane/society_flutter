import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      // Check if session exists and is valid
      if (session != null && !session.isExpired) {
        // Try to restore user state
        await ref.read(authProvider.notifier).restoreSession();
      } else {
        // Session expired or invalid, clear it
        if (session != null) {
          await Supabase.instance.client.auth.signOut();
        }
      }
    } catch (e) {
      // If any error occurs, clear session and show login
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        // Ignore signout errors
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = ref.watch(authProvider);
    final session = Supabase.instance.client.auth.currentSession;

    // Check if we have a valid session and user
    final isValid = session != null && 
                    !session.isExpired && 
                    user != null;

    if (!isValid) {
      return const LoginScreen();
    }

    // Valid session and user - navigate to dashboard using routes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.dashboardRoute);
      }
    });

    // Return a placeholder while navigation happens
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
