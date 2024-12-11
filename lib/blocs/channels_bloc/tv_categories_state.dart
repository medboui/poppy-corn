/*part of 'tv_categories_bloc.dart';

abstract class TvCategoriesState extends Equatable {
  const TvCategoriesState();

  @override
  List<Object> get props => [];
}

class LoadingCategories extends TvCategoriesState {}

class LoadedCategories extends TvCategoriesState {

  final List<CategoryModel> CategoriesList;

  const LoadedCategories({required this.CategoriesList});


  @override
  List<Object> get props => [CategoriesList];

}

class ErrorsState extends TvCategoriesState {
  final String message;

  const ErrorsState({required this.message});


  @override
  List<Object> get props => [message];
}*/
part of 'tv_categories_bloc.dart';

abstract class TvCategoriesState extends Equatable {
  const TvCategoriesState();

  @override
  List<Object> get props => [];
}

class LoadingCategories extends TvCategoriesState {}

class LoadedCategories extends TvCategoriesState {
  final List<CategoryModel> categoriesList;
  final String? selectedCategory; // Nullable to allow no selection initially.

  const LoadedCategories({
    required this.categoriesList,
    this.selectedCategory,
  });

  LoadedCategories copyWith({
    List<CategoryModel>? categoriesList,
    String? selectedCategory,
  }) {
    return LoadedCategories(
      categoriesList: categoriesList ?? this.categoriesList,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object> get props => [categoriesList, selectedCategory ?? ""]; // Handle nullable.
}

class ErrorsState extends TvCategoriesState {
  final String message;

  const ErrorsState({required this.message});

  @override
  List<Object> get props => [message];
}
