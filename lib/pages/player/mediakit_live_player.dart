
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MediaKitLivePlayer extends StatefulWidget {
  const MediaKitLivePlayer(
      {super.key,
        required this.streamUrl,
        required this.title,
        required this.programme,
        required this.onPressed,
        this.fillScreen});

  final String streamUrl;
  final String title;
  final String programme;
  final VoidCallback onPressed;
  final FocusNode? fillScreen;

  @override
  State<MediaKitLivePlayer> createState() => _MediaKitLivePlayerState();
}

class _MediaKitLivePlayerState extends State<MediaKitLivePlayer> {
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');

  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  //-- Player Controllers
  bool showControllersVideo = true;
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


  bool isFillScreen = false;



  /// media kit
  double vwidth=0.0;
  double vheight=0.0;
  String aspectR= "16:9";
  double aspect=16/9;
  List<SubtitleTrack> _availableLanguages = [new SubtitleTrack("0", "no", "None")];
  List<AudioTrack> _availableAudios = [new AudioTrack("0", "no", "None")];
  SubtitleTrack? _selectedLanguage =null;

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


    _fillScreenNode.requestFocus();

    /*Timer.periodic(const Duration(seconds: 10), (timer) {
      if(mounted)
      {
        setState(() {
          showControllersVideo = false;
        });
      }
    });*/



    super.initState();

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
    return KeyboardListener(
      onKeyEvent: (KeyEvent event) {
        setState(() {

          if (!showControllersVideo) {
            _fillScreenNode.requestFocus();
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
              _fillScreenNode.requestFocus();
            }

            else if(event is KeyDownEvent &&
                event.logicalKey != LogicalKeyboardKey.arrowUp)
            {
              _fillScreenNode.requestFocus();
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
                                                      widget.onPressed();
                                                      setState(() {
                                                        isFillScreen = !isFillScreen;
                                                      });

                                                      _fillScreenNode.requestFocus();
                                                    },
                                                    style: playersButtonStyle,
                                                    child: Icon(
                                                      !isFillScreen ? Icons.zoom_out_map : Icons.zoom_in_map,
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

                                                !showControllersVideo || !isFillScreen ? const SizedBox() :
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

                                                !showControllersVideo || !isFillScreen ? const SizedBox() :
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
