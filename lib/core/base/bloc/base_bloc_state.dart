import 'package:equatable/equatable.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';

abstract class BaseBlocState extends Equatable {
  final int timeStamp;

  bool get hasInitializeError;

  bool get isInitialLoading;

  const BaseBlocState({this.timeStamp = 1}) : super();

  List<LoadingState> get loadingStates;

  @override
  List<Object> get props => [timeStamp,hasInitializeError,isInitialLoading];
}
