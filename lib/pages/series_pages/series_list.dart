// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/blocs/series_blocs/series_list_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/functionality.dart';
import 'package:poppycorn/models/submodels/channel_serie.dart';


class SeriesList extends StatefulWidget {
  final String category_id;
  final String? categoryTitle;
  const SeriesList(
      {super.key, required this.category_id, this.categoryTitle = ''});

  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  String search_text = "";

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
              body: Column(
                children: [
                  HeaderEpisodes(
                    searchButton: true,
                    color: jBackgroundColor,
                    isTitle: true,
                    title: widget.categoryTitle,
                    onSearch: (value){
                      setState(() {
                        search_text = value.toLowerCase();
                      });
                    },
                    searchInput: true,
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                      child: BlocProvider(
                        create: (context) =>
                            SeriesListBloc(widget.category_id)..add(getSeries()),
                        child: BlocBuilder<SeriesListBloc, SeriesListState>(
                          builder: (context, state) {


                            if (state is LoadedSeries) {
                              final channels = state.SeriesList;

                              List<ChannelSerie> searchList = channels
                                  .where((element) =>
                                  element.name!.toLowerCase().contains(search_text))
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
                                  itemCount: searchList.isEmpty ? channels.length : searchList.length,
                                  itemBuilder: (context, index) {

                                    final model =
                                    (search_text.isEmpty || searchList.isEmpty) ? channels : searchList;

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
                                                  ImageUrl: model[index].cover!,
                                                  ImageSize: double.infinity,
                                                  ImageHeight: double.infinity,
                                                )),
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
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: SizedBox(
                                                            width: double.infinity,
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                //context.push("/$screenSeriesDetails/${_filteredChannels[index]['series_id']}")

                                                                Navigator.pushNamed(
                                                                    context,
                                                                    '/$screenSeriesDetails',
                                                                    arguments:
                                                                    model[index].seriesId!);
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
                                                                        jBackgroundColorBlue
                                                                            .withOpacity(
                                                                                0)),
                                                                shape: MaterialStateProperty
                                                                    .all<
                                                                        RoundedRectangleBorder>(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
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
                                                              const EdgeInsets.only(
                                                                  bottom: 5,
                                                                  left: 5,
                                                                  right: 5),
                                                          child: Text(
                                                            model[index].name!,
                                                            style: movieTitleStyle,
                                                            overflow:
                                                                TextOverflow.ellipsis,
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
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                              vertical: 5),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                              vertical: 3),
                                                      decoration: jRatingDecoration,
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
                                                              Functionality.ratingCheck(
                                                                  model[index].rating!
                                                                      .toString()),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors.amber))
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
                              return Container(
                                child: Text(state.message),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: jTextColorLight,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ));
        }
      ),
    );
  }
}
