import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/components/CachedImage.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/player/mediakit_fullscreen_player.dart';


class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {


  final PageController _pageController = PageController(initialPage: 0);

  int pageView = 0;
  int defaultPlayer = 0;

  var jupiterbox = Hive.box('jupiterbox');
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var moviesFavorites = Hive.box('favorite_movies_box');
  var seriesFavorites = Hive.box('favorite_series_box');
  var channelsFavorites = Hive.box('favorite_channels_box');


  //----------- Methods

  Future<List> _getMoviesFavorites() async {
    final favoritesList = moviesFavorites.keys.map((key){

      final item = moviesFavorites.get(key);

      return {"key": key,"defaultPlaylist": item['defaultPlaylist'],"movieId": item['movieId'], "name": item['movieName'], "image": item['movieImage'], "rating": item['movieRating']};
    }).toList();


    return favoritesList;
  }

  Future<List> _getSeriesFavorites() async {
    final favoritesList = seriesFavorites.keys.map((key){

      final item = seriesFavorites.get(key);

      return {"key": key,"defaultPlaylist": item['defaultPlaylist'],"seriesId": item['seriesId'], "name": item['seriesName'], "image": item['seriesImage'], "rating": item['seriesRating']};
    }).toList();


    return favoritesList;
  }

  Future<List> _getChannelsFavorites() async {
    final favoritesList = channelsFavorites.keys.map((key){

      final item = channelsFavorites.get(key);

      return {"key": key,"defaultPlaylist": item['defaultPlaylist'],"channelId": item['channelId'], "name": item['channelName'], "image": item['channelImage']};
    }).toList();


    return favoritesList;
  }
  @override
  void initState() {

    setState(() {
      defaultPlayer = jupiterbox.get('defaultPlayer');
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jBackgroundColor,
      body: Column(
        children: [
          const HeaderEpisodes(title: "Favorites",isTitle: true),
          Padding(
            padding: const EdgeInsets.only(right:10.0,left:10.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: (){

                          setState(() {
                            pageView = 0;
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300), // Optional: Animation duration
                              curve: Curves.ease, // Optional: Animation curve
                            );
                          });

                        },
                      style: ButtonStyle(
                        overlayColor: mFocusColor,
                        elevation:
                        MaterialStateProperty.all<double>(0),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(
                            pageView == 0 ? jTextColorLight : jElementsBackgroundColor),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                        ),
                      ),
                        child: Text('Channels',style: TextStyle(color: pageView == 0 ? jBackgroundColor  : jTextColorLight,fontSize: 18),),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: (){
                          setState(() {
                            pageView = 1;
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300), // Optional: Animation duration
                              curve: Curves.ease, // Optional: Animation curve
                            );
                          });
                        },
                      style: ButtonStyle(
                        overlayColor: mFocusColor,
                        elevation:
                        MaterialStateProperty.all<double>(0),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(
                            pageView == 1 ? jTextColorLight : jElementsBackgroundColor),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                        ),
                      ),
                        child: Text('Movies',style: TextStyle(color: pageView == 1 ? jBackgroundColor : jTextColorLight,fontSize: 18),),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: (){
                          setState(() {
                            pageView = 2;
                            _pageController.animateToPage(
                              2,
                              duration: const Duration(milliseconds: 300), // Optional: Animation duration
                              curve: Curves.ease, // Optional: Animation curve
                            );
                          });
                        },
                      style: ButtonStyle(
                        overlayColor: mFocusColor,
                        elevation:
                        MaterialStateProperty.all<double>(0),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(
                            pageView == 2 ? jTextColorLight : jElementsBackgroundColor),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                        ),
                      ),
                        child: Text('Series',style: TextStyle(color: pageView == 2 ? jBackgroundColor  : jTextColorLight,fontSize: 18),),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right:10.0,left:10.0),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    FutureBuilder<List>(
                        future: _getChannelsFavorites(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(color: jTextColorLight,),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text("Could not load data"),
                            );
                          }

                          final movie = snapshot.data;
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: .7,
                                ),
                                itemCount: movie!.length,
                                itemBuilder: (context, index){

                                    //if(movie[index]['defaultPlaylist'] == defaultPlaylist.get('default').toString()) {
                                    if(true == true) {
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
                                                                    onPressed: () async {

                                                                      final data = await playlistsBox.get(defaultPlaylist.get('default'));


                                                                      String streamUrl = "${data['playlistLink']}/${data['username']}/${data['password']}/${movie[index]['channelId'].toString()}";
                                                                      if(context.mounted) {
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) {



                                                                              return MediaKitFullScreen(streamUrl: streamUrl,logo:  movie[index]['image'], title: movie[index]['name'],streamId: movie[index]['channelId'].toString() , programme: "Programme not identified", onPressed: (){});


                                                                          }

                                                                        ));}
                                                                    },
                                                                    style: ButtonStyle(
                                                                      overlayColor: mFocusColor,
                                                                      elevation: MaterialStateProperty.all<double>(0),
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
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .center,
                                                                      crossAxisAlignment: CrossAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        MyCachedImage(
                                                                          ImageUrl: movie[index]['image'],
                                                                          ImageSize: double.infinity,)
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(
                                                                    bottom: 5, left: 5, right: 5),
                                                                child: Text(movie[index]['name'],
                                                                  style: movieTitleStyle,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return null;
                                }
                            ),
                          );


                        }),
                    FutureBuilder<List>(
                        future: _getMoviesFavorites(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return  Center(
                              child: CircularProgressIndicator(color: jTextColorLight,),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text("Could not load data"),
                            );
                          }

                          final movie = snapshot.data;



                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: .7,
                                ),
                                itemCount: movie!.length,
                                itemBuilder: (context, index){


                                  //if(movie[index]['defaultPlaylist'] == defaultPlaylist.get('default').toString()){
                                  if(true == true){
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
                                                    Positioned.fill(child: MyCachedImage(ImageUrl: movie[index]['image'], ImageSize: double.infinity,ImageHeight: double.infinity,)),
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [Colors.transparent, Colors.black], // Define your gradient colors
                                                            begin: Alignment.topCenter, // Adjust the gradient start point
                                                            end: Alignment.bottomCenter, // Adjust the gradient end point
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
                                                                        //context.push("/$screenMovieDetails/${movie[index]['movieId'].toString()}")
                                                                    Navigator.pushNamed(context, '/$screenMovieDetails', arguments: movie[index]['movieId'].toString());
                                                                  },
                                                                  style: ButtonStyle(
                                                                    overlayColor: mFocusColor,
                                                                    elevation: MaterialStateProperty.all<double>(0),
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
                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                    children: [
                                                                      Container(width: double.infinity,),
                                                                      Container(
                                                                        margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                                                                        decoration: jRatingDecoration,
                                                                        child: Text(movie[index]['rating'].toString() != '' ? movie[index]['rating'].toString() : "0", style: TextStyle(color: jTextColorLight),),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 5, left: 5,right: 5),
                                                              child: Text(movie[index]['name'], style: movieTitleStyle,overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return null;

                                }
                            ),
                          );


                        }),
                    FutureBuilder<List>(
                        future: _getSeriesFavorites(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return  Center(
                              child: CircularProgressIndicator(color: jTextColorLight,),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text("Could not load data"),
                            );
                          }

                          final movie = snapshot.data;
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: .7,
                                ),
                                itemCount: movie!.length,
                                itemBuilder: (context, index){
                                    //if(movie[index]['defaultPlaylist'] == defaultPlaylist.get('default').toString()) {
                                    if(true ==  true) {
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
                                                      Positioned.fill(child: MyCachedImage(
                                                        ImageUrl: movie[index]['image'],
                                                        ImageSize: double.infinity,
                                                        ImageHeight: double.infinity,)),
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
                                                                          //context.push("/$screenSeriesDetails/${movie[index]['seriesId'].toString()}")
                                                                      Navigator.pushNamed(context, '/$screenSeriesDetails', arguments: movie[index]['seriesId'].toString());
                                                                    },
                                                                    style: ButtonStyle(
                                                                      overlayColor: mFocusColor,
                                                                      elevation: MaterialStateProperty.all<double>(0),
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
                                                                      crossAxisAlignment: CrossAxisAlignment
                                                                          .end,
                                                                      children: [
                                                                        Container(width: double.infinity,),
                                                                        Container(
                                                                          margin: const EdgeInsets.symmetric(
                                                                              horizontal: 0, vertical: 10),
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 5, vertical: 3),
                                                                          decoration: jRatingDecoration,
                                                                          child: Text(movie[index]['rating']
                                                                              .toString() != ''
                                                                              ? movie[index]['rating']
                                                                              .toString()
                                                                              : "0", style: TextStyle(color: jTextColorLight)),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(
                                                                    bottom: 5, left: 5, right: 5),
                                                                child: Text(movie[index]['name'],
                                                                  style: movieTitleStyle,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return null;
                                }
                            ),
                          );


                        }),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
