import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/full_screen_loading.dart';

enum LoadingStatus { initial, loading, success, error }

class LoadingManager {
  final GlobalKey<NavigatorState> _navigatorKey;
  OverlayEntry? _overlayEntry;
  int _loadingCounter = 0;

  // Stream controller for loading events
  final _loadingController = StreamController<LoadingStatus>.broadcast();

  // Public stream that UI can listen to
  Stream<LoadingStatus> get loadingStream => _loadingController.stream;

  LoadingManager(this._navigatorKey);

  bool get isLoading => _loadingCounter > 0;

  void showLoading() {
    if (_loadingCounter == 0) {
      _createOverlayEntry();
      _loadingController.add(LoadingStatus.loading);
    }
    _loadingCounter++;
  }

  void hideLoading() {
    if (_loadingCounter > 0) {
      _loadingCounter--;
      if (_loadingCounter == 0) {
        _removeOverlayEntry();
        _loadingController.add(LoadingStatus.success);
      }
    }
  }

  void showLoadingWithMessage(String message) {
    if (_loadingCounter == 0) {
      _createOverlayEntryWithMessage(message);
      _loadingController.add(LoadingStatus.loading);
    } else {
      // Replace existing overlay with new message
      _removeOverlayEntry();
      _createOverlayEntryWithMessage(message);
    }
    _loadingCounter++;
  }

  // Force hide all loading overlays
  void forceHideLoading() {
    _loadingCounter = 0;
    _removeOverlayEntry();
    _loadingController.add(LoadingStatus.success);
  }

  // Clean up resources
  void dispose() {
    _loadingController.close();
  }

  void _createOverlayEntry() {
    _removeOverlayEntry(); // Ensure no duplicate overlays

    final overlay = _navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => const FullScreenLoading(),
    );

    overlay.insert(_overlayEntry!);
  }

  void _createOverlayEntryWithMessage(String message) {
    _removeOverlayEntry(); // Ensure no duplicate overlays

    final overlay = _navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: AppColors.appBackground,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RotatingImage(),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
