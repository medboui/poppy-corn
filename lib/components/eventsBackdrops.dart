import 'package:flutter/material.dart';


class EventsBackdrops extends StatefulWidget {
  const EventsBackdrops({Key? key, required this.listImages})
      : super(key: key);
  final List<String> listImages;


  @override
  State<EventsBackdrops> createState() => _EventsBackdropsState();
}

class _EventsBackdropsState extends State<EventsBackdrops> {

  late bool isNotEmpty;
  late int sizeList;
  int indexImage = 0;

  _runAnimation() async {
    await Future.delayed(const Duration(seconds: 15));

    if (mounted) {
      setState(() {
        if ((indexImage + 1) >= sizeList) {
          indexImage = 0;
        } else {
          indexImage = indexImage + 1;
        }
      });
      _runAnimation();
    }
  }


  @override
  void initState() {


    isNotEmpty = widget.listImages.isNotEmpty;

    if (isNotEmpty) {
      sizeList = widget.listImages.length;


      _runAnimation();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (!isNotEmpty) {
      return const SizedBox();
    }

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(seconds: 3),
          switchInCurve: Curves.easeIn,
          child: Image.network(
            widget.listImages[indexImage],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, url, error) {
              return const SizedBox();
            },
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.topCenter,
              begin: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.4),
                Colors.black.withOpacity(.4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
