// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poppycorn/blocs/movies_blocs/movies_list_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/models/functionality.dart';

import '../helpers/helpers.dart';


class MoviesListThumbs extends StatelessWidget {
  MoviesListThumbs({super.key, required this.category_id});

  final String category_id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MoviesListBloc(category_id)..add(getThumbsMovies()),
      child: BlocBuilder<MoviesListBloc, MoviesListState>(builder: (context, state) {
        if (state is LoadedMovies) {

          final model = state.MoviesList;
          return ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: model.length,
            // Number of items in horizontal ListView
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 150,
                height: 250,
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
                        key: UniqueKey(),
                        ImageUrl: model[index].streamIcon!,
                        ImageSize: double.infinity,
                        ImageHeight: double.infinity,
                      )),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black],
                              // Define your gradient colors
                              begin: Alignment.topCenter,
                              // Adjust the gradient start point
                              end: Alignment
                                  .bottomCenter, // Adjust the gradient end point
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //context.push("/$screenMovieDetails/${_filteredChannels[index]['stream_id']}")

                                      Navigator.pushNamed(
                                          context, '/$screenMovieDetails',
                                          arguments: model[index].streamId!);
                                    },
                                    style: ButtonStyle(
                                      overlayColor: mFocusColor,
                                      elevation:
                                          MaterialStateProperty.all<double>(0),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5, left: 5, right: 5),
                                child: Text(
                                  model[index].name!,
                                  style: movieTitleStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 3),
                            decoration: jRatingDecoration,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                    style: TextStyle(
                                        fontSize: 12, color: jTextColorLight))
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is ErrorsState) {
          return Container(child: Text(state.message));
        } else {
          return Center(child: CircularProgressIndicator(color: jTextColorLight,),);
        }
      }),
    );
  }
}
