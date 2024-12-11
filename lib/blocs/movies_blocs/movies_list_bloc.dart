import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/channel_movie.dart';

part 'movies_list_event.dart';
part '../movies_blocs/movies_list_state.dart';

class MoviesListBloc extends Bloc<MoviesListEvent, MoviesListState> {

  final String categoryId;
  MoviesListBloc(this.categoryId) : super(LoadingMovies()) {
    on<MoviesListEvent>((event, emit) async {
      if (event is getMovies) {
        emit(LoadingMovies());

        try {
          final result = await iptvApi().getMovieChannels(categoryId);
          emit(LoadedMovies(MoviesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }else if(event is getThumbsMovies){
        emit(LoadingMovies());

        try {
          final result = await iptvApi().getThumbsMovies(categoryId);
          emit(LoadedMovies(MoviesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
