import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';

void main() {
  group('LoadingState Tests', () {
    test('initial state should have default values', () {
      final state = LoadingState<String>.initial();

      expect(state.isLoading, false);
      expect(state.isLoadedSuccess, false);
      expect(state.loadError, null);
    });

    test('loading state should set isLoading to true', () {
      final state = LoadingState<String>.loading();

      expect(state.isLoading, true);
      expect(state.isLoadedSuccess, false);
      expect(state.loadError, null);
    });

    test('success state should set isLoadedSuccess to true', () {
      final state = LoadingState<String>.success();

      expect(state.isLoading, false);
      expect(state.isLoadedSuccess, true);
      expect(state.loadError, null);
    });

    test('error state should set loadError', () {
      final error = AppError(message: 'Test error');
      final state = LoadingState<String>.error(error);

      expect(state.isLoading, false);
      expect(state.isLoadedSuccess, false);
      expect(state.loadError, error);
    });

    test('copyWith should update only specified fields', () {
      final initialState = LoadingState<String>.initial();
      final updatedState = initialState.copyWith(
        isLoading: true,
        isLoadedSuccess: true,
      );

      expect(updatedState.isLoading, true);
      expect(updatedState.isLoadedSuccess, true);
      expect(updatedState.loadError, null);
    });

    test('equality check works correctly', () {
      final state1 = LoadingState<String>(
        isLoading: true,
        isLoadedSuccess: false,
      );

      final state2 = LoadingState<String>(
        isLoading: true,
        isLoadedSuccess: false,
      );

      final state3 = LoadingState<String>(
        isLoading: false,
        isLoadedSuccess: true,
      );

      expect(state1, state2);
      expect(state1 == state3, false);
    });
  });

  group('LoaderState Tests', () {
    test('initial state should have default values', () {
      final state = LoaderState.initial();

      expect(state.currentPage, 1);
      expect(state.pageSize, 10);
      expect(state.isLoadingMore, false);
      expect(state.isLoadMoreSuccess, false);
      expect(state.errorLoadMore, null);
      expect(state.hasNext, true);
    });

    test('copyWith should update only specified fields', () {
      final initialState = LoaderState.initial();
      final updatedState = initialState.copyWith(
        currentPage: 2,
        isLoadingMore: true,
        hasNext: false,
      );

      expect(updatedState.currentPage, 2);
      expect(updatedState.pageSize, 10);
      expect(updatedState.isLoadingMore, true);
      expect(updatedState.isLoadMoreSuccess, false);
      expect(updatedState.errorLoadMore, null);
      expect(updatedState.hasNext, false);
    });

    test('equality check works correctly', () {
      final state1 = LoaderState(
        currentPage: 2,
        pageSize: 15,
        isLoadingMore: true,
      );

      final state2 = LoaderState(
        currentPage: 2,
        pageSize: 15,
        isLoadingMore: true,
      );

      final state3 = LoaderState(
        currentPage: 3,
        pageSize: 15,
        isLoadingMore: false,
      );

      expect(state1, state2);
      expect(state1 == state3, false);
    });
  });
}
