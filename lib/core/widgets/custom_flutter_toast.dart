import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomFlutterToast {
  static OverlayEntry? _currentToast;

  static void showToast({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    BuildContext? context,
  }) {
    // Dismiss current toast if exists
    _currentToast?.remove();
    
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData? icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case ToastType.info:
      default:
        backgroundColor = AppColors.primaryBlue;
        icon = Icons.info;
        break;
    }

    final overlay = Overlay.of(context ?? navigatorKey.currentContext!);

    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: _ToastAnimation(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    Future.delayed(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  static void showSuccessToast(String message) {
    showToast(message: message, type: ToastType.success);
  }

  static void showErrorToast(String message) {
    showToast(message: message, type: ToastType.error);
  }

  static void showWarningToast(String message) {
    showToast(message: message, type: ToastType.warning);
  }

  static void showInfoToast(String message) {
    showToast(message: message, type: ToastType.info);
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
}

// Animation widget for smooth appearance and disappearance
class _ToastAnimation extends StatefulWidget {
  final Widget child;

  const _ToastAnimation({required this.child});

  @override
  _ToastAnimationState createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

// Global navigator key to access context anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();