import 'package:flutter/material.dart';
import 'package:poppycorn/helpers/helpers.dart';

class CheckInternet extends StatelessWidget {
  final String message;

  const CheckInternet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jBackgroundColor,
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 54,color: Colors.amber,),
                SizedBox(height: 20,),
                Text(message, style: TextStyle(fontSize: 16,color: jTextColorLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
