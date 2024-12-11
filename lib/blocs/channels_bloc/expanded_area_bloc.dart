import 'package:bloc/bloc.dart';

part 'expanded_area_event.dart';
part 'expanded_area_state.dart';

class ExpandedAreaBloc extends Bloc<ExpandedAreaEvent, ExpandedAreaState> {
  ExpandedAreaBloc() : super(ExpandedInitial()) {
    on<ToggleExpand>((event, emit) {
      final currentState = state as ExpandedInitial;
      emit(ExpandedInitial(isExpanded: !currentState.isExpanded));
    });
  }
}