part of 'tv_channels_bloc.dart';

sealed class TvChannelsEvent extends Equatable {
  const TvChannelsEvent();

  @override
  List<Object> get props => [];
}
class getChannels extends TvChannelsEvent {}