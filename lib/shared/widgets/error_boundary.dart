import 'package:flutter/material.dart';
import '../../core/utils/error_handler.dart';

/// Error boundary widget to catch and display errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final String? context;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.context,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    // Catch Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack);
    };
  }

  void _handleError(dynamic error, StackTrace? stackTrace) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _error = error;
      });

      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: widget.context ?? 'ErrorBoundary',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback ??
          _DefaultErrorWidget(
            error: _error,
            onRetry: () {
              setState(() {
                _hasError = false;
                _error = null;
              });
            },
          );
    }

    return widget.child;
  }
}

/// Default error widget displayed when error boundary catches an error
class _DefaultErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ErrorHandler.getUserFriendlyMessage(error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

