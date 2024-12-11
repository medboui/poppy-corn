import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/movieCasts.dart';


part 'movie_casts_event.dart';
part '../movies_blocs/movie_casts_state.dart';


class MovieCastsBloc extends Bloc<MovieCastsEvent, MovieCastsState> {
  final String movieId;
  MovieCastsBloc(this.movieId) : super(MovieCastsLoading()) {
    on<MovieCastsEvent>((event, emit) async {
      if (event is getMovieCasts) {
        emit(MovieCastsLoading());
        try {
          final result = await iptvApi().getMovieCasts(movieId,'movie');
          emit(MovieCastsLoaded(movieCasts: result));
        }catch (e){
          emit(MovieCastsErrorState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
