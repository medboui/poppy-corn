
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_tizen/video_player_tizen.dart';

import '../../helpers/helpers.dart';

class TizenScreen extends StatefulWidget {
  const TizenScreen({
    Key? key,
    required this.link,
    required this.title,
    this.isLive = false,
  }) : super(key: key);
  final String link;
  final String title;
  final bool isLive;

  @override
  State<TizenScreen> createState() => _FullVideoScreenState();
}

class _FullVideoScreenState extends State<TizenScreen> {
  String position = '';
  String duration = '';
  double maxDuration = 0.0;
  double currentPosition = 0.0;
  bool validPosition = false;
  late Timer timer;
  double aspect = 16 / 9;
  String aspectR = "16:9";
  bool isPlayed = false;
  bool progress = true;
  bool showControllersVideo = true;
  bool isPlaying = true;
  List<dynamic> aspects = [
    {'id': 0, 'lbl': '20:9', 'aspect': 20 / 9},
    {'id': 1, 'lbl': '16:9', 'aspect': 16 / 9}
  ];
  double aspectRatio = 16/9;
  double vwidth = 0.0;
  double vheight = 0.0;
  bool isFullEspectRation = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _hideControllerFocus = FocusNode();
  late VideoPlayerController controller;
  VideoPlayerTizen vp=new VideoPlayerTizen();
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((ev) {
        this.progress=false;
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          this.progress=false;
        });

      });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (KeyEvent event) {
        setState(() {
          if (!showControllersVideo) {
            _hideControllerFocus.requestFocus();
            if (event is KeyDownEvent &&
                event.logicalKey != LogicalKeyboardKey.select) {
              showControllersVideo = true;
            }
          }
        });
      },
      focusNode: _focusNode,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              child: Stack(
                children: [
                  Center(
                    child:  AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    )
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showControllersVideo = !showControllersVideo;
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!progress && showControllersVideo)
                          Container(
                            color: Colors.transparent,
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  ///Back & Title
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      BackButton(
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(child: Container(),),
                        showControllersVideo && !progress ?
                        Container(
                          alignment: Alignment(0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !showControllersVideo
                                  ? const SizedBox()
                                  : Text(
                                position,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: jTextColorLight),
                              ),
                              !isTv(context)
                                  ? Expanded(
                                child: !showControllersVideo
                                    ? const SizedBox()
                                    : Slider(
                                  activeColor:
                                  jIconsColorSpecial,
                                  inactiveColor: Colors.white,
                                  value: currentPosition,
                                  min: 0.0,
                                  max: maxDuration,
                                  onChanged: (value) async {
                                  // add action
                                  },
                                ),
                              )
                                  : (showControllersVideo
                                  ? Text(
                                " / ",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: jTextColorLight),
                              )
                                  : SizedBox()),
                              !showControllersVideo
                                  ? const SizedBox()
                                  : Text(
                                duration,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: jTextColorLight),
                              ),
                              !showControllersVideo
                                  ? const SizedBox()
                                  : const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ) : SizedBox(),
                        if (!progress && showControllersVideo)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: jBackgroundColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : const SizedBox(
                                    width: 10,
                                  ),


                                  !showControllersVideo
                                      ? const SizedBox()
                                      : Container(
                                    constraints:
                                    const BoxConstraints(maxWidth: 30.0),
                                    child: ElevatedButton(
                                      focusNode: _hideControllerFocus,
                                      onPressed: () {
                                        setState(() {
                                          showControllersVideo = false;
                                        });
                                      },
                                      style: playersButtonStyle,
                                      child: Icon(
                                        Icons.arrow_downward,
                                        color: jIconsColorLight,
                                      ),
                                    ),
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : const SizedBox(
                                    width: 10,
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : Container(
                                    constraints:
                                    const BoxConstraints(maxWidth: 30.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        //_seekBackward();
                                        // add action
                                      },
                                      style: playersButtonStyle,
                                      child: Icon(
                                        Icons.replay_10_rounded,
                                        color: jIconsColorLight,
                                      ),
                                    ),
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : const SizedBox(
                                    width: 10,
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : Container(
                                    constraints:
                                    const BoxConstraints(maxWidth: 30.0),
                                    child: ElevatedButton(
                                      onPressed: () {


                                        if (controller.value.isPlaying) {
                                          controller.pause();
                                          setState(() {
                                         !!   controller.value.isPlaying
                                            isPlaying = false;
                                          });
                                        } else {
                                          controller.play();
                                          setState(() {
                                            isPlaying = true;
                                          });
                                        }
                                      },
                                      style: playersButtonStyle,
                                      child: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: jIconsColorLight,
                                      ),
                                    ),
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : const SizedBox(
                                    width: 10,
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : Container(
                                    constraints:
                                    const BoxConstraints(maxWidth: 30.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        //    _seekForward();
                                        // add action
                                      },
                                      style: playersButtonStyle,
                                      child: Icon(
                                        Icons.forward_10_rounded,
                                        color: jIconsColorLight,
                                      ),
                                    ),
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : const SizedBox(
                                    width: 10,
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : Container(
                                    constraints:
                                    const BoxConstraints(maxWidth: 30.0),
                                    child: ElevatedButton(

                                      onPressed: () {
                                       // add action
                                      },
                                      style: playersButtonStyle,
                                      child: Icon(
                                        Icons.aspect_ratio,
                                        color: isFullEspectRation
                                            ? jIconsColorSpecial
                                            : jIconsColorLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            if (progress)
              const Center(
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                  )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}