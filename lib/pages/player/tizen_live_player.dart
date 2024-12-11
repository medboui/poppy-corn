
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_tizen/video_player_tizen.dart';

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
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        widget.streamUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}