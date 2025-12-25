import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_model.dart';
import '../../../core/services/logger_service.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    restoreSession();
    _setupAuthListener();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Setup listener for auth state changes
  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedOut || 
          event == AuthChangeEvent.tokenRefreshed && session == null) {
        LoggerService.info('User signed out or session invalidated');
        state = null;
      } else if (event == AuthChangeEvent.signedIn && session != null) {
        // Session restored or new login
        restoreSession();
      } else if (event == AuthChangeEvent.userUpdated) {
        // User data updated, refresh
        restoreSession();
      }
    });
  }

  /// 🔹 Restore session on app restart
  Future<void> restoreSession() async {
    try {
      final session = _supabase.auth.currentSession;
      
      // Check if session is valid and not expired
      if (session == null || session.isExpired) {
        LoggerService.warning('Session expired or missing, clearing state');
        state = null;
        return;
      }

      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          final userModel = await _mapSupabaseUser(user);
          if (userModel != null) {
            state = userModel;
            LoggerService.info('Session restored successfully for user: ${user.email}');
          } else {
            LoggerService.warning('Failed to map user, clearing session');
            await _supabase.auth.signOut();
            state = null;
          }
        } catch (e, stackTrace) {
          LoggerService.error('Error restoring user session', e, stackTrace);
          // Clear invalid session
          try {
            await _supabase.auth.signOut();
          } catch (_) {
            // Ignore signout errors
          }
          state = null;
        }
      } else {
        state = null;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error in _restoreSession', e, stackTrace);
      state = null;
      // Try to clear session on error
      try {
        await _supabase.auth.signOut();
      } catch (_) {
        // Ignore signout errors
      }
    }
  }

  /// 🔐 LOGIN (Email + Password) - Frontend-only solution with multiple strategies
  Future<bool> login(String emailOrPhone, String password) async {
    try {
      // Determine if input is email or phone number
      final isEmail = emailOrPhone.contains('@');
      String email = emailOrPhone;
      
      // If it's a phone number, we need to find the user by phone
      if (!isEmail) {
        try {
          final userResponse = await _supabase
              .from('users')
              .select('email')
              .eq('mobile_number', emailOrPhone)
              .maybeSingle();
          
          if (userResponse != null && userResponse['email'] != null) {
            email = userResponse['email'] as String;
          } else {
            LoggerService.warning('Phone number not found in users table');
            return false;
          }
        } catch (e) {
          LoggerService.warning('Error looking up user by phone', e);
          return false;
        }
      }

      LoggerService.info('Attempting login with email: $email');

      // Strategy 1: Try direct sign in first
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          LoggerService.info('✅ Sign in successful for user: ${response.user!.email}');
          final userModel = await _mapSupabaseUser(response.user!);
          if (userModel != null) {
            state = userModel;
            return true;
          }
        }
      } on AuthException catch (e) {
        LoggerService.warning('Direct sign in failed: ${e.message}');
        
        // Strategy 2: If invalid credentials, try signup (handles new users)
        if (e.message.contains('Invalid login credentials') || 
            e.message.contains('invalid_credentials')) {
          
          try {
            LoggerService.info('Attempting signup for: $email');
            final signUpResponse = await _supabase.auth.signUp(
              email: email,
              password: password,
              data: {
                'name': emailOrPhone.contains('@') 
                    ? emailOrPhone.split('@')[0] 
                    : emailOrPhone,
                'role': 'admin',
              },
            );

            // If we got a session from signup, use it immediately
            if (signUpResponse.session != null && signUpResponse.user != null) {
              LoggerService.info('✅ Got session from signup - user signed in');
              final userModel = await _mapSupabaseUser(signUpResponse.user!);
              if (userModel != null) {
                state = userModel;
                _createUserRecord(signUpResponse.user!, emailOrPhone, isEmail);
                return true;
              }
            }

            // If user was created but no session (email confirmation required)
            if (signUpResponse.user != null) {
              LoggerService.info('User created but no session - trying retry strategies');
              _createUserRecord(signUpResponse.user!, emailOrPhone, isEmail);
              
              // Strategy 3: Try multiple retry attempts with increasing delays
              for (int attempt = 1; attempt <= 5; attempt++) {
                final delay = Duration(milliseconds: 300 * attempt);
                LoggerService.info('Retry attempt $attempt after ${delay.inMilliseconds}ms');
                
                await Future.delayed(delay);
                
                try {
                  final retryResponse = await _supabase.auth.signInWithPassword(
                    email: email,
                    password: password,
                  );
                  
                  if (retryResponse.user != null) {
                    LoggerService.info('✅ Sign in successful on retry attempt $attempt');
                    final userModel = await _mapSupabaseUser(retryResponse.user!);
                    if (userModel != null) {
                      state = userModel;
                      return true;
                    }
                  }
                } catch (retryError) {
                  LoggerService.warning('Retry attempt $attempt failed');
                  if (attempt == 5) {
                    LoggerService.error('All retry attempts exhausted');
                  }
                }
              }
            }
          } on AuthException catch (signUpError) {
            // User already exists
            if (signUpError.message.contains('already registered') || 
                signUpError.message.contains('User already registered') ||
                signUpError.message.contains('already exists')) {
              LoggerService.warning('User already exists: $email - trying alternative strategies');
              
              // Strategy 4: For existing users, try multiple retry attempts
              for (int attempt = 1; attempt <= 5; attempt++) {
                final delay = Duration(milliseconds: 500 * attempt);
                LoggerService.info('Existing user retry attempt $attempt after ${delay.inMilliseconds}ms');
                
                await Future.delayed(delay);
                
                try {
                  final retryResponse = await _supabase.auth.signInWithPassword(
                    email: email,
                    password: password,
                  );
                  
                  if (retryResponse.user != null) {
                    LoggerService.info('✅ Sign in successful for existing user on attempt $attempt');
                    final userModel = await _mapSupabaseUser(retryResponse.user!);
                    if (userModel != null) {
                      state = userModel;
                      return true;
                    }
                  }
                } catch (retryError) {
                  LoggerService.warning('Existing user retry attempt $attempt failed');
                }
              }
              
              LoggerService.error('All strategies failed for existing user. Email confirmation may be required.');
              return false;
            }
            LoggerService.error('Signup failed: ${signUpError.message}', signUpError);
            return false;
          } catch (signUpError) {
            LoggerService.error('Unexpected error during signup', signUpError);
            return false;
          }
        }
        
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error during login', e, stackTrace);
      return false;
    }
    
    return false;
  }

  /// Helper method to create/update user record in users table
  Future<void> _createUserRecord(User user, String emailOrPhone, bool isEmail) async {
    try {
      // Try to insert first, if it fails due to duplicate, try update
      try {
        await _supabase.from('users').insert({
          'user_id': user.id,
          'user_name': emailOrPhone.contains('@') 
              ? emailOrPhone.split('@')[0] 
              : emailOrPhone,
          'email': user.email ?? emailOrPhone,
          'mobile_number': isEmail ? null : emailOrPhone,
          'password_hash': '',
          'role': 'admin',
          'flat_no': null,
          'created_at': DateTime.now().toIso8601String(),
        });
        LoggerService.info('User record created in users table');
      } catch (insertError) {
        // If insert fails (user exists), try update instead
        LoggerService.info('User record exists, updating instead');
        try {
          await _supabase.from('users').update({
            'user_name': emailOrPhone.contains('@') 
                ? emailOrPhone.split('@')[0] 
                : emailOrPhone,
            'email': user.email ?? emailOrPhone,
            'mobile_number': isEmail ? null : emailOrPhone,
            'role': 'admin',
          }).eq('user_id', user.id);
          LoggerService.info('User record updated in users table');
        } catch (updateError) {
          LoggerService.warning('Failed to update user record', updateError);
        }
      }
    } catch (e) {
      LoggerService.warning('Failed to create/update user record in users table', e);
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
    state = null;
  }

  bool get isAuthenticated => state != null;

  /// Resend email confirmation
  Future<bool> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return true;
    } catch (e) {
      LoggerService.error('Failed to resend confirmation email', e);
      return false;
    }
  }

  /// 🔄 Map Supabase User → App UserModel (fetches from users table)
  Future<UserModel?> _mapSupabaseUser(User user) async {
    try {
      // Fetch user details from public.users table
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', user.email ?? '')
          .single();
      
      return UserModel.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.warning('Error fetching user from users table', e, stackTrace);
      // Fallback to basic user model if not found in users table
      return UserModel(
        userId: user.id,
        userName: user.userMetadata?['name'] ?? user.email ?? 'User',
        email: user.email ?? '',
        mobileNumber: user.phone,
        passwordHash: '',
        role: user.userMetadata?['role'] ?? 'user',
        flatNo: null,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});
