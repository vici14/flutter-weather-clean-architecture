import 'package:weather_app_assignment/core/base/bloc/base_bloc_state.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';

class BlocLoadingCoordinator {
  final LoadingManager loadingManager;

  BlocLoadingCoordinator(this.loadingManager);

  // Called when a state changes
  void handleStateChange<S extends BaseBlocState>(S previous, S current,
      {bool isInitialLoad = false}) {
    // For initial load, show loading immediately
    if (isInitialLoad) {
      loadingManager.showLoading();
      return;
    }

    // Handle error states
    if (current.hasInitializeError && !previous.hasInitializeError) {
      loadingManager.hideLoading();
      return;
    }

    // Track loading state transitions
    bool wasLoading = _isStateLoading(previous);
    bool isLoading = _isStateLoading(current);

    if (isLoading && !wasLoading) {
      loadingManager.showLoading();
    } else if (!isLoading && wasLoading) {
      loadingManager.hideLoading();
    }
  }

  // This is a reflective method to find LoadingState properties in any state
  bool _isStateLoading(BaseBlocState state) {
    // Check all properties of type LoadingState in the state
    bool isAnyLoading = false;

    // Use reflection to find LoadingState properties
    for (var field in state.props) {
      if (field is LoadingState) {
        if (field.isLoading) {
          return true;
        }
      }
    }

    return isAnyLoading;
  }

  // Show loading directly
  void showLoading() {
    loadingManager.showLoading();
  }

  // Hide loading directly
  void hideLoading() {
    loadingManager.hideLoading();
  }
}
