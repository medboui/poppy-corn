part of 'movie_casts_bloc.dart';

sealed class MovieCastsEvent extends Equatable {
  const MovieCastsEvent();

  @override
  List<Object?> get props => [];
}


class getMovieCasts extends MovieCastsEvent {}