// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/player/mediakit_live_player.dart';
import 'package:poppycorn/pages/player/tizen_live_player.dart';

class tvCategories extends StatefulWidget {
  const tvCategories({super.key});

  @override
  State<tvCategories> createState() => _tvCategoriesState();
}

class _tvCategoriesState extends State<tvCategories> {
  final dio = Dio();

  //---------- LIST VIEW SCROLL
  final double scrollAmount =
      100.0; // Adjust this value to control scroll amount
  bool searchState = false;

  //---------- LISTS
  List<dynamic> _categories = [];
  List<dynamic> _filteredCategories = [];
  List<dynamic> _channels = [];
  List<dynamic> _epgInfos = [];

  var jupiterbox = Hive.box('jupiterbox');
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var channelsFavorites = Hive.box('favorite_channels_box');
  var defaultHomeVideo = Hive.box('default_home_video');

  bool isFavorite = false;
  int? favoriteKey;
  int defaultPlayer = 0;

  //---------- SELECTED ITEMS
  int selectedItemIndex = 0;
  int selectedItem = -1;
  int selectedChannel = -1;
  bool isLoadingCategories = false;
  bool isLoadingChannels = false;
  bool isExpanded = true;
  bool isMaintainedState = false;
  bool showCategories = true;
  bool showChannels = false;
  String programme = '';

  //---------- SELECTED CHANNEL
  String ChannelName = '';
  String ChannelLogo = '';
  String ChannelId = '';

  final FocusNode _fillScreen = FocusNode();
  final FocusNode _backToCategories = FocusNode();

  late var data;

  //----------- Player
  var checkPlayer = null;

