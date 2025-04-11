import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
  final bool isLoading;
  final int timeStamp;
  final String baseError;

  const BaseBlocState(
      {this.isLoading = true, this.timeStamp = 1, this.baseError = ''})
      : super();

  @override
  List<Object> get props => [isLoading, timeStamp];
}
