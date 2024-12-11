part of 'helpers.dart';


//------------ Backgrounds Colors
const Color jBackgroundColor = Color(0xff352A6E);
const Color jBackgroundColorLight = Color(0xff681629);
const Color jBackgroundColorBlue = Color(0xff6678F2);
const Color jBackgroundColorGreen = Color(0xff1D5659);
const Color jElementsBackgroundColor = Color(0xff5E459B);
const Color jActiveElementsBackgroundColor = Colors.amber;

const Color jFocusColor = Color(0xFFBE7DFB);

const Color jChecked = Colors.greenAccent;
const Color jUnchecked = Colors.redAccent;

MaterialStateProperty<Color> mFocusColor = MaterialStateProperty
    .resolveWith<Color>((states) {
  if (states
      .contains(MaterialState.focused)) {
    return Colors.red.withOpacity(
        0.45); // Adjust opacity for focus effect
  }
  return Colors.transparent; // Transparent overlay for other states
});
//------------ Text Colors
Color jTextColorWhite = Colors.white;
Color jTextColorLight = Colors.grey.shade400;
Color jIconsColorLight =  Colors.grey.shade400;
Color jIconsColorSpecial =  const Color(0xFFF161A6);
Color jActiveElementsColor = const Color(0xFF232254);

//------------ EPG Styling

TextStyle epgTitleStyle = TextStyle(
  color: jTextColorLight,
  fontSize: 14,
  fontWeight: FontWeight.w600
);
TextStyle epgDateStyle = const TextStyle(
    color: Color(0xFF6678F2),
    fontSize: 12,
);
TextStyle epgDateStyleS = const TextStyle(
  color: Color(0xFF6678F2),
  fontSize: 12,
);

TextStyle epgDescriptionStyle = TextStyle(
  color: jTextColorLight,
  fontSize: 12,
);

TextStyle movieTitleStyle = TextStyle(
  color: jTextColorLight,
  fontSize: 14,
  fontWeight: FontWeight.w600
);


TextStyle homeButtonsStyle = TextStyle(
    color: jTextColorLight,
    fontSize: 14,
    fontWeight: FontWeight.w600
);

//---------------- BOX DECORATION

BoxDecoration jContainerBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  color: jElementsBackgroundColor,
);
BoxDecoration jContainerBoxDecoration2 = BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: jElementsBackgroundColor.withOpacity(.4),
  /*border: Border.all(color: jTextColorLight, width: 1.5)*/
);
BoxDecoration jInkDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  color: jElementsBackgroundColor.withOpacity(0.3),
);
BoxDecoration jInkDecorationSettings = BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  color: jBackgroundColor,
);
BoxDecoration jActiveInkDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  color: jActiveElementsColor,
);

BoxDecoration jRatingDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: Colors.deepPurpleAccent,
);

ButtonStyle playersButtonStyle = ButtonStyle(
    overlayColor: mFocusColor,
    elevation: MaterialStateProperty
        .all<double>(0),
    backgroundColor:
    MaterialStateProperty.all<
        Color>(
        jIconsColorSpecial
            .withOpacity(0)),
    padding: MaterialStateProperty.all<
        EdgeInsets>(EdgeInsets.zero),
    shape: MaterialStateProperty.all<
        RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(30),
      ),
    ));

ButtonStyle subtitlesButtonStyle = ButtonStyle(
    overlayColor: mFocusColor,
    elevation: MaterialStateProperty
        .all<double>(0),
    backgroundColor:
    MaterialStateProperty.all<
        Color>(
        jElementsBackgroundColor),
    padding: MaterialStateProperty.all<
        EdgeInsets>(EdgeInsets.zero),
    shape: MaterialStateProperty.all<
        RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(30),
      ),
    ));


ButtonStyle playerFillButtons = ButtonStyle(
    overlayColor: mFocusColor,
    elevation:
    MaterialStateProperty.all<double>(
        0),
    backgroundColor:
    MaterialStateProperty.all<Color>(
        jElementsBackgroundColor),
    shape: MaterialStateProperty.all<
        RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(5),
      ),
    ));
//////////////// HOME COLORS

