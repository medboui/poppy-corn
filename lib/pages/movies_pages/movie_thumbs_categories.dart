
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/blocs/movies_cat_bloc/movies_cat_bloc.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/components/movies_thumbs.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';

import 'package:poppycorn/pages/movies_pages/movies_list.dart';

class MoviesThumbsCategories extends StatefulWidget {
  const MoviesThumbsCategories({super.key});

  @override
  State<MoviesThumbsCategories> createState() => _MoviesThumbsCategoriesState();
}

class _MoviesThumbsCategoriesState extends State<MoviesThumbsCategories> {
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
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              Navigator.pushNamed(context, "/$screenAllMovies");
            },
            backgroundColor: jIconsColorSpecial.withOpacity(0.7),
            child: const Icon(
              HeroiconsOutline.listBullet,
              size: 20,
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        jBackgroundColor
                      ], // Define your gradient colors
                      begin: Alignment.topCenter, //
                      end: Alignment
                          .bottomCenter, // Adjust the gradient end point
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  HeaderEpisodes(
                    searchButton: true,
                    onSearch: (value){
                      setState(() {
                        search_text = value.toLowerCase();
                      });
                    },
                    searchInput: true,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: BlocProvider(
                            create: (context) => MoviesCatBloc()..add(getCategories()),
                            child: BlocBuilder<MoviesCatBloc, MoviesCatState>(builder: (context, state){

                                if (state is LoadedCategories) {

                                  final categories = state.CategoriesList;

                                  List<CategoryModel> searchList = categories
                                      .where((element) =>
                                      element.categoryName!.toLowerCase().contains(search_text))
                                      .toList();

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: searchList.isEmpty ? categories.length : searchList.length, // Number of vertical items
                                    itemBuilder: (context, index) {

                                      final model =
                                      (search_text.isEmpty || searchList.isEmpty) ? categories : searchList;

                                      if (index != 0) {
                                        return SizedBox(
                                          height: 250, // Provide a height constraint
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    model[index].categoryName!,
                                                    style: TextStyle(
                                                        color: jTextColorWhite,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 14),
                                                  ),
                                                  Expanded(child: Container()),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MoviesList(
                                                                      category_id:
                                                                      model[index].categoryId!,
                                                                      categoryTitle:
                                                                      model[index].categoryName!)),
                                                        );
                                                      },
                                                      style: ButtonStyle(
                                                          overlayColor: mFocusColor,
                                                          elevation:
                                                          MaterialStateProperty.all<
                                                              double>(0),
                                                          padding: MaterialStateProperty.all<
                                                              EdgeInsets>(
                                                              const EdgeInsets.all(10)),
                                                          backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              jTextColorLight
                                                                  .withOpacity(
                                                                  0.1)),
                                                          shape:
                                                          MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  10),
                                                            ),
                                                          )),
                                                      child: Text(
                                                        "View All",
                                                        style: TextStyle(
                                                            color: jTextColorLight),
                                                      ))
                                                ],
                                              ),
                                              Flexible(
                                                child: MoviesListThumbs(
                                                    key: UniqueKey(),
                                                    category_id:
                                                    model[index].categoryId!),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              //context.replace("/$screenAllMovies")
                                              Navigator.pushNamed(
                                                  context, '/$screenAllMovies');
                                            },
                                            style: ButtonStyle(
                                                overlayColor: mFocusColor,
                                                elevation:
                                                MaterialStateProperty.all<double>(
                                                    0),
                                                padding: MaterialStateProperty.all<
                                                    EdgeInsets>(
                                                    const EdgeInsets.all(10)),
                                                backgroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    jTextColorLight
                                                        .withOpacity(0.1)),
                                                shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                  ),
                                                )),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  HeroiconsOutline.listBullet,
                                                  color: jTextColorLight,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text('ALL MOVIES',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        color: jTextColorLight))
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }else if (state is ErrorsState){
                                  return Container();
                                }else {
                                  return Container();
                                }

                            }),
                        ),
                  ))
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}