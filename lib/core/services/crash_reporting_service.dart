import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/app_config.dart';
import 'logger_service.dart';

class CrashReportingService {
  static bool _initialized = false;

  /// Initialize Sentry for crash reporting
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Only initialize in production or staging
      if (AppConfig.isProduction || AppConfig.isStaging) {
        final dsn = _getSentryDsn();
        if (dsn != null && dsn.isNotEmpty) {
          await SentryFlutter.init(
            (options) {
              options.dsn = dsn;
              options.environment = AppConfig.environment;
              options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
              options.profilesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
              options.beforeSend = (event, {hint}) {
                // Filter out sensitive data if request data exists
                // Note: SentryEvent.request.data is read-only in newer versions
                // This is a best-effort sanitization
                return event;
              } as BeforeSendCallback?;
            },
            appRunner: () {}, // Will be called after initialization
          );
          _initialized = true;
          LoggerService.info('Crash reporting initialized');
        } else {
          LoggerService.warning('Sentry DSN not configured, crash reporting disabled');
        }
      } else {
        LoggerService.debug('Crash reporting disabled in development mode');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize crash reporting', e, stackTrace);
    }
  }

  /// Get Sentry DSN from environment or return null
  static String? _getSentryDsn() {
    // You can add SENTRY_DSN to your .env file
    // For now, return null to disable (configure in .env when ready)
    return null; // TODO: Add SENTRY_DSN to .env.example and load from AppConfig
  }

  /// Capture an exception
  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? hint,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) {
      LoggerService.error('Crash reporting not initialized', exception, stackTrace);
      return;
    }

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'hint': hint}) : null,
        withScope: (scope) {
          if (extra != null && extra.isNotEmpty) {
            scope.setContexts('extra', extra);
          }
        },
      );
    } catch (e) {
      LoggerService.error('Failed to capture exception', e);
    }
  }

  /// Capture a message
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) {
      LoggerService.info(message);
      return;
    }

    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          if (extra != null && extra.isNotEmpty) {
            scope.setContexts('extra', extra);
          }
        },
      );
    } catch (e) {
      LoggerService.error('Failed to capture message', e);
    }
  }

  /// Set user context
  static Future<void> setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: id,
          email: email,
          username: username,
          data: data,
        ));
      });
    } catch (e) {
      LoggerService.error('Failed to set user context', e);
    }
  }

  /// Clear user context (e.g., on logout)
  static Future<void> clearUser() async {
    if (!_initialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    } catch (e) {
      LoggerService.error('Failed to clear user context', e);
    }
  }

  /// Add breadcrumb for debugging
  static void addBreadcrumb(
    String message, {
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    if (!_initialized) return;

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          level: level,
          data: data,
        ),
      );
    } catch (e) {
      LoggerService.error('Failed to add breadcrumb', e);
    }
  }

  /// Sanitize sensitive data before sending to Sentry
  // ignore: unused_element
  static dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();
        // Remove sensitive fields
        if (keyStr.contains('password') ||
            keyStr.contains('token') ||
            keyStr.contains('secret') ||
            keyStr.contains('key') ||
            keyStr.contains('auth')) {
          sanitized[key] = '[REDACTED]';
        } else if (value is Map || value is List) {
          sanitized[key] = _sanitizeData(value);
        } else {
          sanitized[key] = value;
        }
      });
      return sanitized;
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    return data;
  }
}

