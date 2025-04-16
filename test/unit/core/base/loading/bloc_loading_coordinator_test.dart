import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/core/base/bloc/base_bloc_state.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/base/loading/bloc_loading_coordinator.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';

class MockLoadingManager extends Mock implements LoadingManager {}

class TestState extends BaseBlocState {
  final LoadingState<String> testLoadingState;
  final LoadingState<int> secondLoadingState;
  final String baseError;

  const TestState({
    required this.baseError,
    required int timeStamp,
    this.testLoadingState = const LoadingState(),
    this.secondLoadingState = const LoadingState(),
  }) : super(timeStamp: timeStamp);

  @override
  List<Object> get props =>
      [timeStamp, baseError, testLoadingState, secondLoadingState];

  @override
  List<LoadingState> get loadingStates =>
      [testLoadingState, secondLoadingState];

  @override
  bool get hasInitializeError => baseError.isNotEmpty;

  @override
  bool get isInitialLoading => false;

  TestState copyWith({
    String? baseError,
    int? timeStamp,
    LoadingState<String>? testLoadingState,
    LoadingState<int>? secondLoadingState,
  }) {
    return TestState(
      baseError: baseError ?? this.baseError,
      timeStamp: timeStamp ?? this.timeStamp,
      testLoadingState: testLoadingState ?? this.testLoadingState,
      secondLoadingState: secondLoadingState ?? this.secondLoadingState,
    );
  }
}

void main() {
  late BlocLoadingCoordinator coordinator;
  late MockLoadingManager mockLoadingManager;

  setUp(() {
    mockLoadingManager = MockLoadingManager();
    coordinator = BlocLoadingCoordinator(mockLoadingManager);
  });

  group('BlocLoadingCoordinator', () {
    test('should show loading on initial load', () {
      TestState state = const TestState(baseError: '', timeStamp: 0);

      coordinator.handleStateChange(state, state, isInitialLoad: true);

      verify(mockLoadingManager.showLoading()).called(1);
    });

    test('should show loading when state transitions to loading', () {
      TestState previousState = const TestState(baseError: '', timeStamp: 0);
      TestState currentState = previousState.copyWith(
        testLoadingState: const LoadingState<String>(isLoading: true),
      );

      coordinator.handleStateChange(previousState, currentState);

      verify(mockLoadingManager.showLoading()).called(1);
    });

    test(
        'should hide loading when state transitions from loading to non-loading',
        () {
      TestState previousState = TestState(
        baseError: '',
        timeStamp: 0,
        testLoadingState: const LoadingState<String>(isLoading: true),
      );
      TestState currentState = previousState.copyWith(
        testLoadingState: LoadingState<String>(
          isLoading: false,
          isLoadedSuccess: true,
          value: 'Success',
        ),
      );

      coordinator.handleStateChange(previousState, currentState);

      verify(mockLoadingManager.hideLoading()).called(1);
    });

    test('should hide loading on error state', () {
      TestState previousState = const TestState(baseError: '', timeStamp: 0);
      TestState currentState = previousState.copyWith(
        baseError: 'An error occurred',
      );

      coordinator.handleStateChange(previousState, currentState);

      verify(mockLoadingManager.hideLoading()).called(1);
    });

    test('should directly show loading when called', () {
      coordinator.showLoading();

      verify(mockLoadingManager.showLoading()).called(1);
    });

    test('should directly hide loading when called', () {
      coordinator.hideLoading();

      verify(mockLoadingManager.hideLoading()).called(1);
    });
  });
}
