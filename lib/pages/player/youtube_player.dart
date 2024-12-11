import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class MyYoutubePlayer extends StatefulWidget {
  const MyYoutubePlayer({super.key, required this.code});

  final String code;
  @override
  State<MyYoutubePlayer> createState() => _MyYoutubePlayerState();
}

class _MyYoutubePlayerState extends State<MyYoutubePlayer> {


  late YoutubePlayerController _controller;

  @override
  void initState() {

    _controller = YoutubePlayerController.fromVideoId(videoId: widget.code,autoPlay: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: YoutubePlayer(controller: _controller),
    );
  }
}
