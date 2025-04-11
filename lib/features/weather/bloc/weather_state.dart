import '../../../core/base/bloc/base_bloc_state.dart';


class WeatherState extends BaseBlocState {
 
  const WeatherState({
    super.timeStamp = 1,
    super.baseError = '',
   });

  WeatherState copyWith({
    int? timeStamp,
    String? baseError,
   }) {
    return WeatherState(
      timeStamp: timeStamp ?? this.timeStamp,
      baseError: baseError ?? this.baseError,
     
    );
  }

  @override
  List<Object> get props =>
      [timeStamp, baseError];
}
