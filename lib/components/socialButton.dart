import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart';


class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.link, required this.icon});

  final String link;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        launch(link);
      },
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.zero
          ),
          overlayColor: mFocusColor,
          elevation:
          MaterialStateProperty.all<double>(
              0),
          backgroundColor:
          MaterialStateProperty.all<Color>(
              jElementsBackgroundColor
                  .withOpacity(0.3)),
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(50),
            ),
          )),
      child: FaIcon(
        icon,
        color: jTextColorLight,
        size: 16,
      ),
    );
  }
}
