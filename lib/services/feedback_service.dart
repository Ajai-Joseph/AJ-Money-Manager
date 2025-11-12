import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Service for providing user feedback through various mechanisms
class FeedbackService {
  /// Shows a success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
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
        action: action,
      ),
    );
  }

  /// Shows an error snackbar
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
      ),
    );
  }

  /// Shows an info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
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
        action: action,
      ),
    );
  }

  /// Shows a warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
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
        action: action,
      ),
    );
  }

  /// Shows a toast message (quick feedback)
  static void showToast(
    String message, {
    Toast? length,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      textColor: textColor ?? Colors.white,
      fontSize: 14.0,
    );
  }

  /// Shows a success toast
  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Shows an error toast
  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Shows a confirmation dialog for destructive actions
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDestructive ? Colors.red.shade700 : Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? Colors.red.shade700 : null,
                foregroundColor: Colors.white,
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Shows a delete confirmation dialog
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) async {
    return showConfirmationDialog(
      context,
      title: 'Delete $itemName?',
      message: customMessage ?? 'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  /// Shows a loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 24),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dismisses the loading dialog
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Shows a bottom sheet with options
  static Future<T?> showOptionsBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<BottomSheetOption<T>> options,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...options.map((option) {
                return ListTile(
                  leading: option.icon != null
                      ? Icon(
                          option.icon,
                          color: option.isDestructive ? Colors.red.shade700 : null,
                        )
                      : null,
                  title: Text(
                    option.label,
                    style: TextStyle(
                      color: option.isDestructive ? Colors.red.shade700 : null,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(option.value);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Shows visual feedback with a ripple effect
  static void showRippleFeedback(BuildContext context) {
    // This is handled automatically by Material widgets
    // but can be customized if needed
  }

  /// Shows a custom dialog
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        );
      },
    );
  }
}

/// Model for bottom sheet options
class BottomSheetOption<T> {
  final String label;
  final T value;
  final IconData? icon;
  final bool isDestructive;

  const BottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });
}
