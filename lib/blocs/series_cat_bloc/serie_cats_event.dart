part of 'serie_cats_bloc.dart';

sealed class SerieCatsEvent extends Equatable {
  const SerieCatsEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class getCategories extends SerieCatsEvent {}
