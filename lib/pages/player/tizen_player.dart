
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
  late VideoPlayerController _controller;
  // VideoPlayerTizen vp=new VideoPlayerTizen();
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
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