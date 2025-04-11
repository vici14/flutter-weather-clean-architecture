import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_bloc_state.dart';
import 'base_event.dart';

abstract class BaseBloc<E extends BaseEvent, S extends BaseBlocState>
    extends Bloc<E, S> {
  BaseBloc({required S state}) : super(state);
}
