import 'package:logger/logger.dart';
import '../config/app_config.dart';

class LoggerService {
  static Logger? _logger;

  static Logger get logger {
    _logger ??= Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _getLogLevel(),
    );
    return _logger!;
  }

  static Level _getLogLevel() {
    if (AppConfig.isProduction) {
      return Level.warning; // Only warnings and errors in production
    } else if (AppConfig.isStaging) {
      return Level.info; // Info, warnings, and errors in staging
    } else {
      return Level.debug; // All logs in development
    }
  }

  // Convenience methods
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Log with context
  static void logWithContext(
    String level,
    String message, {
    String? context,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final contextMessage = context != null ? '[$context] $message' : message;
    
    final logMessage = metadata != null && metadata.isNotEmpty
        ? '$contextMessage | Metadata: $metadata'
        : contextMessage;

    switch (level.toLowerCase()) {
      case 'debug':
        debug(logMessage, error, stackTrace);
        break;
      case 'info':
        info(logMessage, error, stackTrace);
        break;
      case 'warning':
      case 'warn':
        warning(logMessage, error, stackTrace);
        break;
      case 'error':
        error(logMessage, error, stackTrace);
        break;
      case 'fatal':
        fatal(logMessage, error, stackTrace);
        break;
      default:
        info(logMessage, error, stackTrace);
    }
  }
}

