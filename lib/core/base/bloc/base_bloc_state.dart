import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
   final int timeStamp;
 
  const BaseBlocState(
      { this.timeStamp = 1})
      : super();

  @override
  List<Object> get props => [ timeStamp];
}
