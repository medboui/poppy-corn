import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poppycorn/apis/iptvApi.dart';
import 'package:poppycorn/models/submodels/ChannelLive.dart';

part 'tv_channels_event.dart';
part 'tv_channels_state.dart';

class TvChannelsBloc extends Bloc<TvChannelsEvent, TvChannelsState> {
  final String catyId;
  TvChannelsBloc(this.catyId) : super(LoadingTvChannels()) {
    on<TvChannelsEvent>((event, emit) async {
      if (event is getChannels) {
        emit(LoadingTvChannels());

        try {
          final result = await iptvApi().getLiveChannels(this.catyId);
          emit(LoadedChannels(ChannelsList: result));

          print(this.catyId);
        }catch (e){
          emit(const ChannelsErrorsState(message: 'Something Went Wrong Please Try Again'));
        }
      }
    });
  }
}
