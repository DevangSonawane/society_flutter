import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/crash_reporting_service.dart';
import '../../shared/widgets/animated_dialog.dart';
import '../../shared/widgets/custom_snackbar.dart';

/// Custom exception classes
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class AuthenticationException extends AppException {
  AuthenticationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class NotFoundException extends AppException {
  NotFoundException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Centralized error handler
class ErrorHandler {
  /// Handle and log an error
  static Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showToUser = false,
    BuildContext? buildContext,
  }) async {
    // Log the error
    LoggerService.error(
      'Error${context != null ? " in $context" : ""}',
      error,
      stackTrace,
    );

    // Report to crash reporting service
    await CrashReportingService.captureException(
      error,
      stackTrace: stackTrace,
      hint: context,
      extra: {
        'context': context ?? 'unknown',
        'showToUser': showToUser,
      },
    );

    // Show user-friendly message if needed
    if (showToUser && buildContext != null && buildContext.mounted) {
      _showErrorDialog(buildContext, error);
    }
  }

  /// Convert error to user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is NetworkException) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error is AuthenticationException) {
      return 'Authentication failed. Please login again.';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is NotFoundException) {
      return 'The requested resource was not found.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Show error dialog to user
  static void _showErrorDialog(BuildContext context, dynamic error) {
    AnimatedAlertDialog.show(
      context: context,
      title: 'Error',
      content: Text(getUserFriendlyMessage(error)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    CustomSnackbar.show(
      context,
      message: getUserFriendlyMessage(error),
      type: SnackbarType.error,
      duration: const Duration(seconds: 4),
    );
  }

  /// Wrap async function with error handling
  static Future<T?> safeAsync<T>(
    Future<T> Function() fn, {
    String? context,
    T? defaultValue,
    bool showToUser = false,
    BuildContext? buildContext,
  }) async {
    try {
      return await fn();
    } catch (e, stackTrace) {
      await handleError(
        e,
        stackTrace: stackTrace,
        context: context,
        showToUser: showToUser,
        buildContext: buildContext,
      );
      return defaultValue;
    }
  }
}

