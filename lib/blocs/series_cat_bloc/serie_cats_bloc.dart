import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';

part 'serie_cats_event.dart';
part 'serie_cats_state.dart';

class SerieCatsBloc extends Bloc<SerieCatsEvent, SerieCatsState> {
  SerieCatsBloc() : super(LoadingCategories()) {
    on<SerieCatsEvent>((event, emit) async {
      if (event is getCategories) {
        emit(LoadingCategories());

        try {
          final result = await iptvApi().getCategories("get_series_categories");
          emit(LoadedCategories(CategoriesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
