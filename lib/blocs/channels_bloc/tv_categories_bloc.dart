/*import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';

part 'tv_categories_event.dart';
part 'tv_categories_state.dart';

class TvCategoriesBloc extends Bloc<TvCategoriesEvent, TvCategoriesState> {

  TvCategoriesBloc() : super(LoadingCategories()) {
    on<TvCategoriesEvent>((event, emit) async {
      if (event is getCategories) {
        emit(LoadingCategories());

        try {
          final result = await iptvApi().getCategories("get_vod_categories");
          emit(LoadedCategories(CategoriesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }else if(event is selectCategory){

      }

    });
  }
}
*/
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';

part 'tv_categories_event.dart';
part 'tv_categories_state.dart';

class TvCategoriesBloc extends Bloc<TvCategoriesEvent, TvCategoriesState> {
  TvCategoriesBloc() : super(LoadingCategories()) {
    on<TvCategoriesEvent>((event, emit) async {
      if (event is getCategories) {
        emit(LoadingCategories());

        try {
          final result = await iptvApi().getCategories("get_vod_categories");
          emit(LoadedCategories(categoriesList: result));
        } catch (e) {
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      } else if (event is selectCategory) {
        if (state is LoadedCategories) {
          final currentState = state as LoadedCategories;
          emit(currentState.copyWith(selectedCategory: event.selectedCategory));
          print('State after selection: ${currentState.selectedCategory}');
        }
      }
    });
  }
}
