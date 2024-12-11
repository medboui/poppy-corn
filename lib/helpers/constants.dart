part of 'helpers.dart';

const double sizeTablet = 950;

Size getSize(BuildContext context) => MediaQuery.of(context).size;


bool isTv(BuildContext context) {
  return MediaQuery.of(context).size.width > sizeTablet;
}

