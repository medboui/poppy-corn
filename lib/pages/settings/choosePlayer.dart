import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';

class ChoosePlayer extends StatefulWidget {
  const ChoosePlayer({super.key});

  @override
  State<ChoosePlayer> createState() => _ChoosePlayerState();
}

class _ChoosePlayerState extends State<ChoosePlayer> {


  int defaultPlayer = 0;
  var jupiterBox = Hive.box('jupiterBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /*ElevatedButton(
                    onPressed: () {
                      setState(() {
                        jupiterBox.put('defaultPlayer', 1);
                        defaultPlayer = 1;
                      });

                      Navigator.pushReplacementNamed(context, '/$screenSplash');
                    },
                    style: ButtonStyle(
                        overlayColor: mFocusColor,
                        elevation: MaterialStateProperty
                            .all<double>(0),
                        padding: MaterialStateProperty.all<
                            EdgeInsets>(
                            const EdgeInsets.all(10)),
                        backgroundColor:
                        MaterialStateProperty.all<
                            Color>(defaultPlayer == 1 ? jIconsColorSpecial
                            .withOpacity(0.3) :
                        jTextColorLight
                            .withOpacity(0.1)),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                10),
                          ),
                        )),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(defaultPlayer == 1 ? Icons.circle : Icons.circle_outlined, color: jTextColorLight,size: 13,),
                        SizedBox(width: 10,),
                        Text(
                          "Vlc Player",
                          style: TextStyle(
                              color: jTextColorLight),
                        )
                      ],
                    )),*/
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        jupiterBox.put('defaultPlayer', 0);
                        defaultPlayer = 0;
                      });
                      Navigator.pushReplacementNamed(context, '/$screenSplash');
                    },
                    style: ButtonStyle(
                        overlayColor: mFocusColor,
                        elevation: MaterialStateProperty
                            .all<double>(0),
                        padding: MaterialStateProperty.all<
                            EdgeInsets>(
                            const EdgeInsets.all(10)),
                        backgroundColor:
                        MaterialStateProperty.all<
                            Color>(defaultPlayer == 0 ? jIconsColorSpecial
                            .withOpacity(0.3) :
                        jTextColorLight
                            .withOpacity(0.1)),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                10),
                          ),
                        )),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(defaultPlayer == 0 ? Icons.circle : Icons.circle_outlined, color: jTextColorLight,size: 13,),
                        SizedBox(width: 10,),
                        Text(
                          "FEEL THE MAGIC OF IPTV PLAYER – START NOW",
                          style: TextStyle(
                              color: jTextColorLight),
                        )
                      ],
                    )),
                /*ElevatedButton(
                    onPressed: () {
                      setState(() {
                        jupiterBox.put('defaultPlayer', 2);
                        defaultPlayer = 2;
                      });
                      Navigator.pushReplacementNamed(context, '/$screenSplash');
                    },
                    style: ButtonStyle(
                        overlayColor: mFocusColor,
                        elevation: MaterialStateProperty
                            .all<double>(0),
                        padding: MaterialStateProperty.all<
                            EdgeInsets>(
                            const EdgeInsets.all(10)),
                        backgroundColor:
                        MaterialStateProperty.all<
                            Color>(defaultPlayer == 2 ? jIconsColorSpecial
                            .withOpacity(0.3) :
                        jTextColorLight
                            .withOpacity(0.1)),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                10),
                          ),
                        )),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(defaultPlayer == 2 ? Icons.circle : Icons.circle_outlined, color: jTextColorLight,size: 13,),
                        SizedBox(width: 10,),
                        Text(
                          "Lightweight Player",
                          style: TextStyle(
                              color: jTextColorLight),
                        )
                      ],
                    )),*/
              ],
            ),
          )
        ],
      ),
    );
  }
}
