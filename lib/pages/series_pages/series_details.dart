// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/blocs/series_blocs/serie_casts_bloc.dart';
import 'package:poppycorn/components/BackDropsAnimated.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/player/youtube_player.dart';
import 'package:poppycorn/pages/series_pages/series_seasons.dart';

import '../../models/SeriesModel.dart';

class SeriesPage extends StatefulWidget {
  final String series_id;
  const SeriesPage({super.key, required this.series_id});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final dio = Dio();
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var seriesFavorites = Hive.box('favorite_series_box');

  bool isLoadingChannels = false;
  bool isFavorite = false;
  int? favoriteKey;

  //---------- LISTS
  late String seriesLink = '';

  late List seasonsList = [];

  late Future<SerieDets?> future;

  String _movieLogo = '';
  List<String> _seriesBackdrops = [];


  String trailer = "";



  Future<SerieDets> _getSeriesInfos(String seriesId) async {
    if (mounted) {
      setState(() {
        isLoadingChannels = true;
      });
    }

    final playList = await playlistsBox.get(defaultPlaylist.get('default'));

    final url =
        "${playList['playlistLink']}/player_api.php?username=${playList['username']}&password=${playList['password']}&action=get_series_info&series_id=$seriesId";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final json = response.data ?? "";

      final serie = SerieDets.fromJson(json);

      final favoritesList = seriesFavorites.keys.map((key) {
        final item = seriesFavorites.get(key);

        return {"key": key, "seriesId": item['seriesId']};
      }).toList();

      for (int i = 0; i < favoritesList.length; i++) {
        if (favoritesList[i]['seriesId'] == widget.series_id) {
          isFavorite = true;
          favoriteKey = favoritesList[i]['key'];
          break;
        }
      }

      _getTmdbSeriesInfo(serie.info!.tmdb.toString());
      return serie;
    } else {
      if (mounted) {
        setState(() {
          isLoadingChannels = false;
        });
      }
      throw Exception('Failed to load data from the server');
    }
  }

  Future<void> _getTmdbSeriesInfo(String movieId) async {
    final url = "$tmdbBaseLink/tv/$movieId$tmdbEndLinkImages";
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = response.data;

      if (parsedJson['images']['logos'] is List &&
          parsedJson['images']['logos'].length == 0) {
        _movieLogo = '';
      } else {
        _movieLogo =
            "$tmdbCastImageLink${parsedJson['images']['logos']![0]['file_path'] ?? ''}";
      }

      if (parsedJson['images']['backdrops'] is List &&
          parsedJson['images']['backdrops'].length == 0) {
        _seriesBackdrops = [];
      } else {
        // Access the list of backdrops
        List<dynamic> backdrops = parsedJson['images']['backdrops'];

        // List to store all file paths
        List<String> filePaths = [];

        // Loop through backdrops and extract file_path
        /*for (var backdrop in backdrops) {
            String filePath = "$tmdbCastImageLink${backdrop['file_path']}";
            filePaths.add(filePath);
          }*/

        String filePath = "$tmdbCastImageLink${backdrops[0]['file_path']}";
        filePaths.add(filePath);

        if (mounted) {
          setState(() {
            _seriesBackdrops = filePaths;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingChannels = false;
          _movieLogo = '';
        });
      }
    }
  }

  Future<void> savePlaylist(String defaultPlaylist, String name, String movieId,
      String image, String rating) async {
    _createItem({
      'defaultPlaylist': defaultPlaylist,
      'seriesName': name,
      'seriesImage': image,
      'seriesRating': rating,
      'seriesId': movieId,
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

    if (!isFavorite) {
      var key = await seriesFavorites.add(newItem);

      if (mounted) {
        setState(() {
          favoriteKey = key;
        });
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    future = _getSeriesInfos(widget.series_id);
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
      child: BlocBuilder<InternetBloc, InternetState>(
          builder: (context, state) {

            if(state is NotConnectedState){
              return CheckInternet(message: state.message);
            }
          return Scaffold(
            backgroundColor: jBackgroundColor,
            body: FutureBuilder<SerieDets?>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: jTextColorLight,
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: Text("Could not load data"),
                    );
                  }

                  final movie = snapshot.data;

                  return Stack(
                    children: [
                      CardMovieImagesBackground(
                          key: UniqueKey(), listImages: _seriesBackdrops.toList()),
                      Positioned.fill(
                        child: Container(
                          color: jActiveElementsColor.withOpacity(0.3),
                        ),
                      ),
                      Positioned.fill(
                          child: Container(
                              decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black
                          ], // Define your gradient colors
                          begin:
                              Alignment.topCenter, // Adjust the gradient start point
                          end:
                              Alignment.bottomCenter, // Adjust the gradient end point
                        ),
                      ))),
                      Column(
                        children: [
                          const HeaderEpisodes(),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        height: double.infinity,
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    _movieLogo != ''
                                                        ? MyCachedImage(
                                                            ImageUrl: _movieLogo,
                                                            ImageSize: 200,
                                                            ImageHeight: 50,
                                                            fit: "contain")
                                                        : SizedBox(
                                                            width: 250,
                                                            child: Text(
                                                              movie!.info!.name ?? '',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey.shade400,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                fontSize: 25,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                            ),
                                                          ),
                                                    Expanded(child: Container()),
                                                    Row(children: [
                                                      SizedBox(
                                                        width: 60,
                                                        height: 60,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      SeriesSeasons(
                                                                          serieDetails:
                                                                              movie!)),
                                                            );
                                                          },
                                                          style: ButtonStyle(
                                                              overlayColor:
                                                                  mFocusColor,
                                                              elevation:
                                                                  MaterialStateProperty
                                                                      .all<double>(0),
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                              Color>(
                                                                          jTextColorWhite),
                                                              padding:
                                                                  MaterialStateProperty
                                                                      .all<EdgeInsets>(
                                                                          EdgeInsets
                                                                              .zero),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                              )),
                                                          child: const Icon(
                                                            HeroiconsSolid.play,
                                                            color:
                                                                jElementsBackgroundColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {



                                                          Navigator.push(context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                                    return MyYoutubePlayer(
                                                                        code: movie!.info!.youtubeTrailer??'');
                                                                  }
                                                              ));

                                                        },
                                                        style: ButtonStyle(
                                                            overlayColor: mFocusColor,
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all<double>(0),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<Color>(
                                                                    Colors.black
                                                                        .withOpacity(
                                                                            0.3)),
                                                            padding:
                                                                MaterialStateProperty.all<EdgeInsets>(
                                                                    const EdgeInsets.all(
                                                                        10)),
                                                            shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(30),
                                                              ),
                                                            )),
                                                        child: Row(
                                                          children: [
                                                            Text("Trailer",
                                                                style: TextStyle(
                                                                    color:
                                                                        jTextColorLight)),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Icon(
                                                              HeroiconsSolid.film,
                                                              color: jTextColorLight,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (isFavorite) {
                                                            seriesFavorites
                                                                .delete(favoriteKey);
                                                            setState(() {
                                                              isFavorite = false;
                                                            });
                                                          } else {
                                                            savePlaylist(
                                                                defaultPlaylist
                                                                    .get('default')
                                                                    .toString(),
                                                                movie!.info!.name ??
                                                                    '',
                                                                widget.series_id
                                                                    .toString(),
                                                                movie.info!.cover ??
                                                                    '',
                                                                movie.info!.rating
                                                                        .toString() ??
                                                                    '' ??
                                                                    '');
                                                            setState(() {
                                                              isFavorite = true;
                                                            });
                                                          }
                                                        },
                                                        style: ButtonStyle(
                                                            overlayColor: mFocusColor,
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all<double>(0),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<Color>(
                                                                    Colors.black
                                                                        .withOpacity(
                                                                            0.3)),
                                                            padding:
                                                                MaterialStateProperty.all<EdgeInsets>(
                                                                    const EdgeInsets.all(
                                                                        10)),
                                                            shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(30),
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
                                                              color: jTextColorLight,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            movie!.info!
                                                                    .releaseDate ??
                                                                '',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey.shade400)),
                                                        Text(
                                                          " * ",
                                                          style: TextStyle(
                                                            color: jTextColorLight,
                                                          ),
                                                        ),
                                                        Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth: 150),
                                                            child: Text(
                                                                movie.info!.genre ??
                                                                    '',
                                                                maxLines: 1,
                                                                overflow: TextOverflow
                                                                    .ellipsis,
                                                                style: TextStyle(
                                                                    color: Colors.grey
                                                                        .shade400))),
                                                        Text(
                                                          " * ",
                                                          style: TextStyle(
                                                            color: jTextColorLight,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                HeroiconsSolid.star,
                                                                size: 13,
                                                                color: Colors.amber),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                                movie.info!.rating
                                                                        .toString() ??
                                                                    '',
                                                                style: TextStyle(
                                                                    color: Colors.grey
                                                                        .shade400)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: double.infinity,
                                                            child: Text(
                                                              movie.info!.plot ?? '',
                                                              textAlign:
                                                                  TextAlign.justify,
                                                              style: TextStyle(
                                                                color:
                                                                    jTextColorLight,
                                                                wordSpacing: 2,
                                                                height: 1.5,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                    top: 0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                SizedBox(
                                                                  height: 80,
                                                                  child: BlocProvider(
                                                                    create: (context) =>
                                                                        SerieCastsBloc(
                                                                            movie!
                                                                                .info!
                                                                                .tmdb!)
                                                                          ..add(
                                                                              getSerieCasts()),
                                                                    child: BlocBuilder<
                                                                        SerieCastsBloc,
                                                                        SerieCastsState>(
                                                                      builder:
                                                                          (context,
                                                                              state) {
                                                                        if (state
                                                                            is SerieCastsLoaded) {
                                                                          final casts =
                                                                              state
                                                                                  .serieCasts;

                                                                          return ListView.builder(
                                                                              padding: EdgeInsets.zero,
                                                                              physics: const BouncingScrollPhysics(),
                                                                              itemCount: casts.length,
                                                                              scrollDirection: Axis.horizontal,
                                                                              itemBuilder: (context, index) {
                                                                                return Container(
                                                                                    width: 60,
                                                                                    margin: const EdgeInsets.only(right: 10),
                                                                                    child: Column(
                                                                                      children: [
                                                                                        ClipRRect(
                                                                                            borderRadius: const BorderRadius.only(
                                                                                              bottomLeft: Radius.circular(50),
                                                                                              bottomRight: Radius.circular(50),
                                                                                              topLeft: Radius.circular(50),
                                                                                              topRight: Radius.circular(50),
                                                                                            ),
                                                                                            child: MyCachedImage(
                                                                                              ImageUrl: "$tmdbCastImageLink${casts[index].image}",
                                                                                              ImageSize: 60,
                                                                                              ImageHeight: 60,
                                                                                            )),
                                                                                        const SizedBox(
                                                                                          height: 3,
                                                                                        ),
                                                                                        Text(
                                                                                          casts[index].name.toString(),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          maxLines: 1,
                                                                                          style: TextStyle(color: jTextColorLight, fontSize: 10),
                                                                                        )
                                                                                      ],
                                                                                    ));
                                                                              });
                                                                        } else if (state
                                                                            is SerieCastsErrorState) {
                                                                          return Center(
                                                                              child: Text(
                                                                                  state.message));
                                                                        } else {
                                                                          return Center(
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              color:
                                                                                  jTextColorLight,
                                                                            ),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  );
                }),
          );
        }
      ),
    );
  }
}
