import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../helpers/helpers.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({
    Key? key,
    required this.link,
    required this.title,
    this.isLive = false,
  }) : super(key: key);
  final String link;
  final String title;
  final bool isLive;

  @override
  State<MediaScreen> createState() => _FullVideoScreenState();
}

class _FullVideoScreenState extends State<MediaScreen> {
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);
  bool isPlayed = false;
  bool progress = true;
  bool showControllersVideo = true;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _hideControllerFocus = FocusNode();

  String position = '';
  String duration = '';
  double maxDuration = 0.0;
  double currentPosition = 0.0;
  bool validPosition = false;
  late Timer timer;
  double aspect = 16 / 9;
  String aspectR = "16:9";
  bool isPlaying = true;
  List<dynamic> aspects = [
    {'id': 0, 'lbl': '20:9', 'aspect': 20 / 9},
    {'id': 1, 'lbl': '16:9', 'aspect': 16 / 9}
  ];
  double aspectRatio = 16/9;
  double vwidth = 0.0;
  double vheight = 0.0;
  bool isFullEspectRation = false;
  List<SubtitleTrack> _availableLanguages = [
    new SubtitleTrack("0", "no", "None")
  ];
  List<AudioTrack> _availableAudios = [new AudioTrack("0", "no", "None")];
  List<SubtitleTrack> subtitles = [];

  /// List of playback speeds
  /*final List<double> _playbackSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2
  ];*/

  bool isSeekingForward = false;
  bool isSeekingBackaward = false;

  bool isHideFocused = false;
  bool isReplayFocused = false;
  bool isPauseFocused = false;
  bool isForwardFocused = false;
  bool isFullscreenFocused = false;
  bool isSubtitlesFocused = false;
  bool isAudiotracksFocused = false;

  @override
  void initState() {
    player.open(Media(widget.link)).then((value) => {
          player.stream.duration.listen((event) {
            maxDuration = event.inMilliseconds.toDouble();
            if (event.inHours == 0) {
              var strDuration = event.toString().split('.')[0];
              duration =
                  "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
              player.stream.position.listen((pos) {
                var strPosition = pos.toString().split('.')[0];
                position =
                    "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
                currentPosition = pos.inMilliseconds.toDouble();
              });
            } else {
              duration = event.toString().split('.')[0];
              player.stream.position.listen((pos) {
                setState(() {
                  position = pos.toString().split('.')[0];
                  currentPosition = pos.inMilliseconds.toDouble();
                });
              });
            }
            player.stream.tracks.listen((event) {
              // List<VideoTrack> videos = event.video;
              List<AudioTrack> audios = event.audio;
              subtitles = event.subtitle;
              subtitles.forEach((element) {
                if (element?.language != null)
                  this._availableLanguages.add(element);
              });
              audios.forEach((AudioTrack elt) {
                if (elt?.language != null) this._availableAudios.add(elt);
              });
            });
            player.stream.width.listen((event) {
              if (event != null) vwidth = event!.toDouble();
            });
            player.stream.height.listen((event) {
              if (event != null) vheight = event!.toDouble();
            });

            if (mounted) {
              player.setVideoTrack(VideoTrack.auto());
              player.setAudioTrack(AudioTrack.auto());
              player.setSubtitleTrack(SubtitleTrack.auto());
              setState(() {
                this.isPlayed = true;
                this.progress = false;
              });
            }
          }),
        });

    _hideControllerFocus.requestFocus();

    super.initState();
  }

  void _seekForward() async {
    Duration currentPosition = controller.player.state.position;
    Duration newPosition = currentPosition + const Duration(seconds: 10);

    // Ensure new position doesn't exceed video duration
    if (newPosition > controller.player.state.duration) {
      newPosition = controller.player.state.duration;
    }

    await controller.player.seek(newPosition);
  }

  void _seekBackward() async {
    Duration currentPosition = controller.player.state.position;
    int newPositionInSeconds = currentPosition.inSeconds - 10;

    // Ensure new position doesn't go below zero
    if (newPositionInSeconds < 0) {
      newPositionInSeconds = 0;
    }

    Duration newPosition = Duration(seconds: newPositionInSeconds);

    await controller.player.seek(newPosition);
  }

  @override
  void dispose() async {
    controller.player.stop();
    player.dispose();
    super.dispose();
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

        /*if (showControllersVideo) {

            if(event is KeyDownEvent &&
                event.logicalKey != LogicalKeyboardKey.arrowDown)
            {
              _aspectFocus.requestFocus();
            }

            else if(event is KeyDownEvent &&
                event.logicalKey != LogicalKeyboardKey.arrowUp)
            {
              _aspectFocus.requestFocus();
            }
          }*/
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
                  Video(
                    key: UniqueKey(),
                    controller: controller,
                    fit: aspectR=="20:9" ? BoxFit.fill : BoxFit.contain,
                    aspectRatio: 16 / 9,
                    subtitleViewConfiguration: const SubtitleViewConfiguration(
                        padding: EdgeInsets.only(bottom: 50)),
                    controls: (state) {
                      return SizedBox();
                    },
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
                                    await controller.player
                                        .seek(Duration(
                                        milliseconds:
                                        value.toInt()));
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
                                        _seekBackward();
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


                                        if (isPlaying) {
                                          controller.player.pause();
                                          setState(() {
                                            isPlaying = false;
                                          });
                                        } else {
                                          controller.player.play();
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
                                        _seekForward();
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
                                        setState(() {
                                          if (isFullEspectRation) {
                                            isFullEspectRation = false;
                                          } else {
                                            isFullEspectRation = true;
                                          }

                                          setState(() {
                                            if (isFullEspectRation) {
                                              aspectRatio = 16/9;
                                              isFullEspectRation = false;
                                            } else {
                                              aspectRatio = 20/9;
                                              isFullEspectRation = true;
                                            }
                                          });

                                          if (aspect==16/9) {
                                            setState(() {
                                              aspect=20/9;
                                              aspectR = "20:9";
                                            });
                                          }
                                          else {
                                            setState(() {   aspect=16/9;aspectR = "16:9"; });
                                          }
                                        });
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
                                  !showControllersVideo ? const SizedBox() :
                                  PopupMenuButton<SubtitleTrack>(
                                    tooltip: _availableLanguages.length.toString(),
                                    onSelected: (SubtitleTrack value) {
                                      setState(() {
                                        controller.player.setSubtitleTrack(value);
                                      });
                                    },
                                    color: jBackgroundColor,
                                    offset: const Offset(0, -120),
                                    icon: Icon(Icons.subtitles, color: jTextColorLight,),
                                    itemBuilder: (BuildContext context) {
                                      return _availableLanguages.map((entry) {
                                        return PopupMenuItem<SubtitleTrack>(
                                          value: entry,
                                          child: Text(entry.title.toString(),style: TextStyle(color: jTextColorLight),),
                                        );
                                      }).toList();
                                    },
                                  ),

                                  !showControllersVideo  ? const SizedBox() :
                                  PopupMenuButton<AudioTrack>(
                                    tooltip: _availableAudios.length.toString(),
                                    onSelected: (AudioTrack value) {
                                      setState(() {
                                        controller.player.setAudioTrack(value);
                                      });
                                    },
                                    color: jBackgroundColor,
                                    offset: const Offset(0, -120),
                                    icon: Icon(Icons.multitrack_audio, color: jTextColorLight,),
                                    itemBuilder: (BuildContext context) {
                                      return _availableAudios.map((entry) {
                                        return PopupMenuItem<AudioTrack>(
                                          value: entry,
                                          child: Text(entry.title.toString(),style: TextStyle(color: jTextColorLight),),
                                        );
                                      }).toList();
                                    },
                                  ),
                                  !showControllersVideo
                                      ? const SizedBox()
                                      : const SizedBox(
                                    width: 10,
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
}
