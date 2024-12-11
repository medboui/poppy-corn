part of 'movies_list_bloc.dart';

sealed class MoviesListEvent extends Equatable {
  const MoviesListEvent();

  @override
  List<Object> get props => [];
}

class getMovies extends MoviesListEvent {}
class getThumbsMovies extends MoviesListEvent {}