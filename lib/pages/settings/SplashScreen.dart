
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:poppycorn/pages/home.dart';
import 'package:poppycorn/pages/settings/privacy.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  //late final PodPlayerController _controller;

  final _jupiterBox = Hive.box('jupiterBox');

  void goTo() async {
    var first_launch = _jupiterBox.get('first_launch');

    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => first_launch == null ? const PrivacyPage() : const HomePage(),
        ),
      );
    });
  }

  @override
  void initState() {
    /*_controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.asset('assets/images/hola.mp4'),
    )..initialise();

    _controller.hideOverlay();*/

    goTo();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF491c8b),
      body: Transform.scale(
        scale: 1,
        child: Container()/*Lottie.asset(
          'assets/images/animated/splash.json',
          height: double.infinity,
          width: double.infinity,
        )*/,
      ),
    );
  }
}
