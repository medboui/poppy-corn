import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/SeriesModel.dart';
import 'package:poppycorn/pages/player/mediakit_player.dart';

class SeriesSeasons extends StatefulWidget {
  const SeriesSeasons({super.key, required this.serieDetails});

  final SerieDets serieDetails;

  @override
  State<SeriesSeasons> createState() => _SeriesSeasonsState();
}

class _SeriesSeasonsState extends State<SeriesSeasons> {
  late SerieDets serieDetails;
  int selectedSeason = 1;
  int selectedEpisode = 0;

  int focusedSeason = 1;
  int focusedEpisode = 0;
  int defaultPlayer = 0;

  var jupiterbox = Hive.box('jupiterbox');
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var defaultHomeVideo = Hive.box('default_home_video');

  Future<void> _makeDefaultVideo(String key) async {
    await defaultHomeVideo.put('video', key);
  }

  @override
  void initState() {
    setState(() {
      defaultPlayer = jupiterbox.get('defaultPlayer');
    });

    serieDetails = widget.serieDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> seasons = [];
    if (serieDetails.episodes != null && serieDetails.episodes!.isNotEmpty) {
      serieDetails.episodes!.forEach((k, v) {
        seasons.add(k);
      });
    }

    return BlocProvider(
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
                Container(
                  color: jBackgroundColor,
                ),
                Column(
                  children: [
                    const HeaderEpisodes(),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: ListView.builder(
                                  itemCount: seasons.length,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (_, i) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      decoration: BoxDecoration(
                                          color: focusedSeason ==
                                                  int.parse(seasons[i])
                                              ? jElementsBackgroundColor
                                              : jActiveElementsColor,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: InkWell(
                                        onFocusChange: (isFocused) {
                                          setState(() {
                                            focusedSeason =
                                                int.parse(seasons[i]);
                                          });
                                        },
                                        onTap: () {
                                          setState(() {
                                            selectedSeason = i + 1;
                                            selectedEpisode = 0;
                                            focusedEpisode = 0;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: focusedSeason ==
                                                    int.parse(seasons[i])
                                                ? Colors.amber
                                                : jElementsBackgroundColor
                                                    .withOpacity(0.3),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  "SEASON : ${seasons[i]}",
                                                  style: TextStyle(
                                                    color: selectedSeason ==
                                                            int.parse(
                                                                seasons[i])
                                                        ? jIconsColorSpecial
                                                        : jTextColorLight,
                                                    fontSize: 14,
                                                  ),
                                                )),
                                                Icon(
                                                  HeroiconsOutline.queueList,
                                                  color: selectedSeason ==
                                                          int.parse(seasons[i])
                                                      ? jIconsColorSpecial
                                                      : jTextColorLight,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: serieDetails
                                          .episodes?["$selectedSeason"]
                                          ?.length ??
                                      0,
                                  itemBuilder: (_, i) {
                                    final model = serieDetails
                                        .episodes!["$selectedSeason"]![i];

                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: focusedEpisode ==
                                                int.parse(model!.episodeNum!)
                                            ? jElementsBackgroundColor
                                            : jActiveElementsColor,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        onFocusChange: (key) {
                                          setState(() {
                                            focusedEpisode =
                                                int.parse(model.episodeNum!);
                                          });
                                        },
                                        onTap: () async {
                                          setState(() {
                                            selectedEpisode =
                                                int.parse(model.episodeNum!) ??
                                                    0;
                                          });

                                          final playList = await playlistsBox
                                              .get(defaultPlaylist
                                                  .get('default'));
                                          String link =
                                              "${playList['playlistLink']}/series/${playList['username']}/${playList['password']}/${model.id}.${model.containerExtension}";

                                          defaultHomeVideo.put('video', link);
                                          if (context.mounted) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                                        return MediaScreen(link: link, title: model!.title ??'');

                                                    }
                                                ));
                                          }
                                        },
                                        child: Ink(
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                ),
                                                child: MyCachedImage(
                                                  ImageUrl:
                                                      model.info!.movieImage ??
                                                          "",
                                                  ImageSize: 200,
                                                  ImageHeight: 100,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    model.title ?? '',
                                                    style: TextStyle(
                                                        color: selectedEpisode ==
                                                                int.parse(model
                                                                    .episodeNum!)
                                                            ? jIconsColorSpecial
                                                            : jTextColorLight,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    model.info?.duration ?? '',
                                                    style: TextStyle(
                                                      color: selectedEpisode ==
                                                              int.parse(model
                                                                  .episodeNum!)
                                                          ? jIconsColorSpecial
                                                          : jTextColorLight,
                                                    ),
                                                  )
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ))
                        ],
                      ),
                    )),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
