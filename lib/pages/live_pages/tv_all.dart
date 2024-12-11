// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/pages/player/mediakit_fullscreen_player.dart';

import '../../helpers/helpers.dart';

class AllChannels extends StatefulWidget {
  const AllChannels({super.key});

  @override
  State<AllChannels> createState() => _AllChannelsState();
}

class _AllChannelsState extends State<AllChannels> {
  final dio = Dio();
  //---------- LISTS
  List<dynamic> _channels = [];
  List<dynamic> _filteredChannels = [];

  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var channelsFavorites = Hive.box('favorite_channels_box');
  var defaultHomeVideo = Hive.box('default_home_video');
  bool isFavorite = false;
  int? favoriteKey;

  //---------- SELECTED ITEMS
  int selectedItem = -1;
  int selectedChannel = -1;
  bool isLoadingChannels = false;
  bool searchState = false;
  String search_text = "";

  var jupiterbox = Hive.box('jupiterbox');
  int defaultPlayer = 0;

  Future<void> _getChannels(String catId) async {
    if (mounted) {
      setState(() {
        isLoadingChannels = true;
      });
    }

    final data = await playlistsBox.get(defaultPlaylist.get('default'));

    final url =
        "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_live_streams&category_id=$catId";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final parsedJson = response.data;

        if (mounted) {
          setState(() {
            _channels = parsedJson;
            _filteredChannels = parsedJson;
            isLoadingChannels = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingChannels = false;
          });
        }
        throw Exception('Failed to load data from the server');
      }
    } catch (error) {
      throw (error);
    }
  }

  void _channel_search(String value) {
    if (value.isEmpty) {
      setState(() {
        _filteredChannels = _channels;
      });
    } else {
      setState(() {
        _filteredChannels = _channels
            .where((data) =>
                data['name'].toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    setState(() {
      defaultPlayer = jupiterbox.get('defaultPlayer');
    });

    _getChannels('all');

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternetBloc(),
      child:
          BlocBuilder<InternetBloc, InternetState>(builder: (context, state) {
        if (state is NotConnectedState) {
          return CheckInternet(message: state.message);
        }
        return Scaffold(
          backgroundColor: jBackgroundColor,
          body: Column(
            children: [
              HeaderEpisodes(
                searchButton: true,
                onSearch: _channel_search,
                searchInput: true,
                color: jBackgroundColor,
              ),
              Expanded(
                flex: 1,
                child: isLoadingChannels == false
                    ? Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filteredChannels.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 5.0),
                                child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      selectedChannel =
                                          _filteredChannels[index]['stream_id'];
                                    });

                                    final playList = await playlistsBox
                                        .get(defaultPlaylist.get('default'));

                                    String streamUrl =
                                        "${playList['playlistLink']}/${playList['username']}/${playList['password']}/${_filteredChannels[index]['stream_id'].toString()}";
                                    if (context.mounted) {
                                      /*Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FullScreenPlayer(
                                                  key: UniqueKey(),
                                                  streamUrl: streamUrl,
                                                  streamId: _filteredChannels[index]
                                                  ['streamId'],
                                                  title: _filteredChannels[index]
                                                      ['name'],
                                                  programme:
                                                      "Programme not identified",
                                                  onPressed: () {})),
                                        );*/

                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {


                                          return MediaKitFullScreen(
                                            streamUrl: streamUrl,
                                            streamId: _filteredChannels[index]
                                                    ['stream_id']
                                                .toString(),
                                            title: _filteredChannels[index]
                                                ['name'],
                                            programme:
                                                "Programme not identified",
                                            onPressed: () {},
                                          );

                                        //
                                      }));
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  child: Ink(
                                    decoration: selectedChannel ==
                                            _filteredChannels[index]
                                                ['stream_id']
                                        ? jActiveInkDecoration
                                        : jInkDecoration,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          MyCachedImage(
                                            ImageUrl: _filteredChannels[index]
                                                ['stream_icon'],
                                            ImageSize: 100,
                                            ImageHeight: 60,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Text(
                                            _filteredChannels[index]['name'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: selectedChannel ==
                                                      _filteredChannels[index]
                                                          ['stream_id']
                                                  ? jTextColorLight
                                                  : jTextColorLight,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: jTextColorLight,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Loading All Channels May Take a little bit longer",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: jTextColorLight),
                            )
                          ],
                        ),
                      ),
              )
            ],
          ),
        );
      }),
    );
  }
}
