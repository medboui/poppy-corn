import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:poppycorn/blocs/channels_bloc/tv_categories_bloc.dart';
import 'package:poppycorn/blocs/channels_bloc/tv_channels_bloc.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';
import 'package:poppycorn/blocs/channels_bloc/expanded_area_bloc.dart';


class TvChannels extends StatefulWidget {
  const TvChannels({super.key});

  @override
  State<TvChannels> createState() => _TvChannelsState();
}

class _TvChannelsState extends State<TvChannels> {
  String search_text = "";

  String CatId = "991";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => InternetBloc()),
          BlocProvider(create: (context) => ExpandedAreaBloc()),
          BlocProvider(create: (context) => TvCategoriesBloc()),
        ],
        child:
            BlocBuilder<InternetBloc, InternetState>(builder: (context, state) {
          if (state is NotConnectedState) {
            return CheckInternet(message: state.message);
          }

          return BlocProvider(
            create: (context) => ExpandedAreaBloc(),
            child: Scaffold(
              backgroundColor: jBackgroundColor,
              body: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    BlocBuilder<ExpandedAreaBloc, ExpandedAreaState>(
                      builder: (context, state) {
                        if (state is ExpandedInitial) {
                          return Container(
                            height: MediaQuery.of(context)
                                .size
                                .height, // or a specific height
                            child: Column(
                              children: [
                                Visibility(
                                  visible: state.isExpanded,
                                  child: HeaderEpisodes(
                                    isLive: true,
                                    searchButton: true,
                                    searchCallback: () {
                                      /*setState(() {
                                        searchState = !searchState;
                                      });*/
                                    },
                                    color: jBackgroundColor,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible: state.isExpanded,
                                        child: Expanded(
                                          flex: 1,
                                          child: BlocProvider(
                                            create: (context) =>
                                                TvCategoriesBloc()
                                                  ..add(getCategories()),
                                            child: BlocBuilder<TvCategoriesBloc,
                                                    TvCategoriesState>(
                                                builder: (context, state) {
                                              if (state is LoadingCategories) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              } else if (state
                                                  is LoadedCategories) {
                                                final categories =
                                                    state.categoriesList;

                                                List<CategoryModel> searchList =
                                                    categories
                                                        .where((element) =>
                                                            element
                                                                .categoryName!
                                                                .toLowerCase()
                                                                .contains(
                                                                    search_text))
                                                        .toList();

                                                return Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: ListView.builder(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    itemCount:
                                                        searchList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 5.0),
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            print('Selected Category: ${searchList[index].categoryId}'); // Debug the category value.
                                                            context.read<TvCategoriesBloc>().add(selectCategory(selectedCategory: searchList[index].categoryId!));
                                                            context.read<TvChannelsBloc>().add(getChannels());
                                                          },
                                                          style: ButtonStyle(
                                                              overlayColor:
                                                                  mFocusColor,
                                                              elevation:
                                                                  MaterialStateProperty
                                                                      .all<double>(
                                                                          0),
                                                              backgroundColor:
                                                                  state.selectedCategory == searchList[index].categoryId ?
                                                                  MaterialStateProperty.all<Color>(
                                                                      jActiveElementsColor) :
                                                                  MaterialStateProperty.all<Color>(
                                                                      jTextColorLight
                                                                          .withOpacity(
                                                                          0.1)),
                                                              shape: MaterialStateProperty
                                                                  .all<
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
                                                                const EdgeInsets
                                                                    .all(13),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  HeroiconsSolid
                                                                      .tv,
                                                                  color:
                                                                      jTextColorLight,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                    child: Text(
                                                                  searchList[
                                                                          index]
                                                                      .categoryName!,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        jTextColorLight,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                )),
                                                                Icon(
                                                                  HeroiconsOutline
                                                                      .chevronRight,
                                                                  color:
                                                                      jTextColorLight,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              } else if (state is ErrorsState) {
                                                return Container();
                                              } else {
                                                return Container();
                                              }
                                            }),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: state.isExpanded,
                                        child: Expanded(
                                          flex: 1,
                                          child: BlocProvider(
                                            create: (context) =>
                                            TvCategoriesBloc()
                                              ..add(getCategories()),
                                            child: BlocBuilder<TvCategoriesBloc,
                                                TvCategoriesState>(
                                                builder: (context, state) {
                                                  if (state
                                                  is LoadedCategories) {

                                                    return BlocProvider(
                                                      create: (context) =>
                                                      TvChannelsBloc(this.CatId)
                                                        ..add(getChannels()),
                                                      child: BlocBuilder<TvChannelsBloc,
                                                          TvChannelsState>(
                                                          builder: (context, Channelsstate) {
                                                            if (Channelsstate is LoadingCategories) {
                                                              return Center(
                                                                child:
                                                                CircularProgressIndicator(),
                                                              );
                                                            } else if (Channelsstate
                                                            is LoadedChannels) {
                                                              final channels =
                                                                  Channelsstate.ChannelsList;

                                                              return Padding(
                                                                padding:
                                                                const EdgeInsets.only(
                                                                    right: 5.0),
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(bottom: 5.0),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                              10),
                                                                          color:
                                                                          jElementsBackgroundColor),
                                                                      child: ElevatedButton(
                                                                        onPressed: () {},
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
                                                                                jElementsBackgroundColor
                                                                                    .withOpacity(
                                                                                    0.3)),
                                                                            shape: MaterialStateProperty
                                                                                .all<
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
                                                                          const EdgeInsets
                                                                              .all(12),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                  HeroiconsOutline
                                                                                      .arrowLeft,
                                                                                  color:
                                                                                  jTextColorLight),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Expanded(
                                                                                  child: Text(
                                                                                    "Back to Categories"
                                                                                        .toUpperCase(),
                                                                                    overflow:
                                                                                    TextOverflow
                                                                                        .ellipsis,
                                                                                    maxLines: 1,
                                                                                    style:
                                                                                    TextStyle(
                                                                                      color:
                                                                                      jTextColorLight,
                                                                                      fontWeight:
                                                                                      FontWeight
                                                                                          .w800,
                                                                                      fontSize:
                                                                                      12,
                                                                                    ),
                                                                                  ))
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
                                                                        channels.length,
                                                                        itemBuilder:
                                                                            (context, index) {
                                                                          return Container(
                                                                            margin:
                                                                            const EdgeInsets
                                                                                .only(
                                                                                bottom:
                                                                                5.0),
                                                                            child:
                                                                            ElevatedButton(
                                                                              onPressed:
                                                                                  () {},
                                                                              style:
                                                                              ButtonStyle(
                                                                                  overlayColor:
                                                                                  mFocusColor,
                                                                                  elevation:
                                                                                  MaterialStateProperty.all<double>(
                                                                                      0),
                                                                                  backgroundColor:
                                                                                  MaterialStateProperty.all<Color>(jTextColorLight.withOpacity(
                                                                                      0.1)),
                                                                                  shape: MaterialStateProperty.all<
                                                                                      RoundedRectangleBorder>(
                                                                                    RoundedRectangleBorder(
                                                                                      borderRadius:
                                                                                      BorderRadius.circular(10),
                                                                                    ),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding:
                                                                                const EdgeInsets
                                                                                    .all(
                                                                                    5),
                                                                                child: Row(
                                                                                  children: [
                                                                                    MyCachedImage(
                                                                                      ImageUrl:
                                                                                      channels[index].streamIcon!,
                                                                                      ImageSize:
                                                                                      40,
                                                                                      ImageHeight:
                                                                                      40,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width:
                                                                                      10,
                                                                                    ),
                                                                                    Expanded(
                                                                                        child:
                                                                                        Text(
                                                                                          channels[index]
                                                                                              .name!,
                                                                                          overflow:
                                                                                          TextOverflow.ellipsis,
                                                                                          maxLines:
                                                                                          1,
                                                                                          style:
                                                                                          TextStyle(
                                                                                            color:
                                                                                            jTextColorLight,
                                                                                            fontWeight:
                                                                                            FontWeight.w600,
                                                                                            fontSize:
                                                                                            12,
                                                                                          ),
                                                                                        )),
                                                                                    Icon(
                                                                                      Icons
                                                                                          .aspect_ratio,
                                                                                      color:
                                                                                      jIconsColorSpecial,
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
                                                              );
                                                            } else if (state
                                                            is ChannelsErrorsState) {
                                                              return Container();
                                                            } else {
                                                              return Container();
                                                            }
                                                          }),
                                                    );
                                                  } else if (state is ErrorsState) {
                                                    return Container();
                                                  } else {
                                                    return Container();
                                                  }
                                                }),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        child: Expanded(
                                          flex: 1,
                                          child: Container(
                                            color: Colors.orange,
                                            child: Column(
                                              children: [

                                                ElevatedButton(
                                                  onPressed: () {
                                                    context
                                                        .read<ExpandedAreaBloc>()
                                                        .add(ToggleExpand());
                                                  },
                                                  child: const Text(
                                                      'Toggle Container'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
