import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/movieCasts.dart';

part 'serie_casts_event.dart';
part 'serie_casts_state.dart';

class SerieCastsBloc extends Bloc<SerieCastsEvent, SerieCastsState> {
  final String serieId;
  SerieCastsBloc(this.serieId) : super(SerieCastsLoading()) {
    on<SerieCastsEvent>((event, emit) async{
      if (event is getSerieCasts) {
        emit(SerieCastsLoading());
        try {
          final result = await iptvApi().getMovieCasts(serieId,'tv');
          emit(SerieCastsLoaded(serieCasts: result));
        }catch (e){
          emit(const SerieCastsErrorState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
