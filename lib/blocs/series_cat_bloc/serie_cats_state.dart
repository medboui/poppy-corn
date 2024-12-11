part of 'serie_cats_bloc.dart';

sealed class SerieCatsState extends Equatable {
  const SerieCatsState();
  @override
  List<Object> get props => [];
}

class LoadingCategories extends SerieCatsState {}

class LoadedCategories extends SerieCatsState {

  final List<CategoryModel> CategoriesList;

  const LoadedCategories({required this.CategoriesList});


  @override
  List<Object> get props => [CategoriesList];

}

class ErrorsState extends SerieCatsState {
  final String message;

  const ErrorsState({required this.message});


  @override
  List<Object> get props => [message];
}
