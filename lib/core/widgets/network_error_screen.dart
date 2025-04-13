import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NetworkErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const NetworkErrorScreen({
    Key? key,
    required this.onRetry,
    this.message =
        'No internet connection. Please check your network settings and try again.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 80,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 24),
                Text(
                  'Network Error',
                  style: AppTextStyles.headerStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTextStyles.bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'RETRY',
                    style: AppTextStyles.bodyStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
