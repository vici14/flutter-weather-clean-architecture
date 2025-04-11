import 'package:equatable/equatable.dart';

import '../../error/AppError.dart';

// Generic loading state to track loading status for different operations
class LoadingState<T> extends Equatable {
  final bool isLoading;
  final bool isLoadedSuccess;
  final AppError? loadError;
  final T? _value;

  T? get type => _value;

  const LoadingState({
    this.isLoading = false,
    this.isLoadedSuccess = false,
    this.loadError,
    T? value,
  }) : _value = value;

  // Factory constructor for initial state
  factory LoadingState.initial() {
    return const LoadingState();
  }

  // Factory constructor for loading state
  factory LoadingState.loading() {
    return const LoadingState(
      isLoading: true,
      isLoadedSuccess: false,
      loadError: null,
    );
  }

  // Factory constructor for success state
  factory LoadingState.success() {
    return const LoadingState(
      isLoading: false,
      isLoadedSuccess: true,
      loadError: null,
    );
  }

  // Factory constructor for error state
  factory LoadingState.error(dynamic error) {
    return LoadingState(
      isLoading: false,
      isLoadedSuccess: false,
      loadError: error,
    );
  }

  LoadingState<T> copyWith({
    bool? isLoading,
    bool? isLoadedSuccess,
    dynamic loadError,
    T? value,
  }) {
    return LoadingState<T>(
      isLoading: isLoading ?? this.isLoading,
      isLoadedSuccess: isLoadedSuccess ?? this.isLoadedSuccess,
      loadError: loadError ?? this.loadError,
      value: value ?? _value,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadedSuccess, loadError, _value];
}

class LoaderState extends Equatable {
  final int pageSize;
  int currentPage;
  final bool isLoadingMore;
  final bool isLoadMoreSuccess;
  final AppError? errorLoadMore;
  final bool hasNext;

  LoaderState({
    this.pageSize = 10,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.isLoadMoreSuccess = false,
    this.errorLoadMore,
    this.hasNext = true,
  });

  LoaderState copyWith({
    bool? isLoadingMore,
    AppError? error,
    bool? isLoadMoreSuccess,
    int? currentPage,
    int? pageSize,
    bool? hasNext,
  }) {
    return LoaderState(
      currentPage: currentPage ?? this.currentPage,
      errorLoadMore: error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadMoreSuccess: isLoadMoreSuccess ?? this.isLoadMoreSuccess,
      pageSize: pageSize ?? this.pageSize,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  factory LoaderState.initial() {
    return LoaderState(
        currentPage: 1,
        pageSize: 10,
        isLoadMoreSuccess: false,
        isLoadingMore: false,
        errorLoadMore: null,
        hasNext: true);
  }

  @override
  List<Object?> get props => [
        pageSize,
        currentPage,
        isLoadMoreSuccess,
        isLoadingMore,
        errorLoadMore,
        hasNext,
      ];
}
