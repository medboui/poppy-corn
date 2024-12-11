part of 'movies_cat_bloc.dart';

sealed class MoviesCatEvent extends Equatable {
  const MoviesCatEvent();

  @override
  List<Object> get props => [];
}

class getCategories extends MoviesCatEvent {}