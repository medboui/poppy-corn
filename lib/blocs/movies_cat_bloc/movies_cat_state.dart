part of 'movies_cat_bloc.dart';

sealed class MoviesCatState extends Equatable {
  const MoviesCatState();

  @override
  List<Object> get props => [];
}

class LoadingCategories extends MoviesCatState {}

class LoadedCategories extends MoviesCatState {

  final List<CategoryModel> CategoriesList;

  const LoadedCategories({required this.CategoriesList});


  @override
  List<Object> get props => [CategoriesList];

}

class ErrorsState extends MoviesCatState {
  final String message;

  const ErrorsState({required this.message});


  @override
  List<Object> get props => [message];
}
