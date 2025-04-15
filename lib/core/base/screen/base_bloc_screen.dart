import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_assignment/core/base/bloc/base_bloc.dart';
import 'package:weather_app_assignment/core/base/bloc/base_bloc_state.dart';
import 'package:weather_app_assignment/core/base/loading/bloc_loading_coordinator.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/widgets/error_screen.dart';

abstract class BaseBlocScreen<B extends BaseBloc<dynamic, S>,
    S extends BaseBlocState> extends StatefulWidget {
  const BaseBlocScreen({Key? key}) : super(key: key);
}

abstract class BaseBlocScreenState<B extends BaseBloc<dynamic, S>,
    S extends BaseBlocState> extends State<BaseBlocScreen<B, S>> {
  late B bloc;
  late BlocLoadingCoordinator loadingCoordinator;

  // Override to create the BLoC
  B createBloc();

  // Override to build content when loaded
  Widget buildContent(BuildContext context, S state);

  // Override to build error widget
  Widget buildError(BuildContext context, S state) {
    return ErrorScreen(
      onRetry: () => onRetry(state),
    );
  }

  // Override to handle retry action
  void onRetry(S state) {
    // Default implementation
  }

  @override
  void initState() {
    super.initState();
    bloc = createBloc();
    loadingCoordinator = BlocLoadingCoordinator(getIt<LoadingManager>());

    // Initialize with loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingCoordinator.handleStateChange(bloc.state, bloc.state,
          isInitialLoad: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: (context) => bloc,
      child: BlocConsumer<B, S>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          // Sync BLoC state changes with LoadingManager
          loadingCoordinator.handleStateChange(bloc.state, state);
        },
        builder: (context, state) {
          if (state.hasInitializeError) {
            return buildError(context, state);
          }

          return buildContent(context, state);
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    bloc.close();
    super.dispose();
  }
}
