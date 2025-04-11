import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';
part 'state.g.dart';

@freezed
class State with _$State {
  const factory State({
    required int id,
    required String name,
    required int country_id,
    required String country_code,
    required String iso2,
    required String type,
    String? latitude,
    String? longitude,
  }) = _State;

  factory State.fromJson(Map<String, dynamic> json) => _$StateFromJson(json);
}
