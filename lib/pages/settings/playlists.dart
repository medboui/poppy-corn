// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:lottie/lottie.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';

import 'dart:async';
import 'dart:convert';



class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  final dio = Dio();
  // Device Id
  String deviceID = 'Unknown';
  String deviceKey = 'Unknown';
  String deviceEmail = '';

  bool isLoadingCategories = false;




  List<Map<String, dynamic>> _items = [];

  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');

  int? default_id;


  @override
  void initState() {
    setState(() {
      default_id = defaultPlaylist.get('default');
    });

    initPlatformState();
    _getPlaylist();

    super.initState();

  }

  Future<void> initPlatformState() async {

    var jupiterBox = Hive.box('jupiterBox');

    if (!mounted) return;
    setState(() {
      deviceID = jupiterBox.get('deviceID');
      deviceKey = jupiterBox.get('deviceKey');
      deviceEmail = jupiterBox.get('email');
    });

  }


  Future<void> _getHostPlaylists() async {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            color: const Color(0xff292d32).withOpacity(0.8),
            child: SizedBox(
              height: 80,
              child: OverflowBox(
                minHeight: 80,
                maxHeight: 100,
                child:Center(child: CircularProgressIndicator(color: jTextColorLight,),),
              ),
            ),
          );
        });

    playlistsBox.clear();

    final url =
        "$mainUrl/getplaylists?email=${deviceEmail}&device_key=$deviceKey";


    final response = await dio.get(
      url
    );

    if (response.statusCode == 200) {

      if(response != null) {
        final parsedJson = jsonDecode(response.data);

        for (int i = 0; i < parsedJson.length; i++) {
          _createItem(parsedJson[i]);
        }

        _getPlaylist();
      }

      if(mounted) {
        Navigator.of(context).pop();
      }
    } else {
      throw Exception('Failed to load data from the server');
    }
  }

  Future<void> _getPlaylist() async {
    final data = playlistsBox.keys.map((key) {
      final item = playlistsBox.get(key);
      return {
        "key": key,
        "id": item['id'],
        "name": item['playlistName'],
        'username': item['username'],
        'password': item['password'],
        'host': item['playlistLink']
      };
    }).toList();
    if (mounted) {
      setState(() {
        _items = data.reversed.toList();
      });
    }

  }

  Future<void> _deletePlaylist(int key, int id) async {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            color: const Color(0xff292d32).withOpacity(0.8),
            child: SizedBox(
              height: 80,
              child: OverflowBox(
                minHeight: 80,
                maxHeight: 100,
                child: Center(child: CircularProgressIndicator(color: jTextColorLight,),),
              ),
            ),
          );
        });

    final url =
        "$mainUrl/deleteplaylist?device_key=$deviceKey&playlist_id=$id";


    final response = await dio.get(
      url
    );

    if (response.statusCode == 200) {
      await playlistsBox.delete(key);

      _getPlaylist();

      if(mounted) {
        Navigator.of(context).pop();
      }
    } else {
      throw Exception('Failed to load data from the server');
    }
  }


  Future<void> _showModal(BuildContext context, String name, String username,
      String password, String host) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          true, // Allows the user to dismiss the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: jBackgroundColor,
          title: Text(
            name.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w600, color: jIconsColorSpecial),
          ),
          content: SelectableText(
            'Username : $username \n\nPassword : $password \n\nHost : $host',
            style: TextStyle(fontWeight: FontWeight.w500,color: jTextColorWhite),
          ),
          actions: <Widget>[
            Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
              },
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: mFocusColor,
                  elevation: MaterialStateProperty.all<double>(0),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(
                      jElementsBackgroundColor.withOpacity(0)),
                ),
                child: Text('Close', style: TextStyle(color: jIconsColorSpecial, fontWeight: FontWeight.w800),),
              ),
            ),
          ],
        );
      },
    );
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
                child: Center(child: CircularProgressIndicator(color: jTextColorLight,),),
              ),
            ),
          );
        });

    await playlistsBox.add(newItem);
    if(mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> savePlaylist(String name, String username, String password, String link) async {
    final iptv_url =
        '$link/player_api.php?username=$username&password=$password';

    try {

      final iptv_response = await dio.get(iptv_url);

      if (iptv_response.statusCode == 200) {
        final url =
            "$mainUrl/setplaylist?email=$deviceEmail&device_key=$deviceKey&name=$name&username=$username&password=$password&url=${Uri.encodeQueryComponent(link)}";

        try {
          final response = await dio.get(
            url
          );

          if (response.statusCode == 200) {
            _createItem({
              'playlistName': name,
              'username': username,
              'password': password,
              'playlistLink': link,
            });

            _getHostPlaylists();

            final snackBar = SnackBar(
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              content: Center(
                child: Text(response.data.toString()),
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
            );
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            //Navigator.of(context).pop();
          }
        }catch (error){
          const snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            content: Center(
              child: Text("Failed to load data from the server"),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          );
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      }
    } catch (error) {
      const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        content: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(HeroiconsOutline.exclamationTriangle, color: jBackgroundColor),
              SizedBox(width: 10,),
              Text("OPERATION FAILED, CHECK YOUR IPTV LINK", style: TextStyle(color: jBackgroundColor),)
            ],
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.amber,
      );
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }


  Future<void> _makeItDefault(int key) async {
    defaultPlaylist.put('default', key);

    if (mounted) {
      setState(() {
        default_id = defaultPlaylist.get('default');
      });

      _getPlaylist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/backsettings.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    jBackgroundColor
                  ], // Define your gradient colors
                  begin: Alignment.topCenter, //
                  end: Alignment.bottomCenter, // Adjust the gradient end point
                ),
              ),
            ),
          ),
          Positioned(
              child: Column(
                children: [
                  const HeaderEpisodes(),
                  Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                        child: Row(
                          children: [

                            Expanded(
                                flex: 1,
                                child: GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                      childAspectRatio: 1.3,
                                    ),
                                    itemCount: _items.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                        padding: const EdgeInsets.all(10),
                                        decoration: jContainerBoxDecoration2,
                                        child: Column(
                                          children: [
                                            Icon(HeroiconsOutline.rectangleStack,
                                                size: 45, color: jTextColorLight),
                                            const SizedBox(height: 5,),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _items[index]['name'].toString().toUpperCase() ?? '',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: jTextColorLight),
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Shortcuts(
                                                        shortcuts: <LogicalKeySet, Intent>{
                                                          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                                                        },
                                                        child: SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _makeItDefault(_items[index]['key']);
                                                            },
                                                            style: ButtonStyle(
                                                              overlayColor: mFocusColor,
                                                              elevation: MaterialStateProperty.all<double>(0),
                                                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                                                              backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  jElementsBackgroundColor.withOpacity(0)),
                                                            ),
                                                            child: default_id != null &&
                                                                default_id == _items[index]['key']
                                                                ? const Icon(HeroiconsSolid.playCircle,color: Colors.lightGreenAccent,)
                                                                : Icon(HeroiconsOutline.pauseCircle,color: jTextColorLight,),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5,),
                                                      Shortcuts(
                                                        shortcuts: <LogicalKeySet, Intent>{
                                                          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                                                        },
                                                        child: SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _showModal(
                                                                  context,
                                                                  _items[index]['name'],
                                                                  _items[index]['username'],
                                                                  _items[index]['password'],
                                                                  _items[index]['host']);
                                                            },
                                                            style: ButtonStyle(
                                                              overlayColor: mFocusColor,
                                                              elevation: MaterialStateProperty.all<double>(0),
                                                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                                                              backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  jElementsBackgroundColor.withOpacity(0)),
                                                            ),
                                                            child: Icon(HeroiconsOutline.arrowsPointingOut, color: jTextColorLight,),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5,),
                                                      Shortcuts(
                                                        shortcuts: <LogicalKeySet, Intent>{
                                                          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                                                        },
                                                        child: SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed: () {

                                                              _deletePlaylist(_items[index]['key'],
                                                                  _items[index]['id']);
                                                            },
                                                            style: ButtonStyle(
                                                              overlayColor: mFocusColor,
                                                              elevation: MaterialStateProperty.all<double>(0),
                                                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                                                              backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  jElementsBackgroundColor.withOpacity(0)),
                                                            ),
                                                            child: Icon(HeroiconsOutline.trash, color: jTextColorLight,),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                            ),
                            Expanded(
                              child: Transform.scale(
                                scale: 1.2,
                                child: Image.asset("assets/images/qrcode.png", width: 250,height: 250,),
                              ),
                            )
                          ],
                        ),
                      )),
                  Stack(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shortcuts(
                                shortcuts: <LogicalKeySet, Intent>{
                                  LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                                },
                                child: ElevatedButton(
                                    onPressed: () {
                                      //_showModalBottomSheet(context);
                                      //context.push("/$screenPlaylistForm");
                                      Navigator.pushNamed(context, '/$screenPlaylistForm');
                                    },
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation: MaterialStateProperty.all<double>(0),
                                        backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            jActiveElementsColor),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: Row(
                                      children: [
                                        Icon(HeroiconsOutline.plus,
                                            color: jTextColorLight),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Add Playlist",
                                          style: TextStyle(color: jTextColorLight),
                                        )
                                      ],
                                    )),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Shortcuts(
                                shortcuts: <LogicalKeySet, Intent>{
                                  LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                                },
                                child: ElevatedButton(
                                    onPressed: () {
                                      _getHostPlaylists();
                                    },
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation: MaterialStateProperty.all<double>(0),
                                        backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            jIconsColorSpecial),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: Row(
                                      children: [
                                        Icon(HeroiconsOutline.arrowPath,color: jTextColorWhite),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text("Refresh Playlists", style: TextStyle(color: jTextColorWhite,))
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}
