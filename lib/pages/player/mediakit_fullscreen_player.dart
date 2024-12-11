// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MediaKitFullScreen extends StatefulWidget {
  const MediaKitFullScreen({
    super.key,
    required this.streamUrl,
    required this.streamId,
    required this.title,
    required this.programme,
    required this.onPressed,
    this.fillScreen, this.logo
  });

  final String streamUrl;
  final String? logo;
  final String streamId;
  final String title; final String programme;
  final VoidCallback onPressed;
  final FocusNode? fillScreen;

  @override
  State<MediaKitFullScreen> createState() => _MediaKitFullScreenState();
}

class _MediaKitFullScreenState extends State<MediaKitFullScreen> {

  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var channelsFavorites = Hive.box('favorite_channels_box');

  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  late Timer timer;

  //-- Player Controllers
  bool showControllersVideo = false;
  final FocusNode _fullScreenNode = FocusNode();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _fillScreenNode = FocusNode();
  bool isPlayed = true;
  bool progress = true;
  String position = '';
  String duration = '';
  double sliderValue = 0.0;
  bool validPosition = false;
  bool isSeekingForward = false;
  bool isSeekingBackaward = false;
  bool isPlaying = true;
  bool isFullEspectRation = false;
  double aspectRatio = 16/9;

  bool isFillScreen = true;


  bool isFavorite = false;
  int? favoriteKey;


  /// media kit
  double vwidth=0.0;
  double vheight=0.0;
  String aspectR= "16:9";
  double aspect=16/9;
  List<SubtitleTrack> _availableLanguages = [new SubtitleTrack("0", "no", "None")];
  List<AudioTrack> _availableAudios = [new AudioTrack("0", "no", "None")];