  Future<void> _getCategories() async {
    if (mounted) {
      setState(() {
        isLoadingCategories = true;
      });
    }

    final data = await playlistsBox.get(defaultPlaylist.get('default'));

    final url =
        "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_live_categories";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = response.data;

      if (mounted) {
        setState(() {
          _categories = parsedJson;
          _filteredCategories = parsedJson;
          isLoadingCategories = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
      throw Exception('Failed to load data from the server');
    }
  }

  Future<void> _getChannels(String catId) async {
    if (mounted) {
      setState(() {
        isLoadingChannels = true;
      });
    }

    final data = await playlistsBox.get(defaultPlaylist.get('default'));

    final url =
        "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_live_streams&category_id=$catId";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = response.data;

      if (mounted) {
        setState(() {
          _channels = parsedJson;
          isLoadingChannels = false;
          _backToCategories.requestFocus();
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
  }

  void toggleExpanded() {

    print(isExpanded);
    setState(() {
      isExpanded = !isExpanded; // Toggle the value
      showChannels = isExpanded && !showCategories ? !showChannels : false;
      showCategories = false; // Toggle the value
    });
    print(isExpanded);
  }

  String _getStreamUrl(String streamId) {
    return "${data['playlistLink']}/${data['username']}/${data['password']}/$streamId";
  }

  void _getVideoUrl(String streamId, String title, String programme) async {
    String videoUrl =
        "${data['playlistLink']}/${data['username']}/${data['password']}/$streamId";

    setState(() {
       // checkPlayer = MediaKitLivePlayer(key: UniqueKey(),
      checkPlayer = TizenLiveScreen(key: UniqueKey(),
          streamUrl: videoUrl,
          title: title,
          programme: programme,
          onPressed: () {
            toggleExpanded();
          },
          fillScreen: _fillScreen,);



    });
  }

  Future<void> _getEPGbyStreamId(String streamId) async {
    try {
      final url =
          "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_short_epg&stream_id=$streamId";

      final response = await dio.get(url);

      final favoritesList = channelsFavorites.keys.map((key) {
        final item = channelsFavorites.get(key);

        return {"key": key, "channelId": item['channelId']};
      }).toList();

      //channelsFavorites.clear();
      for (int i = 0; i < favoritesList.length; i++) {
        if (favoritesList[i]['channelId'] == streamId) {
          if (mounted) {
            setState(() {
              isFavorite = true;

              favoriteKey = favoritesList[i]['key'];
            });
          }

          break;
        } else {
          if (mounted) {
            setState(() {
              isFavorite = false;

              favoriteKey = favoritesList[i]['key'];
            });
          }
        }
      }

      if (response.statusCode == 200) {
        final parsedJson = response.data;

        if (mounted) {
          setState(() {
            _epgInfos = parsedJson['epg_listings'];
            programme = _DecodeEpg(_epgInfos[0]['title']).split('-')[0];
          });
        }
      }
    } catch (e) {
      //debugPrint("Error EPG Series $streamId: $e");
    }
  }

  //---------- Favorites Methods
  Future<void> savePlaylist(String defaultPlaylist, String name,
      String channelId, String image) async {
    _createItem({
      'defaultPlaylist': defaultPlaylist,
      'channelName': name,
      'channelImage': image,
      'channelId': channelId,
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xff292d32).withOpacity(0.8),
            child: SizedBox(
              height: 80,
              child: OverflowBox(
                minHeight: 80,
                maxHeight: 100,
                child: CircularProgressIndicator(
                  color: jTextColorLight,
                ),
              ),
            ),
          );
        });

    var key = await channelsFavorites.add(newItem);

    if (mounted) {
      setState(() {
        favoriteKey = key;
      });
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  //------------ Filter Categories
  void _category_search(String value) {
    if (value.isEmpty) {
      setState(() {
        _filteredCategories = _categories;
      });
    } else {
      setState(() {
        _filteredCategories = _categories
            .where((data) => data['category_name']
                .toLowerCase()
                .contains(value.toLowerCase()))
            .toList();
      });
    }
  }

  //---- Decoder
  String _DecodeEpg(String value) {
    String decoded = utf8.decode(base64Decode(value));
    return decoded;
  }

  @override
  void initState() {
    data = playlistsBox.get(defaultPlaylist.get('default'));

    setState(() {
      defaultPlayer = jupiterbox.get('defaultPlayer');
    });
    _getCategories();

    super.initState();
    //channelsFavorites.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isExpanded) {
          toggleExpanded();

          return false;
        }
        return true; // Always return false to prevent accidental popping
      },
      child: BlocProvider(
        create: (context) => InternetBloc(),
        child: BlocBuilder<InternetBloc, InternetState>(
          builder: (context, state) {
            if (state is NotConnectedState) {
              return CheckInternet(message: state.message);
            }
            return Scaffold(
              backgroundColor: jBackgroundColor,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Visibility(
                            child: HeaderEpisodes(
                          isLive: true,
                          searchButton: true,
                          searchCallback: () {
                            setState(() {
                              searchState = !searchState;
                            });
                          },
                          color: jBackgroundColor,
                        )),
                        Expanded(child: Container())
                      ],
                    ),
                  ),
                  Positioned.fill(
                      child: Opacity(
                    opacity: 1,//showCategories ? 1 : 0,
                    child: Container(
                      margin: EdgeInsets.only(top: 50),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: isLoadingCategories == false
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5.0, left: 5.0),
                                    child: Column(
                                      children: [
                                        searchState == true
                                            ? Center(
                                                child: SizedBox(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          jElementsBackgroundColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 5.0),
                                                    height: 50,
                                                    child: TextField(
                                                      style: TextStyle(
                                                        color: Colors.grey
                                                            .shade400, // Change the text color here
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                              hintText:
                                                                  'Search for ...',
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  fontSize:
                                                                      13.0),
                                                              prefixIcon: Icon(
                                                                HeroiconsOutline
                                                                    .magnifyingGlass,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                              ),
                                                              fillColor:
                                                                  jElementsBackgroundColor
                                                                      .withOpacity(
                                                                          0.3),
                                                              filled: true,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none)),
                                                      onChanged: (value) {
                                                        _category_search(value);
                                                      },
                                                      onSubmitted: (value) {
                                                        setState(() {
                                                          searchState =
                                                              !searchState;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: jIconsColorSpecial,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          margin: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  '/$screenAllChannels');
                                            },
                                            style: ButtonStyle(
                                                overlayColor: mFocusColor,
                                                elevation: MaterialStateProperty
                                                    .all<double>(0),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        jIconsColorSpecial),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                )),
                                            child: Padding(
                                              padding: const EdgeInsets.all(13),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    HeroiconsSolid.tv,
                                                    color: jTextColorWhite,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                    "ALL CHANNELS",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: jTextColorWhite,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  )),
                                                  Icon(
                                                    HeroiconsOutline
                                                        .chevronRight,
                                                    color: jTextColorWhite,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount:
                                                _filteredCategories.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (selectedItem !=
                                                        int.parse(_filteredCategories[
                                                        index][
                                                        'category_id'])) {
                                                      setState(() {
                                                        selectedItem = int.parse(
                                                            _filteredCategories[
                                                                    index][
                                                                'category_id']);
                                                        selectedItemIndex =
                                                            index + 1;
                                                        showChannels = true;
                                                        showCategories = false;
                                                      });


                                                    _getChannels(
                                                        _filteredCategories[
                                                                index]
                                                            ['category_id']);
                                                    }else {
                                                      setState(() {
                                                        showChannels = true;
                                                        showCategories = false;
                                                      });
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                      overlayColor: mFocusColor,
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all<double>(0),
                                                      backgroundColor: selectedItem ==
                                                              int.parse(_filteredCategories[index][
                                                                  'category_id'])
                                                          ? MaterialStateProperty.all<Color>(
                                                              jActiveElementsColor)
                                                          : MaterialStateProperty.all<Color>(
                                                              jTextColorLight.withOpacity(
                                                                  0.1)),
                                                      shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      )),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            13),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          HeroiconsSolid.tv,
                                                          color: selectedItem ==
                                                                  int.parse(_filteredCategories[
                                                                          index]
                                                                      [
                                                                      'category_id'])
                                                              ? jTextColorLight
                                                              : jTextColorLight,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                            child: Text(
                                                          _filteredCategories[
                                                                  index]
                                                              ['category_name'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            color: selectedItem ==
                                                                    int.parse(_filteredCategories[
                                                                            index]
                                                                        [
                                                                        'category_id'])
                                                                ? jTextColorLight
                                                                : jTextColorLight,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        )),
                                                        Icon(
                                                          HeroiconsOutline
                                                              .chevronRight,
                                                          color: selectedItem ==
                                                                  int.parse(_filteredCategories[
                                                                          index]
                                                                      [
                                                                      'category_id'])
                                                              ? jTextColorLight
                                                              : jTextColorLight,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                    color: jTextColorLight,
                                  )),
                          ),
                          selectedItem >= 0 ? Expanded(
                            flex:  1,
                            child: isLoadingChannels == false
                                ? Padding(
                              padding:
                              const EdgeInsets.only(right: 5.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      physics:
                                      const BouncingScrollPhysics(),
                                      itemCount: _channels.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: ElevatedButton(
                                            onPressed: () {

                                                setState(() {
                                                  selectedChannel =
                                                  _channels[index]
                                                  ['stream_id'];
                                                  ChannelName =
                                                  _channels[index]
                                                  ['name'];
                                                  ChannelLogo =
                                                  _channels[index][
                                                  'stream_icon'];
                                                });

                                                _getVideoUrl(
                                                    _channels[index][
                                                    'stream_id']
                                                        .toString(),
                                                    ChannelName,
                                                    programme.isNotEmpty
                                                        ? programme
                                                        : 'Programme not identified');
                                                _getEPGbyStreamId(
                                                    _channels[index][
                                                    'stream_id']
                                                        .toString());

                                                _fillScreen
                                                    .requestFocus();
                                            },
                                            style: ButtonStyle(
                                                overlayColor:
                                                mFocusColor,
                                                elevation:
                                                MaterialStateProperty
                                                    .all<double>(0),
                                                backgroundColor: selectedChannel ==
                                                    _channels[index][
                                                    'stream_id']
                                                    ? MaterialStateProperty.all<Color>(
                                                    jActiveElementsColor)
                                                    : MaterialStateProperty.all<
                                                    Color>(
                                                    jTextColorLight
                                                        .withOpacity(
                                                        0.1)),
                                                shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10),
                                                  ),
                                                )),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(
                                                  5),
                                              child: Row(
                                                children: [
                                                  MyCachedImage(
                                                    ImageUrl: _channels[
                                                    index]
                                                    ['stream_icon'],
                                                    ImageSize: 40,
                                                    ImageHeight: 40,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                        _channels[index]
                                                        ['name'],
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: selectedChannel ==
                                                              _channels[
                                                              index]
                                                              [
                                                              'stream_id']
                                                              ? jTextColorLight
                                                              : jTextColorLight,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600,
                                                          fontSize: 12,
                                                        ),
                                                      )),
                                                  selectedChannel ==
                                                      _channels[
                                                      index]
                                                      [
                                                      'stream_id']
                                                      ? Icon(
                                                    Icons
                                                        .aspect_ratio,
                                                    color:
                                                    jIconsColorSpecial,
                                                  )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : Center(
                              child: CircularProgressIndicator(
                                color: jTextColorLight,
                              ),
                            ),
                          ) : SizedBox(),
                          Expanded(flex: selectedChannel >= 0 ? 1 : 0,child: Container()),

                        ],
                      ),
                    ),
                  )),
                  IgnorePointer(
                    ignoring: selectedChannel >= 0 ? false : true,
                    child: Container(
                        child: Opacity(
                      opacity: selectedChannel >= 0 ? 1 : 0,
                      child: Row(
                        children: [
                          Visibility(
                              child: Expanded(
                                  flex: isExpanded ? 2 : 0,
                                  child: Container())),
                          Visibility(
                            visible: true,
                            maintainSize: false,
                            child: Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      margin: isExpanded
                                          ? EdgeInsets.only(top: 50)
                                          : EdgeInsets.only(top: 0),
                                      color: Colors.black,
                                      width: double.infinity,
                                      child: Center(
                                        child: checkPlayer,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                      visible: isExpanded ? true : false,
                                      child: Expanded(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(

                                                      vertical: 0),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 60,
                                                      height: 50,
                                                      child: MyCachedImage(
                                                          ImageUrl: ChannelLogo,
                                                          ImageSize: 30),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                      ChannelName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14),
                                                    )),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if (isFavorite) {
                                                          channelsFavorites
                                                              .delete(
                                                                  favoriteKey);
                                                          setState(() {
                                                            isFavorite = false;
                                                          });
                                                        } else {
                                                          savePlaylist(
                                                              defaultPlaylist
                                                                  .get(
                                                                      'default')
                                                                  .toString(),
                                                              ChannelName ?? '',
                                                              selectedChannel
                                                                  .toString(),
                                                              ChannelLogo ??
                                                                  '');
                                                          setState(() {
                                                            isFavorite = true;
                                                          });
                                                        }
                                                      },
                                                      style: ButtonStyle(
                                                          overlayColor:
                                                              mFocusColor,
                                                          elevation:
                                                              MaterialStateProperty.all<
                                                                  double>(0),
                                                          padding:
                                                              MaterialStateProperty.all<EdgeInsets>(
                                                                  const EdgeInsets.all(
                                                                      0)),
                                                          backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  jTextColorLight
                                                                      .withOpacity(
                                                                          0.1)),
                                                          shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                          )),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            isFavorite == false
                                                                ? HeroiconsOutline
                                                                    .bookmark
                                                                : HeroiconsSolid
                                                                    .bookmark,
                                                            color:
                                                                jTextColorLight,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: ListView.builder(
                                                    itemCount: _epgInfos.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              _DecodeEpg(
                                                                  _epgInfos[
                                                                          index]
                                                                      [
                                                                      'title']),
                                                              style:
                                                                  epgTitleStyle,
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              "start : ${_epgInfos[index]['start']}",
                                                              style:
                                                                  epgDateStyleS,
                                                            ),
                                                            Text(
                                                              "End : ${_epgInfos[index]['end']}",
                                                              style:
                                                                  epgDateStyle,
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              _DecodeEpg(_epgInfos[
                                                                      index][
                                                                  'description']),
                                                              style:
                                                                  epgDescriptionStyle,
                                                            ),
                                                            Text(
                                                              '--------------------------',
                                                              style: TextStyle(
                                                                  color:
                                                                      jTextColorLight),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    })),
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
