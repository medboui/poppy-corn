part of 'movie_casts_bloc.dart';

sealed class MovieCastsState extends Equatable {
  const MovieCastsState();

  @override
  List<Object> get props => [];
}

class MovieCastsLoading extends MovieCastsState {}

class MovieCastsLoaded extends MovieCastsState {

  final List<MovieCasts> movieCasts;

  const MovieCastsLoaded({required this.movieCasts});

  @override
  List<Object> get props => [movieCasts];
}

class MovieCastsErrorState extends MovieCastsState {

  final String message;

  const MovieCastsErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
