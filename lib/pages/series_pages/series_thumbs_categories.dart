// ignore_for_file: non_constant_identifier_names


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/blocs/series_cat_bloc/serie_cats_bloc.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/components/series_thumbs.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';

import 'package:poppycorn/pages/series_pages/series_list.dart';

class SeriesThumbsCategories extends StatefulWidget {
  const SeriesThumbsCategories({super.key});

  @override
  State<SeriesThumbsCategories> createState() => _SeriesThumbsCategoriesState();
}

class _SeriesThumbsCategoriesState extends State<SeriesThumbsCategories> {

  String search_text = "";

  bool isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternetBloc(),
      child: BlocBuilder<InternetBloc, InternetState>(
        builder: (context, state) {
          if (state is NotConnectedState) {
            return CheckInternet(message: state.message);
          }
          return BlocProvider(
            create: (context) => SerieCatsBloc()..add(getCategories()),
            child: BlocBuilder<SerieCatsBloc, SerieCatsState>(builder: (context, state){
    return Scaffold(
            backgroundColor: jBackgroundColor,
            floatingActionButton: FloatingActionButton.small(
              onPressed: () {
                Navigator.pushNamed(context, "/$screenAllSeries");
              },
              backgroundColor: jIconsColorSpecial.withOpacity(0.7),
              child: const Icon(
                HeroiconsOutline.listBullet,
                size: 20,
              ),
            ),
            body: Column(
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
                  child: isLoadingCategories == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: jTextColorLight,
                          ),
                        )
                      : BlocProvider(
                    create: (context) => SerieCatsBloc()..add(getCategories()),
                    child: BlocBuilder<SerieCatsBloc, SerieCatsState>(builder: (context, state){

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
                            searchList.isEmpty ? categories : searchList;

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
                                                        SeriesList(
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
                                      child: SeriesListThumbs(
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
                                    Navigator.pushNamed(
                                        context, '/$screenAllSeries');
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
                                      Text('ALL SERIES',
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
            ),
          );
  },
),
);
        },
      ),
    );
  }
}
