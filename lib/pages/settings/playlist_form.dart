// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';

import 'dart:async';

import 'package:poppycorn/pages/settings/playlists.dart';
import 'package:poppycorn/pages/settings/xtream.dart';

class PlayListForm extends StatefulWidget {
  const PlayListForm({super.key});

  @override
  State<PlayListForm> createState() => _PlayListFormState();
}

class _PlayListFormState extends State<PlayListForm> {

  final dio = Dio();
  // Device Id
  String deviceEmail = 'Unknown';
  String deviceKey = 'Unknown';

  bool isLoadingCategories = false;

  final TextEditingController playlist_name = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController playlist_url = TextEditingController();

  final TextEditingController ext_url = TextEditingController();

  final List<Map<String, dynamic>> _items = [];

  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');

  int? default_id;

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();

  final FocusNode _focusNode6 = FocusNode();
  final FocusNode _focusNode7 = FocusNode();
  final FocusNode _focusNode8 = FocusNode();
  final FocusNode _focusNode9 = FocusNode();
  final FocusNode _focusNode10 = FocusNode();
  final FocusNode _focusNode11 = FocusNode();
  final FocusNode _focusNode12 = FocusNode();

  @override
  void initState() {
    setState(() {
      default_id = defaultPlaylist.get('default');
    });


    var jupiterBox = Hive.box('jupiterBox');
    setState(() {
      deviceEmail = jupiterBox.get('email');
      deviceKey = jupiterBox.get('deviceKey');
    });
    super.initState();
  }



