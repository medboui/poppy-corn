// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/blocs/internet_bloc/internet_bloc.dart';
import 'package:poppycorn/components/CheckInternet.dart';
import 'package:poppycorn/components/clock_widget.dart';
import 'package:poppycorn/components/eventsBackdrops.dart';
import 'package:poppycorn/helpers/helpers.dart';

import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dio = Dio();
  var isActiveAccount = Hive.box('isActiveAccount');
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var jupiterBox = Hive.box('jupiterBox');
  var DeviceKey = '';
  var DeviceEmail = '';

  List<String> eventsList = [];

  bool _isActive = false;

  final FocusNode _focusNodeActivate = FocusNode();

  Future<String> _getExpireDate() async {
    final data = await playlistsBox.get(defaultPlaylist.get('default'));
    final url =
        "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      var jsonDecoded = response.data;
      int seconds = int.parse(jsonDecoded['user_info']['exp_date']);
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

      String formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      return formattedDate;
    }

    return "-----";
  }

  Future<void> checkAccountStatus() async {
    String device_key = jupiterBox.get('deviceKey');

    if (isActiveAccount.get('isActiveAccount') == 0) {
      final response = await dio.get(
          '$mainUrl/checkaccount?email=$DeviceEmail&device_key=$device_key');

      if (response.statusCode == 200) {
        final status = response.data;

        isActiveAccount.put('isActiveAccount', int.parse(status));

        if (int.parse(status) == 1) {
          setState(() {
            _isActive = true;
          });
        }
      } else {
        // Handle error
      }
    }
  }

  Future<void> getEvents() async {
    final response = await dio.get('$mainUrl/events');

    if (response.statusCode == 200) {
      final events = response.data;

      setState(() {
        for (var item in events) {
          eventsList.add(item.toString()); // Attempt conversion to string
        }
      });
    } else {
      // Handle error
    }
  }


  @override
  void initState() {



    //_getConnectivity();
    getEvents();
    //var jupiterBox = Hive.box('jupiterBox');

    //jupiterBox.deleteAll(['first_launch','deviceId','deviceKey']);

    setState(() {
      DeviceKey = jupiterBox.get('deviceKey');
      DeviceEmail = jupiterBox.get('email');
    });
    checkAccountStatus();
    if (isActiveAccount.get('isActiveAccount') == 0) {
      setState(() {
        _isActive = false;
      });
    } else {
      setState(() {
        _isActive = true;
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _focusNodeActivate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                  Radius.circular(10.0)), // Set your desired radius
              side: BorderSide(
                  color: jTextColorLight,
                  width: 1.0), // Set border color and width
            ),
            backgroundColor: jBackgroundColorLight,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HeroiconsOutline.bellAlert,
                  size: 40,
                  color: jTextColorLight,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(color: jTextColorLight),
                )
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent), // Cancel
                child: Text(
                  'No',
                  style: TextStyle(color: jTextColorLight),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent), // Confirm
                child: Text(
                  'Yes',
                  style: TextStyle(color: jTextColorLight),
                ),
              ),
            ],
          ),
        )) {
          // User confirmed exit, navigate to the desired route
          Navigator.pushReplacementNamed(context, '/$screenSplash');
        }
        return false; // Always return false to prevent accidental popping
      },
      child:  BlocProvider(
        create: (context) => InternetBloc(),
  child: BlocBuilder<InternetBloc, InternetState>(
  builder: (context, state) {

    if(state is NotConnectedState){
      return CheckInternet(message: state.message);
    }
    return Scaffold(
            backgroundColor: jBackgroundColor,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/homescreen.png",
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned.fill(
                    child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: EventsBackdrops(
                      key: UniqueKey(), listImages: eventsList),
                )),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        stops: [
                          0.7, // Start with transparent at the beginning
                          1, // Transition to jBackgroundColor at 80% of the container's height
                        ],
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 100),
                  alignment: const Alignment(0, 0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Opacity(
                            opacity: 1,
                            child: Image.asset(
                              "assets/images/yellowlogo.png",
                              width: 50,
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Column(
                            children: [
                              const ClockWidget(),
                              FutureBuilder<String?>(
                                  future: _getExpireDate(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: Text('LOADING ...',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0)),
                                      );
                                    } else if (!snapshot.hasData) {
                                      return const Center(
                                        child: Text("COULD NOT LOAD DATA",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0)),
                                      );
                                    } else {
                                      return Text(
                                          "Playlist Expiration : ${snapshot.data}",
                                          style: TextStyle(
                                              color: jTextColorLight,
                                              fontSize: 10.0));
                                    }
                                  })
                            ],
                          )
                        ],
                      ),
                      _isActive != true
                          ? const SizedBox(
                              height: 5,
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      _isActive != true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'This Account is not Activated, ',
                                  style: TextStyle(
                                    color: jTextColorLight,
                                    fontSize: 12,
                                  ),
                                ),
                                ElevatedButton(
                                  focusNode: _focusNodeActivate,
                                  onPressed: () async {
                                    await launchUrlString(mainUrl);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    "Buy Activation!",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: jIconsColorSpecial,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            )
                          : const Text(''),
                      _isActive != true
                          ? const SizedBox(
                              height: 10,
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      if (isTv(context))
                        Expanded(flex: 1, child: Container()),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Shortcuts(
                                  shortcuts: <LogicalKeySet, Intent>{
                                    LogicalKeySet(LogicalKeyboardKey.select):
                                        const ActivateIntent(),
                                  },
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                _isActive == true
                                                    ? jTextColorLight
                                                        .withOpacity(0.3)
                                                    : Colors.black38),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                      onPressed: _isActive == true
                                          ? () {
                                              //context.pushReplacement("/$screenLiveCategories")
                                              Navigator.pushNamed(context,
                                                  '/$screenLiveCategories');
                                            }
                                          : null,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/images/tv.png",
                                            width: 60,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'LIVE TV',
                                            style: homeButtonsStyle,
                                          ),
                                        ],
                                      )),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Shortcuts(
                              shortcuts: <LogicalKeySet, Intent>{
                                LogicalKeySet(LogicalKeyboardKey.select):
                                    const ActivateIntent(),
                              },
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    overlayColor: mFocusColor,
                                    elevation:
                                        MaterialStateProperty.all<double>(0),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            _isActive == true
                                                ? jTextColorLight
                                                    .withOpacity(0.3)
                                                : Colors.black38),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: _isActive == true
                                      ? () {
                                          Navigator.pushNamed(context,
                                              '/$screenMovieCategoriesThumbs');
                                        }
                                      : null,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/movie.png",
                                        width: 60,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'MOVIES',
                                        style: homeButtonsStyle,
                                      ),
                                    ],
                                  )),
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Shortcuts(
                              shortcuts: <LogicalKeySet, Intent>{
                                LogicalKeySet(LogicalKeyboardKey.select):
                                    const ActivateIntent(),
                              },
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  overlayColor: mFocusColor,
                                  elevation:
                                      MaterialStateProperty.all<double>(0),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          _isActive == true
                                              ? jTextColorLight
                                                  .withOpacity(0.3)
                                              : Colors.black38),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                onPressed: _isActive == true
                                    ? () {
                                        Navigator.pushNamed(context,
                                            '/$screenSeriesCategoriesThumbs');
                                      }
                                    : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/show.png",
                                      width: 60,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'TV SERIES',
                                      style: homeButtonsStyle,
                                    )
                                  ],
                                ),
                              ),
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Shortcuts(
                                shortcuts: <LogicalKeySet, Intent>{
                                  LogicalKeySet(LogicalKeyboardKey.select):
                                      const ActivateIntent(),
                                },
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      overlayColor: mFocusColor,
                                      elevation:
                                          MaterialStateProperty.all<double>(
                                              0),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              _isActive == true
                                                  ? jTextColorLight
                                                      .withOpacity(0.3)
                                                  : Colors.black38),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: _isActive == true
                                        ? () {
                                            //context.pushReplacement("/$screenFavorites")
                                            Navigator.pushNamed(
                                                context, '/$screenFavorites');
                                          }
                                        : null,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          HeroiconsOutline.bookmark,
                                          color: jTextColorLight,
                                          size: 60,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'FAVORITE',
                                          style: homeButtonsStyle,
                                        )
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isTv(context))
                        Expanded(flex: 1, child: Container()),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: 300,
                        child: Row(children: [
                          Expanded(
                            child: Shortcuts(
                              shortcuts: <LogicalKeySet, Intent>{
                                LogicalKeySet(LogicalKeyboardKey.select):
                                    const ActivateIntent(),
                              },
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    overlayColor: mFocusColor,
                                    elevation:
                                        MaterialStateProperty.all<double>(0),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            jBackgroundColorBlue
                                                .withOpacity(0.3)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    //context.pushReplacement("/$screenPlaylists")

                                    Navigator.pushNamed(
                                        context, '/$screenPlaylists');
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        HeroiconsOutline.rectangleStack,
                                        color: jTextColorLight,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Playlists',
                                        style:
                                            TextStyle(color: jTextColorLight),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Shortcuts(
                            shortcuts: <LogicalKeySet, Intent>{
                              LogicalKeySet(LogicalKeyboardKey.select):
                                  const ActivateIntent(),
                            },
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  overlayColor: mFocusColor,
                                  elevation:
                                      MaterialStateProperty.all<double>(0),
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      jIconsColorSpecial.withOpacity(0.3)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  //context.pushReplacement("/$screenSettings")
                                  Navigator.pushNamed(
                                      context, '/$screenSettings');
                                  

                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      HeroiconsOutline.cog8Tooth,
                                      color: jTextColorLight,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Settings',
                                      style:
                                          TextStyle(color: jTextColorLight),
                                    )
                                  ],
                                )),
                          )),
                        ]),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text("POPPYCORN TV",
                              style: TextStyle(
                                  color: jIconsColorSpecial,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w900)),
                          Text(" IS PURE MEDIA PLAYER, NO CHANNELS INCLUDED.",
                              style: TextStyle(
                                color: jTextColorLight,
                                fontSize: 10.0,
                              )),
                          Expanded(child: Container()),
                          Text('SERIAL KEY: ',
                              style: TextStyle(
                                color: jIconsColorSpecial,
                                fontSize: 10.0,
                              )),
                          Text(DeviceKey.toUpperCase(),
                              style: TextStyle(
                                color: jTextColorLight,
                                fontSize: 10.0,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
      );
  },
),
),
    );
  }
}
