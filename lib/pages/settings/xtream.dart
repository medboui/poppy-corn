// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/settings/playlist_form.dart';
import 'dart:async';
import 'dart:convert';

import 'package:poppycorn/pages/settings/playlists.dart';

class ExtreamCode extends StatefulWidget {
  const ExtreamCode({super.key});

  @override
  State<ExtreamCode> createState() => _ExtreamCodeState();
}

class _ExtreamCodeState extends State<ExtreamCode> {

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

  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');

  int? default_id;

  List<Map<String, dynamic>> _items = [];

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  final FocusNode _focusNode6 = FocusNode();
  final FocusNode _focusNode7 = FocusNode();

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


    await playlistsBox.add(newItem);

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
            "$mainUrl/setplaylist?email=$deviceEmail&device_key=$deviceKey&name=$name&username=$username&password=$password&url=${Uri.encodeQueryComponent(link)}";


        try {
          final response = await dio.get(
            url
          );

          if (response.statusCode == 200) {

            await _getHostPlaylists();

            if(mounted){
                Navigator.pop(context);
                Navigator.pushNamed(context, "/$screenPlaylists");
            }
          }
        } catch (error) {
          if(mounted) {
            Navigator.pop(context);
          }

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

  void _getLinkInfo(String link) {




    String url = link;


    // Parse the URL string
    Uri uri = Uri.parse(url);

    // Extract the host
    String host = uri.host;

    // Extract the parameters as a map
    Map<String, String> parameters = uri.queryParameters;

    String username = parameters['username'] ?? '';
    String password = parameters['password'] ?? '';
    String playlist_url = "${uri.scheme}://$host:${uri.port}";


    savePlaylist(username?? '', username ?? '', password ?? '', playlist_url);




  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode6.dispose();
    _focusNode7.dispose();

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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                focusNode: _focusNode6,
                controller: ext_url,
                style: TextStyle(
                  color: Colors.grey.shade400, // Change the text color here
                ),
                decoration: InputDecoration(
                    hintText: 'IPTV url',
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
                    ext_url.text = value;
                  });

                  _focusNode7.requestFocus();
                },
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  "Make sure your IPTV URL is using either http:// or https://",
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
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
                      child: RawKeyboardListener(
                        focusNode: _focusNode1,
                        child: ElevatedButton(
                          focusNode: _focusNode7,
                          onPressed: () {



                            _getLinkInfo(ext_url.text);




                            //Navigator.pushNamed(context, '/$screenPlaylists');

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
                        onKey: (RawKeyEvent event){
                          if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.select){
                            _getLinkInfo(ext_url.text);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: _focusNode2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/$screenPlaylistForm");
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
                        child: Row(
                          children: [
                            Icon(HeroiconsOutline.documentText,color: jTextColorLight),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(child: Text("Xtream Code", style: TextStyle(color: jTextColorLight),)),
                          ],
                        ),
                      ),
                      onKey: (RawKeyEvent event){
                        if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.select){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  const PlayListForm())
                          );
                        }
                      },
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
                      child: RawKeyboardListener(
                        focusNode: _focusNode3,
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
                          child: Row(
                            children: [
                              Icon(HeroiconsOutline.listBullet,color: jTextColorLight),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(child: Text("Playlists", style: TextStyle(color: jTextColorLight),)),
                            ],
                          ),
                        ),
                        onKey: (RawKeyEvent event){
                          if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.select){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    const Playlists())
                            );
                          }
                        },
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