  List<SubtitleTrack> subtitles=[];
  @override
  void initState() {

    WakelockPlus.enable();


    player.open(Media(widget.streamUrl)).then((value) => {
      setState(() {
        this.isPlayed=true;
        this.progress=false;
      }),
      player.stream.tracks.listen((event) {
        // List<VideoTrack> videos = event.video;
        List<AudioTrack> audios = event.audio;
        subtitles = event.subtitle;
        subtitles.forEach((element) {

          if(element?.language!=null)  setState(() { this._availableLanguages.add(element);  })  ;

        });
        audios.forEach((AudioTrack  elt) {
          if(elt?.language!=null)  setState(() {
            this._availableAudios.add(elt);
          })  ;
        });
      }),
      player.stream.width.listen((event) {
        vwidth=event!.toDouble();
      }),
      player.stream.height.listen((event) {
        vheight=event!.toDouble();
      }),
      player.setVideoTrack(VideoTrack.auto()),
      player.setAudioTrack(AudioTrack.auto()),
      player.setSubtitleTrack(SubtitleTrack.auto()),
    });




    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if(mounted)
      {
        setState(() {
          showControllersVideo = false;
        });
      }
    });



    makeAsFavorite(widget.streamId);


    super.initState();

  }


  void makeAsFavorite(String streamId){

    final favoritesList = channelsFavorites.keys.map((key) {
      final item = channelsFavorites.get(key);

      return {"key": key, "channelId": item['channelId']};
    }).toList();


    //channelsFavorites.clear();
    for (int i = 0; i < favoritesList.length; i++) {
      if (favoritesList[i]['channelId'] == streamId) {
        if (mounted) {
          setState(() {
            isFavorite = true;

            favoriteKey = favoritesList[i]['key'];
          });
        }

        break;
      } else {
        if (mounted) {
          setState(() {
            isFavorite = false;

            favoriteKey = favoritesList[i]['key'];
          });
        }
      }
    }
  }


  //---------- Favorites Methods
  Future<void> savePlaylist(String defaultPlaylist, String name,
      String channelId, String image) async {
    _createItem({
      'defaultPlaylist': defaultPlaylist,
      'channelName': name,
      'channelImage': image,
      'channelId': channelId,
    });
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
                child: CircularProgressIndicator(
                  color: jTextColorLight,
                ),
              ),
            ),
          );
        });

    var key = await channelsFavorites.add(newItem);

    if (mounted) {
      setState(() {
        favoriteKey = key;
      });
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() async {
    super.dispose();

    controller.player.stop();
    await player.dispose();
    _focusNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: (RawKeyEvent event) {
        setState(() {

          if (!showControllersVideo) {
            _fullScreenNode.requestFocus();
          }
          if(event is KeyDownEvent &&
              event.logicalKey != LogicalKeyboardKey.select)
          {
            showControllersVideo = true;
          }

          if (showControllersVideo) {

            if(event is KeyDownEvent &&
                event.logicalKey != LogicalKeyboardKey.arrowDown)
            {
              _fullScreenNode.requestFocus();
            }

            else if(event is KeyDownEvent &&
                event.logicalKey != LogicalKeyboardKey.arrowUp)
            {
              _fullScreenNode.requestFocus();
            }
          }

          showControllersVideo = true;
        });

      },
      focusNode: _focusNode,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Video(
                    key: UniqueKey(),
                    controller: controller,
                    //aspectRatio: aspect,
                    fit: aspectR=="20:9" ? BoxFit.fill : BoxFit.contain,
                    subtitleViewConfiguration: const SubtitleViewConfiguration(
                      //  style: TextStyle(fontSize: 100),
                        padding: EdgeInsets.only(bottom: 50)
                    ),
                    controls: (state) {
                      return Stack(
                        children: [
                          Container(
                            //color: Colors.amber,
                            child: GestureDetector(
                              onDoubleTap: () {
                                setState(() {
                                  showControllersVideo = !showControllersVideo;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  showControllersVideo = true;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  child: !showControllersVideo
                                      ?  Container()
                                      : Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        ///Back & Title
                                        !showControllersVideo
                                            ? const SizedBox()
                                            : const Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: SizedBox(),
                                            ),
                                          ],
                                        ),

                                        ///Slider & Play/Pause
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            margin: const EdgeInsets.all(10),

                                            decoration: BoxDecoration(
                                                color: jBackgroundColor.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Row(
                                              children: [
                                                !showControllersVideo
                                                    ? const SizedBox()
                                                    : const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: !showControllersVideo
                                                      ? const SizedBox()
                                                      : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        widget.title,
                                                        style: TextStyle(
                                                            color: jTextColorLight,
                                                            fontWeight: FontWeight.w800,
                                                            overflow: TextOverflow.ellipsis
                                                        ),),
                                                      Text(
                                                        widget.programme ?? 'Not Defined',
                                                        style: TextStyle(
                                                            color: jIconsColorSpecial,
                                                            fontSize: 12
                                                        ),)
                                                    ],
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
                                                    focusNode: _fillScreenNode,
                                                    onPressed: () {

                                                      Navigator.pop(context);
                                                    },
                                                    style: playersButtonStyle,
                                                    child: Icon(
                                                      Icons.logout,
                                                      color: jIconsColorLight,
                                                    ),
                                                  ),
                                                ),
                                                !showControllersVideo
                                                    ? const SizedBox()
                                                    : const SizedBox(
                                                  width: 10,
                                                ),
                                                !showControllersVideo || !isFillScreen
                                                    ? const SizedBox()
                                                    : Container(
                                                  constraints:
                                                  const BoxConstraints(maxWidth: 30.0),
                                                  child: ElevatedButton(
                                                    focusNode: _fullScreenNode,
                                                    onPressed: () {
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

                                                !showControllersVideo ? const SizedBox() :
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
                                                !showControllersVideo || !isFillScreen
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
                                ),
                              ),
                            ),
                          ),
                        ],
                      );},
                  ),
                  if (progress)
                    const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ))

                ],
              ),
            ),),

          ],
        ),
      ),
    );
  }
}

