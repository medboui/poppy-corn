part of 'movies_list_bloc.dart';

abstract class MoviesListState extends Equatable {
  const MoviesListState();

  @override
  List<Object> get props => [];
}

class LoadingMovies extends MoviesListState {}

class LoadedMovies extends MoviesListState {

  final List<ChannelMovie> MoviesList;

  const LoadedMovies({required this.MoviesList});


  @override
  List<Object> get props => [MoviesList];

}

class ErrorsState extends MoviesListState {
  final String message;

  const ErrorsState({required this.message});


  @override
  List<Object> get props => [message];
}


