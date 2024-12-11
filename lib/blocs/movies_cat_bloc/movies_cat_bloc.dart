import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';

part 'movies_cat_event.dart';
part 'movies_cat_state.dart';

class MoviesCatBloc extends Bloc<MoviesCatEvent, MoviesCatState> {
  MoviesCatBloc() : super(LoadingCategories()) {
    on<MoviesCatEvent>((event, emit) async {
      if (event is getCategories) {
        emit(LoadingCategories());

        try {
          final result = await iptvApi().getCategories("get_vod_categories");
          emit(LoadedCategories(CategoriesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
