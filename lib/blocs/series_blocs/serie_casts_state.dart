part of 'serie_casts_bloc.dart';

sealed class SerieCastsState extends Equatable {
  const SerieCastsState();
  @override
  List<Object> get props => [];
}

class SerieCastsLoading extends SerieCastsState {}

class SerieCastsLoaded extends SerieCastsState {

  final List<MovieCasts> serieCasts;

  const SerieCastsLoaded({required this.serieCasts});

  @override
  List<Object> get props => [serieCasts];
}

class SerieCastsErrorState extends SerieCastsState {

  final String message;

  const SerieCastsErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
