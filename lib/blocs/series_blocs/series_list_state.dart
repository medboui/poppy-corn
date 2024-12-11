part of 'series_list_bloc.dart';

sealed class SeriesListState extends Equatable {
  const SeriesListState();

  @override
  List<Object> get props => [];
}

class LoadingSeries extends SeriesListState {}
class LoadedSeries extends SeriesListState {

  final List<ChannelSerie> SeriesList;

  const LoadedSeries({required this.SeriesList});


  @override
  List<Object> get props => [SeriesList];

}

class ErrorsState extends SeriesListState {
  final String message;

  const ErrorsState({required this.message});


  @override
  List<Object> get props => [message];
}


