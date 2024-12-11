part of 'series_list_bloc.dart';

sealed class SeriesListEvent extends Equatable {
  const SeriesListEvent();

  @override
  List<Object> get props => [];
}


class getSeries extends SeriesListEvent {}
class getThumbSeries extends SeriesListEvent {}