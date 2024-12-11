// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/blocs/movies_blocs/movie_casts_bloc.dart';
import 'package:poppycorn/components/BackDropsAnimated.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/MovieFetch.dart';
import 'package:poppycorn/pages/player/mediakit_player.dart';
import 'package:poppycorn/pages/player/youtube_player.dart';
import 'package:poppycorn/pages/player/tizen_player.dart';

class MovieDetails extends StatefulWidget {
  final String movie_id;
  const MovieDetails({super.key, required this.movie_id});

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final dio = Dio();

  var jupiterbox = Hive.box('jupiterbox');
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var moviesFavorites = Hive.box('favorite_movies_box');
  var defaultHomeVideo = Hive.box('default_home_video');

  bool isLoadingChannels = false;
  bool isFavorite = false;
  int? favoriteKey;
  int defaultPlayer = 0;

  //---------- LISTS
  late String movieLink = '';
  late Future<MovieInfo?> future;

  String _movieLogo = '';
  List<String> _movieBackdrops = [];
  String trailerLink = 'https://www.youtube.com/watch?v=WFfaaLwLobA&t';

  Future<MovieInfo> _getMovieInfos(String movieId) async {
    setState(() {
      isLoadingChannels = true;
    });

    final playList = await playlistsBox.get(defaultPlaylist.get('default'));

    final url =
        "${playList['playlistLink']}/player_api.php?username=${playList['username']}&password=${playList['password']}&action=get_vod_info&vod_id=$movieId";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = await response.data;

      Map<String, dynamic> data = parsedJson;

      MovieInfo mInfo = MovieInfo.fromJson(data['info']);

      MovieData mData = MovieData.fromJson(data['movie_data']);

      setState(() {
        movieLink =
            "${playList['playlistLink']}/movie/${playList['username']}/${playList['password']}/${widget.movie_id}.${mData.containerExtension}";

        isLoadingChannels = false;
      });

      final favoritesList = moviesFavorites.keys.map((key) {
        final item = moviesFavorites.get(key);

        return {"key": key, "movieId": item['movieId']};
      }).toList();

      for (int i = 0; i < favoritesList.length; i++) {
        if (favoritesList[i]['movieId'] == widget.movie_id) {
          isFavorite = true;
          favoriteKey = favoritesList[i]['key'];
          break;
        }
      }

      _getTmdbMovieInfo(data['info']['tmdb_id'].toString());
      return mInfo;
    } else {
      setState(() {
        isLoadingChannels = false;
      });
      throw Exception('Failed to load data from the server');
    }
  }

  Future<void> _getTmdbMovieInfo(String movieId) async {
    final url = "$tmdbBaseLink/movie/$movieId$tmdbEndLinkImages";

    //print(url);
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = response.data;

      if (parsedJson['images']['logos'] is List &&
          parsedJson['images']['logos'].length == 0) {
        _movieLogo = '';
      } else {
        _movieLogo =
            "$tmdbCastImageLink${parsedJson['images']['logos']![0]['file_path'] ?? ''}";
        if (parsedJson['images']['backdrops'] is List &&
            parsedJson['images']['backdrops'].length == 0) {
          _movieBackdrops = [];
        } else {
          //_movieLogo = "$tmdbCastImageLink${parsedJson['images']['logos']![0]['file_path']??''}";

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
              _movieBackdrops = filePaths;
            });
          }
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
      'movieName': name,
      'movieImage': image,
      'movieRating': rating,
      'movieId': movieId,
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

    var key = await moviesFavorites.add(newItem);

    if (mounted) {
      setState(() {
        favoriteKey = key;
      });
    }

    Navigator.of(context).pop();
  }

  Future<void> _makeDefaultVideo(String key) async {
    await defaultHomeVideo.put('video', key);
  }



  String trailer = "";


  @override
  void initState() {
    setState(() {
      defaultPlayer = jupiterbox.get('defaultPlayer');
    });

    future = _getMovieInfos(widget.movie_id);

    super.initState();
    //moviesFavorites.clear();
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
          body: FutureBuilder<MovieInfo?>(
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
                        key: UniqueKey(), listImages: _movieBackdrops),
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
                        begin: Alignment
                            .topCenter, // Adjust the gradient start point
                        end: Alignment
                            .bottomCenter, // Adjust the gradient end point
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
                                    flex: 3,
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
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
                                                            movie!.name ?? '',
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade400,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 25,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
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
                                                          _makeDefaultVideo(
                                                              movieLink ?? '');

                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                             /*
                                                              return MediaScreen(
                                                                  link:
                                                                      movieLink,
                                                                  title: movie!
                                                                          .name ??
                                                                      '');

                                                              */
                                                                        return TizenScreen(
                                                                            link:
                                                                            movieLink,
                                                                            title: movie!
                                                                                .name ??
                                                                                '');

                                                          }
                                                                  //
                                                                  ));
                                                        },
                                                        style: ButtonStyle(
                                                            overlayColor:
                                                                mFocusColor,
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all<double>(
                                                                        0),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        jTextColorWhite),
                                                            padding:
                                                                MaterialStateProperty.all<
                                                                        EdgeInsets>(
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
                                                              code: movie!
                                                                      .youtubeTrailer ??
                                                                  '');
                                                        }
                                                                ));
                                                      },
                                                      style: ButtonStyle(
                                                          overlayColor:
                                                              mFocusColor,
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all<double>(
                                                                      0),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.3)),
                                                          padding: MaterialStateProperty
                                                              .all<EdgeInsets>(
                                                                  const EdgeInsets.all(10)),
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                          )),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Trailer",
                                                            style: TextStyle(
                                                                color:
                                                                    jTextColorLight),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            HeroiconsSolid.film,
                                                            color:
                                                                jTextColorLight,
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
                                                          moviesFavorites
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
                                                              movie!.name ?? '',
                                                              widget.movie_id
                                                                  .toString(),
                                                              movie.coverImage ??
                                                                  '',
                                                              movie.rating
                                                                      .toString() ??
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
                                                              MaterialStateProperty
                                                                  .all<double>(
                                                                      0),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.3)),
                                                          padding: MaterialStateProperty
                                                              .all<EdgeInsets>(
                                                                  const EdgeInsets.all(10)),
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
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
                                                  ]),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        movie!.releaseDate ??
                                                            '',
                                                        style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        " * ",
                                                        style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 150),
                                                        child: Text(
                                                          movie.genre ?? '',
                                                          style: TextStyle(
                                                            color:
                                                                jTextColorLight,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        " * ",
                                                        style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        movie.duration ?? '',
                                                        style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        " * ",
                                                        style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const Icon(
                                                          HeroiconsSolid.star,
                                                          size: 14,
                                                          color: Colors.amber),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        movie.rating
                                                                .toString() ??
                                                            '',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade400),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  right: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                movie.plot ??
                                                                    '',
                                                                style: TextStyle(
                                                                    color:
                                                                        jTextColorLight,
                                                                    wordSpacing:
                                                                        2,
                                                                    height:
                                                                        1.5),
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                  height: 80,
                                                                  child:
                                                                      BlocProvider(
                                                                    create: (context) => MovieCastsBloc(
                                                                        movie!
                                                                            .tmdbId!)
                                                                      ..add(
                                                                          getMovieCasts()),
                                                                    child: BlocBuilder<
                                                                        MovieCastsBloc,
                                                                        MovieCastsState>(
                                                                      builder:
                                                                          (context,
                                                                              state) {
                                                                        if (state
                                                                            is MovieCastsLoaded) {
                                                                          final casts =
                                                                              state.movieCasts;

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
                                                                            is MovieCastsErrorState) {
                                                                          return Center(
                                                                              child: Text(state.message));
                                                                        } else {
                                                                          return Center(
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              color: jTextColorLight,
                                                                            ),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                  )),
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
                        ),
                        //Actors Images
                      ],
                    )
                  ],
                );
              }),
        );
      }),
    );
  }
}
