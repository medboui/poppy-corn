part of 'tv_channels_bloc.dart';

abstract class TvChannelsState extends Equatable {
  const TvChannelsState();

  @override
  List<Object> get props => [];
}

class LoadingTvChannels extends TvChannelsState {}

class LoadedChannels extends TvChannelsState {

  final List<ChannelLive> ChannelsList;

  const LoadedChannels({required this.ChannelsList});


  @override
  List<Object> get props => [ChannelsList];

}

class ChannelsErrorsState extends TvChannelsState {
  final String message;

  const ChannelsErrorsState({required this.message});


  @override
  List<Object> get props => [message];
}