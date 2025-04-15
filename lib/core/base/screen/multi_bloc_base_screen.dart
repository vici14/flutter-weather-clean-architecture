import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_assignment/core/base/bloc/base_bloc.dart';
import 'package:weather_app_assignment/core/base/bloc/base_bloc_state.dart';
import 'package:weather_app_assignment/core/base/loading/bloc_loading_coordinator.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/widgets/error_screen.dart';

abstract class MultiProviderBlocScreen extends StatefulWidget {
  const MultiProviderBlocScreen({Key? key}) : super(key: key);
}

abstract class MultiProviderBlocScreenState<T extends MultiProviderBlocScreen>
    extends State<T> {
  late BlocLoadingCoordinator loadingCoordinator;

  // Override to provide all BLoC providers
  List<BlocProvider> createProviders();

  // List of states to monitor for loading/error conditions
  List<StateAccessor> getStateAccessors(BuildContext context);

  // Override to build content
  Widget buildContent(BuildContext context);

  // Override to initialize data after screen is built
  void initializeData(BuildContext context) {}

  // Override to handle retry action
  VoidCallback onRetry(BuildContext context);

  @override
  void initState() {
    super.initState();
    loadingCoordinator = BlocLoadingCoordinator(getIt<LoadingManager>());

    // Show initial loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: createProviders(),
      child: Builder(
        builder: (context) {
          // Setup listeners for all states
          final stateAccessors = getStateAccessors(context);

          return MultiBlocListener(
            listeners: createListeners(stateAccessors),
            child: Builder(
              builder: (context) {
                return _buildStateConsumer(context, stateAccessors, 0);
              },
            ),
          );
        },
      ),
    );
  }

  // Recursively build nested BlocConsumers for each state accessor
  Widget _buildStateConsumer(
      BuildContext context, List<StateAccessor> accessors, int index) {
    if (index >= accessors.length) {
      // We've processed all accessors, build the actual content
      return buildContent(context);
    }

    // Create BlocConsumer for current accessor
    return accessors[index].createConsumer(
      context,
      (context, state) {
        if (state.hasInitializeError) {
          return ErrorScreen(
            onRetry: () => onRetry(context),
          );
        }
        // Continue with next accessor in the chain
        return _buildStateConsumer(context, accessors, index + 1);
      },
      (context, state) =>
          handleStateChange(context, accessors[index].bloc, state),
    );
  }

  // Create type-safe BlocListeners for each accessor
  List<BlocListener> createListeners(List<StateAccessor> accessors) {
    final listeners = <BlocListener>[];

    for (final accessor in accessors) {
      listeners.add(accessor.createListener(
        context,
        (context, state) => handleStateChange(context, accessor.bloc, state),
      ));
    }

    return listeners;
  }

  // Override this to handle specific state changes
  void handleStateChange<B extends StateStreamable<S>, S extends BaseBlocState>(
      BuildContext context, B bloc, S state) {
    // Default implementation - override in subclasses for specific handling
  }
}

// Helper class to access BLoC states with proper typing
class StateAccessor<B extends StateStreamable<S>, S extends BaseBlocState> {
  final B bloc;
  S get state => bloc.state;

  StateAccessor(this.bloc);

  // Helper method to create properly typed BlocListener
  BlocListener<B, S> createListener(
      BuildContext context, void Function(BuildContext, S) customHandler) {
    return BlocListener<B, S>(
      bloc: bloc,
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        // Get the loading coordinator from the enclosing widget
        final coordinator = context
            .findAncestorStateOfType<MultiProviderBlocScreenState>()
            ?.loadingCoordinator;

        // Handle loading state changes
        if (state.isInitialLoading) {
          coordinator?.showLoading();
        } else {
          coordinator?.hideLoading();
        }

        // Additional custom state handling
        customHandler(context, state);
      },
    );
  }

  // Helper method to create properly typed BlocConsumer
  BlocConsumer<B, S> createConsumer(
      BuildContext context,
      Widget Function(BuildContext, S) buildFunction,
      void Function(BuildContext, S) listenFunction) {
    return BlocConsumer<B, S>(
      bloc: bloc,
      buildWhen: (previous, current) => previous != current,
      listenWhen: (previous, current) => previous != current,
      builder: buildFunction,
      listener: (context, state) {
        // Get the loading coordinator from the enclosing widget
        final coordinator = context
            .findAncestorStateOfType<MultiProviderBlocScreenState>()
            ?.loadingCoordinator;

        // Handle loading state changes
        if (state.isInitialLoading) {
          coordinator?.showLoading();
        } else {
          coordinator?.hideLoading();
        }

        // Additional custom state handling
        listenFunction(context, state);
      },
    );
  }
}
