
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/blocs/movies_blocs/movies_list_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/functionality.dart';
import 'package:poppycorn/models/submodels/channel_movie.dart';



class AllMovies extends StatefulWidget {
  const AllMovies({super.key});

  @override
  State<AllMovies> createState() => _AllMoviesState();
}

class _AllMoviesState extends State<AllMovies> {
  String search_text = "";

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
                  color: jBackgroundColor,
                  isTitle: true,
                  title: "All Movies",
                  onSearch: (value) {
                    setState(() {
                      search_text = value.toLowerCase();
                    });
                  },
                  searchInput: true,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: BlocProvider(
                      create: (context) =>
                          MoviesListBloc('all')..add(getMovies()),
                      child: BlocBuilder<MoviesListBloc, MoviesListState>(
                        builder: (context, state) {
                          if (state is LoadedMovies) {
                            final channels = state.MoviesList;

                            List<ChannelMovie> searchList = channels
                                .where((element) => element.name!
                                    .toLowerCase()
                                    .contains(search_text))
                                .toList();

                            return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: .7,
                                ),
                                itemCount: searchList.isEmpty
                                    ? channels.length
                                    : searchList.length,
                                itemBuilder: (context, index) {
                                  final model = (search_text.isEmpty ||
                                          searchList.isEmpty)
                                      ? channels
                                      : searchList;

                                  return Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                  child: MyCachedImage(
                                                ImageUrl:
                                                    model[index].streamIcon!,
                                                ImageSize: double.infinity,
                                                ImageHeight: double.infinity,
                                              )),
                                              Positioned.fill(
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
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
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              //context.push("/$screenMovieDetails/${_filteredChannels[index]['stream_id'].toString()}")
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/$screenMovieDetails',
                                                                  arguments: model[
                                                                          index]
                                                                      .streamId!
                                                                      .toString());
                                                            },
                                                            style: ButtonStyle(
                                                              overlayColor:
                                                                  mFocusColor,
                                                              elevation:
                                                                  MaterialStateProperty
                                                                      .all<double>(
                                                                          0),
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .transparent),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 5,
                                                                left: 5,
                                                                right: 5),
                                                        child: Text(
                                                          model[index].name!,
                                                          style:
                                                              movieTitleStyle,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                  child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 3),
                                                    decoration:
                                                        jRatingDecoration,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 12,
                                                        ),
                                                        Text(
                                                            Functionality
                                                                .ratingCheck(model[
                                                                        index]
                                                                    .rating!
                                                                    .toString()),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .amber))
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ))
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  );
                                });
                          } else if (state is ErrorsState) {
                            return Center(
                              child: Text(state.message),
                            );
                          } else {
                            return Center(
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
                                  "Loading All Movies May Take a little bit longer",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: jTextColorLight),
                                )
                              ],
                            ));
                          }
                        },
                      ),
                    ),
                  ),
                )
              ],
            ));
      }),
    );
  }
}
