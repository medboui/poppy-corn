import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';

class ChangeKey extends StatefulWidget {
  ChangeKey({super.key, required this.email});

  String email;
  @override
  State<ChangeKey> createState() => _ChangeKeyState();
}

class _ChangeKeyState extends State<ChangeKey> {

  final dio = Dio();
  String deviceID = 'Uknown';
  String deviceKey = 'Uknown';
  var playlistsBox = Hive.box('playlists_box');
  Future<void> updateDataToApi(String email) async {
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
                child: Center(
                  child: CircularProgressIndicator(
                    color: jTextColorLight,
                  ),
                ),
              ),
            ),
          );
        });

    var url =
        "$mainUrl/changekey?email=$email&device_key=$deviceKey";


    final response = await dio.get(url);

    if (response.statusCode == 200) {


      if (mounted) {
        Navigator.of(context).pop();

        Navigator.pushReplacementNamed(context, '/$screenChoosePlayer');
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {

    var jupiterBox = Hive.box('jupiterBox');

    if (mounted) {
      setState(() {
        deviceID = jupiterBox.get('deviceID');
        deviceKey = jupiterBox.get('deviceKey');
      });
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jBackgroundColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              child: OverflowBox(
                minHeight: 50,
                maxHeight: 100,
                child: Image.asset('assets/images/person.png'),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tv, color: jTextColorWhite,),
                const SizedBox(
                  width: 10,
                ),
                Icon(Icons.arrow_right_alt, color: jTextColorWhite,),
                const SizedBox(
                  width: 10,
                ),
                Icon(Icons.tv, color: jTextColorWhite,),
              ],
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                    height: 2,
                    fontSize: 16,
                    color: jTextColorLight,
                  ),
                children: <TextSpan>[
                  TextSpan(text: "If you want to use your subscription on this "),
                  TextSpan(text: "device ",style: TextStyle(color: jIconsColorSpecial)),
                  TextSpan(text: "you have to "),
                  TextSpan(text: "replace the old serial key",style: TextStyle(color: jIconsColorSpecial)),
                  TextSpan(text: " \n",style: TextStyle(color: jIconsColorSpecial)),
                  TextSpan(text: "with the new device serial key by "),
                  TextSpan(text: "clicking ",style: TextStyle(color: jIconsColorSpecial)),
                  TextSpan(text: "on the button below."),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 165,
              child: ElevatedButton(
                  onPressed: () {
                    updateDataToApi(widget.email);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.key, color: jTextColorWhite,size: 20,),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Replace Serial Key", style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: jTextColorWhite
                      ))
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: jIconsColorSpecial,
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          4.0), // Adjust the value for desired roundness
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
