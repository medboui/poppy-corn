// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive/hive.dart';

import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/settings/otpScreen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final dio = Dio();

  EmailOTP poppyAuth = EmailOTP();
  String deviceID = 'Uknown';
  String deviceKey = 'Uknown';

  bool isChecked = true;
  bool isEmail = false;

  int indexPage = 0;

  final TextEditingController email = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final PageController _pageController = PageController(initialPage: 0);

  final jupiterBox = Hive.box('jupiterBox');
  var playlistsBox = Hive.box('playlists_box');
  var defaultPlaylist = Hive.box('default_playlist');
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    for (var key in playlistsBox.keys) {
      var user = playlistsBox.get(key);
    }

    var jupiterBox = Hive.box('jupiterBox');

    if (mounted) {
      setState(() {
        deviceID = jupiterBox.get('deviceID');
        deviceKey = jupiterBox.get('deviceKey');
      });
    }

    super.initState();
  }

  Future<void> _getHostPlaylists() async {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
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

    //playlistsBox.clear();

    final url =
        "$mainUrl/getplaylists?device_id=$deviceID&device_key=$deviceKey";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = json.decode(response.data);

      for (int i = 0; i < parsedJson.length; i++) {
        _createItem(parsedJson[i]);
      }

      if (mounted) {
        Navigator.of(context).pop();

        Navigator.pushReplacementNamed(context, '/$screenSplash');
      }
    } else {
      throw Exception('Failed to load data from the server');
    }
  }

  void isEmailValid(String email) {
    // Define a regular expression pattern for a valid email address
    final emailRegExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
      caseSensitive: false,
    );

    setState(() {
      isEmail = emailRegExp.hasMatch(email);
    });
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
        "$mainUrl/createaccount?email=$email&device_id=$deviceID&device_key=$deviceKey";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final jupiterBox = Hive.box('jupiterBox');

      jupiterBox.put('first_launch', 1);

      defaultPlaylist.put("default", 0);

      if (mounted) {
        Navigator.of(context).pop();

        Navigator.pushReplacementNamed(context, '/$screenSplash');
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> savePlaylist(
      String name, String username, String password, String link) async {
    _createItem({
      'playlistName': name,
      'username': username,
      'password': password,
      'playlistLink': link,
    });



    jupiterBox.put('first_launch', 1);

    defaultPlaylist.put("default", 0);

    Navigator.pushReplacementNamed(context, "/$screenSplash");
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
                child: Center(
                  child: CircularProgressIndicator(
                    color: jTextColorLight,
                  ),
                ),
              ),
            ),
          );
        });

    await playlistsBox.add(newItem);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                  Radius.circular(10.0)), // Set your desired radius
              side: BorderSide(
                  color: jTextColorLight,
                  width: 1.0), // Set border color and width
            ),
            backgroundColor: jBackgroundColorLight,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HeroiconsOutline.bellAlert,
                  size: 40,
                  color: jTextColorLight,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(color: jTextColorLight),
                )
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent), // Cancel
                child: Text(
                  'No',
                  style: TextStyle(color: jTextColorLight),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent), // Confirm
                child: Text(
                  'Yes',
                  style: TextStyle(color: jTextColorLight),
                ),
              ),
            ],
          ),
        )) {
          // User confirmed exit, navigate to the desired route
          Navigator.pushReplacementNamed(context, '/$screenSplash');
        }
        return false; // Always return false to prevent accidental popping
      },
      child: Scaffold(
        backgroundColor: jBackgroundColor,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: FocusScope(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          height: 30,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  focusNode: _focusNode1,
                                  style: TextStyle(
                                    color: Colors.grey
                                        .shade400, // Change the text color here
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      hintText: 'Type your Email ..',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13.0),
                                      prefixIcon: Icon(
                                        HeroiconsOutline.atSymbol,
                                        color: Colors.grey.shade400,
                                      ),
                                      fillColor: jActiveElementsColor,
                                      filled: true,
                                      contentPadding: const EdgeInsets.all(0),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide.none)),
                                  controller: email,
                                  onChanged: (value) {
                                    isEmailValid(value);
                                  },
                                  onSubmitted: (value) {
                                    _focusNode2.requestFocus();
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: 110,
                                height: 45,
                                child: ElevatedButton(
                                  focusNode: _focusNode2,
                                  onPressed: isChecked == true && isEmail == true
                                      ? () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  color: const Color(0xff292d32)
                                                      .withOpacity(0.8),
                                                  child: SizedBox(
                                                    height: 80,
                                                    child: OverflowBox(
                                                      minHeight: 80,
                                                      maxHeight: 100,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: jTextColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });

                                          poppyAuth.setConfig(
                                              appEmail: "agent@poppycorn.tv",
                                              appName: "PoppyCorn TV",
                                              userEmail: email.text,
                                              otpLength: 4,
                                              otpType: OTPType.digitsOnly);


                                          poppyAuth.setSMTP(
                                            host: 'smtp.zeptomail.com',
                                            username: 'agent@poppycorn.tv',
                                            password: 'wSsVR61wrBP1Wvp9lWCqcu0+z1QABwukQ0l93wf37XT/G/2T/ccykkaYAwCjSvFJQDY4RTZGo7t8zE0G0TpfjN4rw1EBCyiF9mqRe1U4J3x17qnvhDzPVmhVlxGBJI8AxAVimmdgG89u',
                                            secure: "TLS",
                                            port: 587,
                                          );
                                          var template = '''
                                          
                                          
                                          
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="X-UA-Compatible" content="ie=edge" />
  <title>{{app_name}}</title>
  <style>
  i {
      display: none;
    }
    </style>
</head>
<body style="margin: 0; font-family: Arial, sans-serif; background: #ffffff; font-size: 14px;">
  <div style="max-width: 680px; margin: 0 auto; padding: 45px 30px 60px; background: #f4f7ff; background-image: url(https://poppycorntv.com/img/backgroundopop.png); background-repeat: no-repeat; background-size: 800px 452px; background-position: top center; color: #434343;">
    <header>
      <table style="width: 100%;">
        <tr style="height: 0;">
          <td>
            <img alt="Poppycorn TV" src="https://poppycorn.tv/theme/img/logo.png" height="60" />
          </td>
          <td style="text-align: right;">
            <span style="font-size: 19px; line-height: 30px; color: #ffffff; font-weight: bold;">Email OTP verification</span>
          </td>
        </tr>
      </table>
    </header>
    <main>
      <div style="margin: 0; margin-top: 50px; padding: 52px 30px 60px; background: #ffffff; border-radius: 30px; text-align: center;">
        <div style="width: 100%; max-width: 489px; margin: 0 auto;">
          <h1 style="margin: 0; font-size: 27px; font-weight: bold; color: #673ab7;">Your Verification Code</h1>
          <p style="margin: 0; margin-top: 20px; font-size: 17px; font-weight: normal; ">
            Thank you for choosing <span style="font-weight: bold; color: #f716a5;">PoppyCorn TV</span>, Use this code to verify your email, valid for <span style="font-weight: bold; color: #f716a5;">5 minutes</span>.
          </p>
          <p style="margin: 0; margin-top: 60px; font-size: 40px; font-weight: bold; letter-spacing: 20px; color: #673ab7;">
            {{otp}}
          </p>
        </div>
      </div>
      <p style="max-width: 500px; margin: 30px auto 0; text-align: center; font-weight: normal; color: #00000;">
        Need help? Ask at <a href="mailto:support@poppycorn.tv" style="color: #673ab7; text-decoration: none;">support@poppycorn.tv</a> or visit our <a href="https://poppycorn.tv/contact-us" target="_blank" style="color: #673ab7; text-decoration: none;">Help Center</a>
      </p>
    </main>
    <footer style="width: 100%; max-width: 490px; margin: 23px auto 0; text-align: center; border-top: 1px solid #e6ebf1;">
      <p style="margin: 25px 0 0; font-size: 16px; font-weight: bold; color: #434343;">POPPYCORN MEDIA LIMITED</p>
      <p style="margin: 8px 0 0; color: #434343;">128 City Road, London, EC1V 2NX, UNITED KINGDOM</p>
      <p style="margin: 8px 0 0; color: #434343;">Copyright &copy; Poppycorn Media Limited. All rights reserved.</p>
    </footer>
  </div>
<div id="divCheckbox" style="visibility: hidden">

</body>
</html><div id="divCheckbox" style="visibility: hidden">
''';
                                          poppyAuth.setTemplate(render: template);
                                          if (await poppyAuth.sendOTP() == true) {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                behavior: SnackBarBehavior.floating,
                                                showCloseIcon: true,
                                                content: Text(
                                                    "CODE HAS BEEN SENT.",
                                                    style: TextStyle(
                                                        color: Colors.white70)),
                                                backgroundColor: Colors.green,
                                              ));


                                              jupiterBox.put("email", email.text);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OtpScreen(
                                                            myauth: poppyAuth,
                                                            UserEmail: email.text,
                                                          )));
                                            }
                                          } else {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                behavior: SnackBarBehavior.floating,
                                                showCloseIcon: true,
                                                content: Text(
                                                    "Oops, OTP send failed",
                                                    style: TextStyle(
                                                        color: Colors.white70)),
                                                backgroundColor:
                                                    Colors.pinkAccent,
                                              ));
                                            }
                                          }
                                          //postDataToApi(email.text);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: jIconsColorSpecial,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          4.0), // Adjust the value for desired roundness
                                    ),
                                  ),
                                  child: const Text(
                                    "NEXT",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "By using this application, you agree to the ",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade400),
                            ),
                            InkWell(
                              onTap: () async {
                                await launchUrlString(privacyUrl);
                              },
                              child: RawKeyboardListener(
                                focusNode: _focusNode3,
                                onKey: (RawKeyEvent event) async {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.select) {
                                    await launchUrlString(privacyUrl);
                                  }
                                },
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: jIconsColorSpecial,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                            Text(
                              " & ",
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            InkWell(
                              onTap: () async {
                                await launchUrlString(termsUrl);
                              },
                              child: RawKeyboardListener(
                                focusNode: _focusNode4,
                                onKey: (RawKeyEvent event) async {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.select) {
                                    await launchUrlString(termsUrl);
                                  }
                                },
                                child: Text(
                                  "Terms of services.",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: jIconsColorSpecial,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                            RawKeyboardListener(
                              focusNode: _focusNode5,
                              onKey: (RawKeyEvent event) async {
                                if (event is RawKeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.select) {
                                  setState(() {
                                    isChecked = !isChecked;
                                  });
                                }
                              },
                              child: Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = !isChecked;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, "/$screenSplash"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jElementsBackgroundColor,
                          ),
                          child: const Icon(HeroiconsSolid.home),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, "/$screenPlaylists"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jElementsBackgroundColor,
                          ),
                          child: const Text('Manage Playlists'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _getHostPlaylists();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jElementsBackgroundColor,
                          ),
                          child: const Text('Load Playlists'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, "/$screenSettings"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jElementsBackgroundColor,
                          ),
                          child: const Text('Settings'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