  Future<void> _getHostPlaylists() async {

    playlistsBox.clear();

    final url = "$mainUrl/getplaylists?email=${deviceEmail}&device_key=$deviceKey";


    final response = await dio.get(url);

    if (response.statusCode == 200) {

      if(response != null) {
        final parsedJson = jsonDecode(response.data);

        for (int i = 0; i < parsedJson.length; i++) {
          _createItem(parsedJson[i]);
        }

      }

      if(mounted) {
        Navigator.of(context).pop();
      }
    } else {
      throw Exception('Failed to load data from the server');
    }
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


    showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
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
            ),
          );
        });

    final iptv_url =
        '$link/player_api.php?username=$username&password=$password';


    try {
      final iptv_response = await dio.get(iptv_url);

      if (iptv_response.statusCode == 200) {
        final url =
            "$mainUrl/setplaylist?email=$deviceEmail&device_key=$deviceKey&name=${name??'Playlist Name'}&username=$username&password=$password&url=${Uri.encodeQueryComponent(link)}";


        try {
          final response = await dio.get(
            url
          );

          if (response.statusCode == 200) {

            await _getHostPlaylists();

            if(mounted){
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/$screenPlaylists");
            }

          }else{

            if(mounted) {
              Navigator.pop(context);
            }
            final snackBar = SnackBar(
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              content: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(HeroiconsOutline.exclamationTriangle,
                        color: Colors.white),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Error: All fields are required.",
                      style: TextStyle(color: jTextColorWhite),
                    )
                  ],
                ),
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            );
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
        } catch (error) {

          if(mounted) {
            Navigator.pop(context);
          }
          const snackBar =  SnackBar(
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
      else{
        final snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          content: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(HeroiconsOutline.exclamationTriangle,
                    color: Colors.white),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Error: Maybe the link or the user info are incorrect.",
                  style: TextStyle(color: jTextColorWhite),
                )
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        );
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              Icon(HeroiconsOutline.exclamationTriangle,
                  color: jBackgroundColor),
              SizedBox(
                width: 10,
              ),
              Text(
                "OPERATION FAILED, CHECK YOUR IPTV LINK",
                style: TextStyle(color: jBackgroundColor),
              )
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


  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    _focusNode6.dispose();
    _focusNode7.dispose();
    _focusNode8.dispose();
    _focusNode9.dispose();
    _focusNode10.dispose();
    _focusNode11.dispose();
    _focusNode12.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderEpisodes(),
            const SizedBox(
              height: 10,
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RawKeyboardListener(
                focusNode: _focusNode6,
                onKey: (RawKeyEvent event){
                  if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.arrowUp){

                    _focusNode1.requestFocus();
                  }
                },
                child: TextField(
                  focusNode: _focusNode1,
                  style: TextStyle(
                    color:
                    Colors.grey.shade400, // Change the text color here
                  ),
                  decoration: InputDecoration(
                      hintText: 'Playlist name',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13.0),
                      prefixIcon: Icon(
                        HeroiconsOutline.playCircle,
                        color: Colors.grey.shade400,
                      ),
                      fillColor: jActiveElementsColor,
                      filled: true,
                      contentPadding: const EdgeInsets.all(0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none)),
                  onSubmitted: (value){
                    setState(() {
                      playlist_name.text = value;
                    });
                    _focusNode2.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      playlist_name.text = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RawKeyboardListener(
                focusNode: _focusNode7,
                onKey: (RawKeyEvent event){
                  if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.arrowUp){

                    _focusNode1.requestFocus();
                  }
                },
                child: TextField(
                  focusNode: _focusNode2,
                  style: TextStyle(
                    color:
                    Colors.grey.shade400, // Change the text color here
                  ),

                  decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13.0),
                      prefixIcon: Icon(
                        HeroiconsOutline.user,
                        color: Colors.grey.shade400,
                      ),
                      fillColor: jActiveElementsColor,
                      filled: true,
                      contentPadding: const EdgeInsets.all(0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none)),
                  onSubmitted: (value){
                    setState(() {
                      username.text = value;
                    });
                    _focusNode3.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      username.text = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RawKeyboardListener(
                focusNode: _focusNode8,
                onKey: (RawKeyEvent event){
                  if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.arrowUp){

                    _focusNode2.requestFocus();
                  }
                },
                child: TextField(
                  focusNode: _focusNode3,
                  style: TextStyle(
                    color:
                    Colors.grey.shade400, // Change the text color here
                  ),
                  decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13.0),
                      prefixIcon: Icon(
                        HeroiconsOutline.lockClosed,
                        color: Colors.grey.shade400,
                      ),
                      fillColor: jActiveElementsColor,
                      filled: true,
                      contentPadding: const EdgeInsets.all(0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none)),
                  onSubmitted: (value){
                    setState(() {
                      password.text = value;
                    });
                    _focusNode4.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      password.text = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:  RawKeyboardListener(
                focusNode: _focusNode9,
                onKey: (RawKeyEvent event){
                  if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.arrowUp){

                    _focusNode3.requestFocus();
                  }
                },
                child: TextField(
                  focusNode: _focusNode4,
                  style: TextStyle(
                    color:
                    Colors.grey.shade400, // Change the text color here
                  ),
                  decoration: InputDecoration(
                      hintText: 'Host (http://provider.com:8080)',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13.0),
                      prefixIcon: Icon(
                        HeroiconsOutline.link,
                        color: Colors.grey.shade400,
                      ),
                      fillColor: jActiveElementsColor,
                      filled: true,
                      contentPadding: const EdgeInsets.all(0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none)),
                  onSubmitted: (value){
                    setState(() {
                      playlist_url.text = value;
                    });
                    _focusNode5.requestFocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      playlist_url.text = value;
                    });
                  },

                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(top:5),
              child: const Text("Make sure your IPTV URL is using either http:// or https://",
                  style: TextStyle(color: Colors.orangeAccent,fontSize: 12)
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                      },
                      child: ElevatedButton(
                        focusNode: _focusNode5,
                        onPressed: () {

                          savePlaylist(
                            playlist_name.text,
                            username.text,
                            password.text,
                            playlist_url.text,
                          );

                        },
                        style: ButtonStyle(
                            overlayColor: mFocusColor,
                            elevation: MaterialStateProperty.all<double>(0),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                jBackgroundColorBlue),

                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            )),
                        child: Row(
                          children: [
                            Icon(
                              HeroiconsOutline.folderPlus,
                              color: jTextColorLight,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Create",
                              style: TextStyle(color: jTextColorLight),
                            ),
                          ],
                        ),

                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  const ExtreamCode())
                          );
                        },
                        style: ButtonStyle(
                            overlayColor: mFocusColor,
                            elevation: MaterialStateProperty.all<double>(0),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                jElementsBackgroundColor),

                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            )),
                        child: RawKeyboardListener(
                          focusNode: _focusNode11,
                          onKey: (RawKeyEvent event){
                            if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.select){

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      const ExtreamCode())
                              );

                            }
                          },
                          child: Row(
                            children: [
                              Icon(HeroiconsOutline.link,color: jTextColorLight),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(child: Text("M3U LINK", style: TextStyle(color: jTextColorLight),)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const Playlists()),
                          );
                        },
                        style: ButtonStyle(
                            overlayColor: mFocusColor,
                            elevation: MaterialStateProperty.all<double>(0),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                jElementsBackgroundColor),

                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            )),
                        child: RawKeyboardListener(
                          focusNode: _focusNode12,
                          onKey: (RawKeyEvent event){
                            if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.select){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      const Playlists())
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Icon(HeroiconsOutline.listBullet,color: jTextColorLight),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(child: Text("Playlists", style: TextStyle(color: jTextColorLight))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
