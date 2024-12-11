/*part of 'tv_categories_bloc.dart';

sealed class TvCategoriesEvent extends Equatable {
  const TvCategoriesEvent();
  @override
  List<Object> get props => [];
}

class getCategories extends TvCategoriesEvent {}
class selectCategory extends TvCategoriesEvent {}*/

part of 'tv_categories_bloc.dart';

sealed class TvCategoriesEvent extends Equatable {
  const TvCategoriesEvent();

  @override
  List<Object> get props => [];
}

class getCategories extends TvCategoriesEvent {}

class selectCategory extends TvCategoriesEvent {
  final String selectedCategory;

  const selectCategory({required this.selectedCategory});

  @override
  List<Object> get props => [selectedCategory];
}

class getChannelsList extends TvCategoriesEvent {}
