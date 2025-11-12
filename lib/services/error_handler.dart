import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Service for handling errors and displaying error messages to users
class ErrorHandler {
  /// Handles errors by displaying user-friendly messages and logging
  static void handleError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    final errorMessage = customMessage ?? _getErrorMessage(error);
    
    // Log error for debugging
    logError(error, customMessage: customMessage);
    
    // Show snackbar with error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Logs error for debugging purposes
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? customMessage,
  }) {
    final message = customMessage ?? error.toString();
    developer.log(
      message,
      name: 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Error level
    );
  }

  /// Builds an error widget with message and retry button
  static Widget buildErrorWidget(
    String message, {
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a compact error widget for inline display
  static Widget buildInlineErrorWidget(
    String message, {
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.red.shade700,
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }

  /// Gets a user-friendly error message from an error object
  static String _getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    }

    // Database errors
    if (errorString.contains('database') ||
        errorString.contains('hive') ||
        errorString.contains('storage')) {
      return 'Database error. Please try again.';
    }

    // Format errors
    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Invalid data format. Please check your input.';
    }

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Permission denied. Please check app permissions.';
    }

    // Default message
    return 'An error occurred. Please try again.';
  }

  /// Shows a success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  /// Shows a warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}
