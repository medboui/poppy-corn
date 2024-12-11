import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/channel_serie.dart';

part 'series_list_event.dart';
part 'series_list_state.dart';

class SeriesListBloc extends Bloc<SeriesListEvent, SeriesListState> {

  final String categoryId;
  SeriesListBloc(this.categoryId) : super(LoadingSeries()) {
    on<SeriesListEvent>((event, emit) async {
      if (event is getSeries) {
        emit(LoadingSeries());

        try {
          final result = await iptvApi().getSerieChannels(categoryId);
          emit(LoadedSeries(SeriesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }else if(event is getThumbSeries){
        emit(LoadingSeries());

        try {
          final result = await iptvApi().getThumbsSeries(categoryId);
          emit(LoadedSeries(SeriesList: result));
        }catch (e){
          emit(const ErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
