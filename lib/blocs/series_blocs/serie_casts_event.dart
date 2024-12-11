part of 'serie_casts_bloc.dart';

sealed class SerieCastsEvent extends Equatable {
  const SerieCastsEvent();

  @override
  List<Object?> get props => [];
}
class getSerieCasts extends SerieCastsEvent {}