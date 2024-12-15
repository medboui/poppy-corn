
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:video_player_videohole/video_player.dart';

import '../../helpers/helpers.dart';

class TizenLiveScreen extends StatefulWidget {
  const TizenLiveScreen({
  super.key,
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
  State<TizenLiveScreen> createState() => _FullVideoScreenState();
}

class _FullVideoScreenState extends State<TizenLiveScreen> {
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');

  late VideoPlayerController _controller;
  // VideoPlayerTizen vp=new VideoPlayerTizen();
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        widget.streamUrl);
    _controller.addListener(() {
      if (_controller.value.hasError) {
        print(_controller.value.errorDescription);
      }
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _controller.value.isInitialized
            ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(child: VideoPlayer(_controller)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: MaterialButton(
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              child: Icon(size: 30, color: Colors.white,
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              )
                          )),
                      _GetTextTrackButton(controller: _controller),
                    ],
                  ),
                  ClosedCaption(text: _controller.value.caption.text),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ]))
            : Container()
    );

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class _GetTextTrackButton extends StatelessWidget {
  const _GetTextTrackButton({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: MaterialButton(
          child: const Text('Sub language', style: TextStyle(fontSize:20,
            color: Colors.white,
          ),),
          onPressed: () async {
            final List<TextTrack>? textTracks = await controller.textTracks;
            if (textTracks == null) {
              return;
            }
            await showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Select language:'),
                    content: SizedBox(
                        height: 200,
                        width: 200,
                        child: ListView.builder(
                          itemCount: textTracks.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                  'language:${textTracks[index].language}'),
                              onTap: () {
                                controller.setTrackSelection(textTracks[index]);
                              },
                            );
                          },
                        )),
                  );
                });
          }),
    );
  }}