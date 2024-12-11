// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();

    String clock = DateFormat('HH:mm a').format(now);
    String DayName = DateFormat('EEE').format(now);
    String DayNumber = DateFormat('d, MMM').format(now);


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(DayName,
                style: GoogleFonts.josefinSans(
                    textStyle: const TextStyle(
                        color: Colors.white,fontSize: 10,fontWeight: FontWeight.w200)
                )                ),
            Text(DayNumber,
                style: GoogleFonts.josefinSans(
                    textStyle: const TextStyle(
                        color: Colors.white,fontSize: 12,fontWeight: FontWeight.w200)
                )                )
          ],
        ),
        const SizedBox(width: 2,),
        Text(clock,
          style: GoogleFonts.josefinSans(
            textStyle: TextStyle(
              color: Colors.grey.shade400,fontSize: 30,fontWeight: FontWeight.w200)
          )
        ),
      ],
    );
  }
}
