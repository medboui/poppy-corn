import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';


class Functionality {
  static String ratingCheck(String rating)
  {

    if(rating != ''){
      return double.parse(rating).toStringAsFixed(1);
    }else {
      return '0';
    }

  }

  static String ShortId(String string, int number) {
    final hash = sha256.convert(utf8.encode(string));
    final shortUniqueNumber = hash.toString().substring(0, number);
    return shortUniqueNumber;
  }

  static Future<bool> popScopeFunc(BuildContext context, bool status) async
  {
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
      backgroundColor: jActiveElementsColor,
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
          onPressed: () => Navigator.pop(context, true),
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
  if(context.mounted) {
  Navigator.pushReplacementNamed(context, '/$screenSplash');
  }
  }
    return false;
  }
}