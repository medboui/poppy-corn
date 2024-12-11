import 'dart:convert';
import 'dart:ui';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:dio/dio.dart';

class Otp extends StatelessWidget {
  const Otp({
    Key? key,
    required this.otpController,
  }) : super(key: key);
  final TextEditingController otpController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      height: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(4),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.length == 4) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration:  InputDecoration(
          hintText: ('0 0 0 0'),
          filled: true,
          fillColor: jElementsBackgroundColor,
          hintStyle: TextStyle(
            color: Colors.white70
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0), // Adjust as needed
            borderSide: const BorderSide(
              color: Colors.transparent, // Hides the default border
            ),
          ),
        ),
        onSaved: (value) {},
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key,required this.myauth, required this.UserEmail}) : super(key: key);
  final EmailOTP myauth ;
  final String UserEmail;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

  String otpController = "1234";


  final dio = Dio();
  String deviceEmail = 'Uknown';
  String deviceKey = 'Uknown';


  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  var jupiterBox = Hive.box('jupiterBox');

  List<Map<String, dynamic>> _items = [];


  Future<void> _getHostPlaylists() async {


    playlistsBox.clear();

    final url =
        "$mainUrl/getplaylists?email=$deviceEmail&device_key=$deviceKey";

    final response = await dio.get(
        url
    );

    if (response.statusCode == 200) {

      if(response != null) {
        final parsedJson = jsonDecode(response.data);

        for (int i = 0; i < parsedJson.length; i++) {
          _createItem(parsedJson[i]);
        }

        _getPlaylist();
      }

    } else {
      throw Exception('Failed to load data from the server');
    }
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
                child: Center(child: CircularProgressIndicator(color: jTextColorLight,),),
              ),
            ),
          );
        });

    await playlistsBox.add(newItem);
    if(mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _getPlaylist() async {
    final data = playlistsBox.keys.map((key) {
      final item = playlistsBox.get(key);
      return {
        "key": key,
        "id": item['id'],
        "name": item['playlistName'],
        'username': item['username'],
        'password': item['password'],
        'host': item['playlistLink']
      };
    }).toList();
    if (mounted) {
      setState(() {
        _items = data.reversed.toList();
      });
    }

  }
  /// SENDING EMAIL TO DATABASE
  Future<void> postDataToApi(String email) async {
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
        "$mainUrl/createaccount?email=$email&device_key=$deviceKey";

    final response = await dio.get(url);


    if (response.statusCode == 200) {

        jupiterBox.put('first_launch', 1);

        defaultPlaylist.put("default", 0);


        if (mounted) {
          Navigator.of(context).pop();


          if(response.toString() == "error")
            {
              Navigator.pushReplacementNamed(context, '/$changeKey', arguments: email);
            }else {
            Navigator.pushReplacementNamed(context, '/$screenChoosePlayer');
          }

        }


    }else {
      if(mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {


    setState(() {
      deviceEmail = jupiterBox.get('email');
      deviceKey = jupiterBox.get('deviceKey');
    });

    //postDataToApi(widget.UserEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
        
                const Icon(Icons.mark_email_read, size: 50, color: Colors.white70,),
                const SizedBox(
                  height: 10,
                ),
                 Text(
                  "Verify it's You",
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900, color: jIconsColorSpecial),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "We sent verification code to : ${widget.UserEmail}.",
                  style: const TextStyle(fontSize: 15, color: Colors.white)
                ),
                const Text(
                    "Please check your inbox (or spam folder) and enter the code below.",
                    style: TextStyle(fontSize: 15, color: Colors.white)
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Otp(
                      otpController: otp1Controller,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    ElevatedButton(
                      onPressed: () async {

                        if (await widget.myauth.verifyOTP(otp: otp1Controller.text) == true) {

                          await postDataToApi(widget.UserEmail);


                          await _getHostPlaylists();

                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              content: Text("CODE is verified", style: TextStyle(
                                  color: Colors.white70)),
                              backgroundColor: Colors.green,
                            ));

                          }
                        } else {
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              content: Text("Invalid CODE", style: TextStyle(color: Colors.white70),),
                              backgroundColor: Colors.pink,
                            ));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jIconsColorSpecial,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4.0), // Adjust the value for desired roundness
                        ),
                      ),
                      child: const Text(
                        "CONFIRM",
                        style: TextStyle(fontSize: 14, color: jBackgroundColor,fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(width: 10,),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.refresh,color: jTextColorLight),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Change Email", style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: jTextColorLight
                            ))
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: jElementsBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                4.0), // Adjust the value for desired roundness
                          ),
                        )),

                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}