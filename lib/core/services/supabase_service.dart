import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scasa_flutter_app/core/services/logger_service.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Ensure user is authenticated before making queries
  /// Throws exception if not authenticated or session expired
  static void ensureAuthenticated() {
    final user = client.auth.currentUser;
    final session = client.auth.currentSession;
    
    if (user == null || session == null) {
      LoggerService.warning('Query attempted without authentication');
      // Clear any stale state
      try {
        client.auth.signOut();
      } catch (_) {
        // Ignore signout errors
      }
      throw Exception('Authentication required. Please log in.');
    }
    
    if (session.isExpired) {
      LoggerService.warning('Session expired for user: ${user.email}');
      // Clear expired session
      try {
        client.auth.signOut();
      } catch (_) {
        // Ignore signout errors
      }
      throw Exception('Session expired. Please log in again.');
    }
    
    LoggerService.debug('Authenticated user: ${user.email}');
  }
  
  /// Handle and log Supabase errors with context
  /// Returns user-friendly error message
  static String handleError(dynamic error, [String? context]) {
    String message = 'Unknown error';
    String contextStr = context != null ? " in $context" : "";
    
    if (error is PostgrestException) {
      message = error.message.isNotEmpty ? error.message : 'Database error';
      LoggerService.error('Postgrest Error$contextStr: $message', error);
      
      // Provide user-friendly error messages
      if (message.contains('permission denied') || 
          message.contains('row-level security') ||
          message.contains('new row violates row-level security')) {
        return 'Permission denied. Check your authentication and RLS policies.';
      }
      if (message.contains('relation') && message.contains('does not exist')) {
        return 'Table not found. Please check your database schema.';
      }
      if (message.contains('null value') && message.contains('violates not-null constraint')) {
        return 'Required field is missing. Please check your data.';
      }
      
      return 'Database error: $message';
    } else if (error is AuthException) {
      message = 'Authentication error: ${error.message}';
      LoggerService.error('Auth Error$contextStr: $message', error);
      return message;
    } else if (error is Exception) {
      message = error.toString();
      LoggerService.error('Exception$contextStr: $message', error);
      return message;
    } else {
      message = error.toString();
      LoggerService.error('Error$contextStr: $message', error);
      return message;
    }
  }
  
  /// Execute a query with proper error handling and authentication check
  static Future<T> executeQuery<T>({
    required Future<T> Function() query,
    required String context,
    bool requireAuth = true,
  }) async {
    try {
      if (requireAuth) {
        try {
          ensureAuthenticated();
        } on Exception catch (authError) {
          // If auth fails, clear session and rethrow
          LoggerService.warning('Authentication failed in $context: $authError');
          try {
            client.auth.signOut();
          } catch (_) {
            // Ignore signout errors
          }
          rethrow;
        }
      }
      
      return await query();
    } on PostgrestException catch (e) {
      // Check if it's an auth-related error
      if (e.message.contains('JWT') || 
          e.message.contains('authentication') ||
          e.message.contains('permission denied') ||
          e.code == 'PGRST301') {
        LoggerService.warning('Auth error in query $context, clearing session');
        try {
          client.auth.signOut();
        } catch (_) {
          // Ignore signout errors
        }
      }
      final errorMsg = handleError(e, context);
      throw Exception(errorMsg);
    } on AuthException catch (e) {
      LoggerService.warning('Auth exception in $context, clearing session');
      try {
        client.auth.signOut();
      } catch (_) {
        // Ignore signout errors
      }
      final errorMsg = handleError(e, context);
      throw Exception(errorMsg);
    } catch (e, stackTrace) {
      // Check if it's an auth-related error message
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('authentication') || 
          errorStr.contains('session expired') ||
          errorStr.contains('jwt')) {
        LoggerService.warning('Auth-related error in $context, clearing session');
        try {
          client.auth.signOut();
        } catch (_) {
          // Ignore signout errors
        }
      }
      LoggerService.error('Unexpected error $context', e, stackTrace);
      final errorMsg = handleError(e, context);
      throw Exception(errorMsg);
    }
  }
}

