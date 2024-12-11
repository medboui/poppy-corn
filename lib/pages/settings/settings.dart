// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:lottie/lottie.dart';
import 'package:poppycorn/components/header_episodes.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/settings/privacy.dart';

import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String deviceKey = 'Unknown';
  String deviceID = 'Unknown';
  int defaultPlayer = 0;

  var isActiveAccount = Hive.box('isActiveAccount');

  bool _isActive = false;
  var jupiterBox = Hive.box('jupiterBox');

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();

  @override
  void initState() {
    if (isActiveAccount.get('isActiveAccount') == 0) {
      setState(() {
        _isActive = false;
      });
    } else {
      setState(() {
        _isActive = true;
      });
    }

    setState(() {
      defaultPlayer = jupiterBox.get('defaultPlayer');
    });

    super.initState();

    setState(() {
      deviceID = jupiterBox.get('deviceID') ?? '';
      deviceKey = jupiterBox.get('deviceKey') ?? '';
    });
  }

  void _copyToClipboard(String text, String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      content: Center(
        child: Text(message),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: jIconsColorSpecial,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    super.dispose();
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
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 15.0),
              child: Column(
                children: [
                  const HeaderEpisodes(),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Serial Key: ".toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade200),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  deviceKey.toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: jIconsColorSpecial,
                                      letterSpacing: 3),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _copyToClipboard(deviceKey,
                                        "Serial key has been copied!");
                                  },
                                  style: ButtonStyle(
                                      overlayColor: mFocusColor,
                                      elevation:
                                          MaterialStateProperty.all<double>(0),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              jElementsBackgroundColor
                                                  .withOpacity(0)),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      )),
                                  child: RawKeyboardListener(
                                    focusNode: _focusNode1,
                                    onKey: (RawKeyEvent event) {
                                      if (event is RawKeyDownEvent &&
                                          event.logicalKey ==
                                              LogicalKeyboardKey.select) {
                                        _copyToClipboard(deviceKey,
                                            "Serial key has been copied!");
                                      }
                                    },
                                    child: Icon(
                                      HeroiconsOutline.clipboard,
                                      color: jTextColorLight,
                                      size: 18,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: GridView.count(
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                crossAxisCount: 2,
                                childAspectRatio: 3.0, // Number of columns
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: const BorderRadius
                                                .all(Radius.circular(
                                                    10.0)), // Set your desired radius
                                            side: BorderSide(
                                                color: jTextColorLight,
                                                width:
                                                    1.0), // Set border color and width
                                          ),
                                          backgroundColor:
                                              jBackgroundColorLight,
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.logout,
                                                size: 40,
                                                color: jTextColorLight,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Are you sure you want to Logout?',
                                                style: TextStyle(
                                                    color: jTextColorLight),
                                              )
                                            ],
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors
                                                      .transparent), // Cancel
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                    color: jTextColorLight),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                jupiterBox
                                                    .delete('first_launch');

                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PrivacyPage()));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors
                                                      .transparent), // Confirm
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: jTextColorLight),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                jIconsColorSpecial
                                                    .withOpacity(0.3)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: jTextColorLight,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Logout'.toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: jTextColorLight),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      launch(buyCoffee);
                                    },
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
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
                                        )),
                                    child: RawKeyboardListener(
                                      focusNode: _focusNode5,
                                      onKey: (RawKeyEvent event) {
                                        if (event is RawKeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.select) {
                                          launch(buyCoffee);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.heart,
                                            color: jTextColorLight,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Love Our Devs'.toUpperCase(),
                                              style: TextStyle(
                                                color: jTextColorLight,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              padding: EdgeInsets.all(20),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: jBackgroundColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10))),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Video Player For :",
                                                      style: TextStyle(
                                                          color:
                                                              jTextColorLight,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    /*ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            jupiterBox.put(
                                                                'defaultPlayer',
                                                                1);
                                                            defaultPlayer = 1;
                                                          });

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                            overlayColor:
                                                            mFocusColor,
                                                            elevation: MaterialStateProperty
                                                                .all<double>(0),
                                                            padding: MaterialStateProperty.all<EdgeInsets>(
                                                                const EdgeInsets.all(
                                                                    10)),
                                                            backgroundColor: MaterialStateProperty.all<Color>(defaultPlayer == 1
                                                                ? jIconsColorSpecial
                                                                .withOpacity(
                                                                0.3)
                                                                : jTextColorLight
                                                                .withOpacity(
                                                                0.1)),
                                                            shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                              ),
                                                            )),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              defaultPlayer == 1
                                                                  ? Icons.circle
                                                                  : Icons
                                                                  .circle_outlined,
                                                              color:
                                                              jTextColorLight,
                                                              size: 13,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "Vlc Player",
                                                              style: TextStyle(
                                                                  color:
                                                                  jTextColorLight),
                                                            )
                                                          ],
                                                        )),*/
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            jupiterBox.put(
                                                                'defaultPlayer',
                                                                0);
                                                            defaultPlayer = 0;
                                                          });

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                            overlayColor:
                                                                mFocusColor,
                                                            elevation: MaterialStateProperty
                                                                .all<double>(0),
                                                            padding: MaterialStateProperty.all<EdgeInsets>(
                                                                const EdgeInsets.all(
                                                                    10)),
                                                            backgroundColor: MaterialStateProperty.all<Color>(defaultPlayer == 0
                                                                ? jIconsColorSpecial
                                                                    .withOpacity(
                                                                        0.3)
                                                                : jTextColorLight
                                                                    .withOpacity(
                                                                        0.1)),
                                                            shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            )),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              defaultPlayer == 0
                                                                  ? Icons.circle
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color:
                                                                  jTextColorLight,
                                                              size: 13,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "Default Player",
                                                              style: TextStyle(
                                                                  color:
                                                                      jTextColorLight),
                                                            )
                                                          ],
                                                        )),

                                                    /*ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            jupiterBox.put(
                                                                'defaultPlayer',
                                                                2);
                                                            defaultPlayer = 2;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                            overlayColor:
                                                                mFocusColor,
                                                            elevation: MaterialStateProperty
                                                                .all<double>(0),
                                                            padding: MaterialStateProperty.all<EdgeInsets>(
                                                                const EdgeInsets.all(
                                                                    10)),
                                                            backgroundColor: MaterialStateProperty.all<Color>(defaultPlayer == 2
                                                                ? jIconsColorSpecial
                                                                    .withOpacity(
                                                                        0.3)
                                                                : jTextColorLight
                                                                    .withOpacity(
                                                                        0.1)),
                                                            shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            )),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              defaultPlayer == 2
                                                                  ? Icons.circle
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color:
                                                                  jTextColorLight,
                                                              size: 13,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "Lightweight Player",
                                                              style: TextStyle(
                                                                  color:
                                                                      jTextColorLight),
                                                            )
                                                          ],
                                                        )),*/
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                jElementsBackgroundColor
                                                    .withOpacity(0.3)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.video_camera_back,
                                          color: jTextColorLight,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'VIDEO PLAYER',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: jTextColorLight),
                                          ),
                                        ),
                                        Icon(
                                          HeroiconsOutline.chevronRight,
                                          color: jTextColorLight,
                                        )
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/$screenPlaylists'),
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                jElementsBackgroundColor
                                                    .withOpacity(0.3)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: RawKeyboardListener(
                                      focusNode: _focusNode2,
                                      onKey: (RawKeyEvent event) {
                                        if (event is RawKeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.select) {
                                          Navigator.pushNamed(
                                              context, '/$screenPlaylists');
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            HeroiconsOutline.squares2x2,
                                            color: jTextColorLight,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'PLAYLISTS',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: jTextColorLight),
                                            ),
                                          ),
                                          Icon(
                                            HeroiconsOutline.chevronRight,
                                            color: jTextColorLight,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _isActive == true
                                        ? () => Navigator.pushNamed(
                                            context, "/$screenFavorites")
                                        : null,
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                jElementsBackgroundColor
                                                    .withOpacity(0.3)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: RawKeyboardListener(
                                      focusNode: _focusNode3,
                                      onKey: (RawKeyEvent event) {
                                        if (event is RawKeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.select) {
                                          _isActive == true
                                              ? Navigator.pushNamed(
                                                  context, "/$screenFavorites")
                                              : null;
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            HeroiconsOutline.bookmark,
                                            color: jTextColorLight,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'FAVORITE',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: jTextColorLight),
                                            ),
                                          ),
                                          Icon(
                                            HeroiconsOutline.chevronRight,
                                            color: jTextColorLight,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      launch(privacyUrl);
                                    },
                                    style: ButtonStyle(
                                        overlayColor: mFocusColor,
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                jElementsBackgroundColor
                                                    .withOpacity(0.3)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )),
                                    child: RawKeyboardListener(
                                      focusNode: _focusNode5,
                                      onKey: (RawKeyEvent event) {
                                        if (event is RawKeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.select) {
                                          launch(privacyUrl);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.shield_outlined,
                                            color: jTextColorLight,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Privacy Policy'.toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: jTextColorLight),
                                            ),
                                          ),
                                          Icon(
                                            HeroiconsOutline.chevronRight,
                                            color: jTextColorLight,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Transform.scale(
                          scale: 1,
                          child: Image.asset('assets/images/person.png')),
                        ), //Image.asset('assets/images/person.png')),
                      ),
                      /*LimitedBox(
                        maxWidth: 40,
                        child: ListView(
                          children: [
                            SocialButton(
                                link: facebookLink,
                                icon: FontAwesomeIcons.facebook),
                            SocialButton(
                                link: instagramLink,
                                icon: FontAwesomeIcons.instagram),
                            SocialButton(
                                link: tiktokLink,
                                icon: FontAwesomeIcons.tiktok),
                            SocialButton(
                                link: twitterLink,
                                icon: FontAwesomeIcons.twitter),
                            SocialButton(
                                link: youtubeLink,
                                icon: FontAwesomeIcons.youtube),
                            SocialButton(
                                link: linkedinLink,
                                icon: FontAwesomeIcons.linkedin),
                            SocialButton(
                                link: telegramLink,
                                icon: FontAwesomeIcons.telegram),
                          ],
                        ),
                      )*/
                    ],
                  ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
