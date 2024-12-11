// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/pages/live_pages/tv_categories.dart';
import 'clock_widget.dart';

class HeaderEpisodes extends StatefulWidget {

  final VoidCallback? searchCallback;
  final bool? searchInput;
  final bool? searchButton;
  final bool? isTitle;
  final bool? isLive;
  final String? title;
  final Color? color;
  final Function(String)? onSearch;
  const HeaderEpisodes({super.key,this.isTitle = false,this.isLive = false, this.title,this.color, this.onSearch, this.searchInput,this.searchButton = false, this.searchCallback});

  @override
  State<HeaderEpisodes> createState() => _HeaderEpisodesState();
}

class _HeaderEpisodesState extends State<HeaderEpisodes> {

  var isActiveAccount = Hive.box('isActiveAccount');

  bool _isActive = false;

  bool searchState = false;


  final FocusNode _searchNode = FocusNode();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();
  final FocusNode _focusNode7 = FocusNode();

  @override
  void initState() {

    if(isActiveAccount.get('isActiveAccount') == 0)
    {
      setState(() {
        _isActive = false;
      });
    }else {
      setState(() {
        _isActive = true;
      });
    }
    super.initState();
  }
  @override
  void dispose() {
    _searchNode.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    _focusNode6.dispose();
    _focusNode7.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0, right: 15.0,left: 5.0),

      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: widget.color ?? Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 20),
          Image.asset(logoImage, width: 55,),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                const SizedBox(width: 10,),
                widget.isTitle != false ? Expanded(
                  child: Text(widget.title??'',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(color: jTextColorLight),),
                ) : Container(),
                const SizedBox(width: 10,),
                widget.searchInput != false && widget.searchInput != null ? Expanded(
                  flex: 2,
                  child: Center(
                    child: SizedBox(
                      width: 350,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        height: 30,
                        child: searchState != false ? TextField(
                          focusNode: _searchNode,
                          style: TextStyle(
                            color: Colors.grey.shade400, // Change the text color here
                          ),
                          decoration: InputDecoration(
                              hintText: 'Search for ...',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13.0
                              ),
                              prefixIcon: Icon(HeroiconsOutline.magnifyingGlass,color: Colors.grey.shade400,size: 18,),
                              fillColor: jActiveElementsColor,
                              filled: true,
                              contentPadding: const EdgeInsets.all(0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none
                              )
                          ),
                          onChanged: (value) {
                            setState(() {
                              widget.onSearch!(value);
                            });
                          },
                          onSubmitted: (value){
                            setState(() {
                              searchState = !searchState;
                            });
                          },

                        ) : const SizedBox(),
                      ),
                    ),
                  ),
                ) : Expanded(child: Container()),

                if (widget.searchButton == true) SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: (){

                          setState(() {
                            searchState = !searchState;
                          });
                          if (widget.searchCallback != null) {
                            widget.searchCallback!(); // Use the exclamation mark to call the callback safely
                          }
                        },
                        style: ButtonStyle(
                          overlayColor: mFocusColor,
                          elevation: MaterialStateProperty.all<double>(0),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              jElementsBackgroundColor.withOpacity(0)),
                        ),

                        child: RawKeyboardListener(
                            focusNode: _focusNode7,
                            onKey: (RawKeyEvent event){
                              if(event is RawKeyDownEvent &&  event.logicalKey == LogicalKeyboardKey.select){
                                setState(() {
                                  searchState = !searchState;
                                });
                                if (widget.searchCallback != null) {
                                  widget.searchCallback!(); // Use the exclamation mark to call the callback safely
                                }
                              }
                            },child: Icon(searchState == false ? HeroiconsSolid.magnifyingGlass : HeroiconsSolid.xMark, color: jTextColorLight,size: 20.0,))
                    ),
                  ),
                ) else const SizedBox(),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: () {

                              //context.replace("/$screenSplash")


                          widget.isLive == true ? Navigator.pushReplacementNamed(context, '/$screenSplash') : Navigator.pushNamed(context, '/$screenSplash');
                        },
                        style: ButtonStyle(
                          overlayColor: mFocusColor,
                          elevation: MaterialStateProperty.all<double>(0),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              jElementsBackgroundColor.withOpacity(0)),
                        ),
                        child: Icon(HeroiconsSolid.home, color: jTextColorLight,size: 20.0,)
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: _isActive == true ? () {

                          widget.isLive == true ?
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const tvCategories()),
                          ) :
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const tvCategories()),
                          );
                        } : null,
                        style: ButtonStyle(
                          overlayColor: mFocusColor,
                          elevation: MaterialStateProperty.all<double>(0),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              jElementsBackgroundColor.withOpacity(0)),
                        ),

                        child: Icon(HeroiconsSolid.tv, color: jTextColorLight,size: 20.0,)
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: _isActive == true ? () {

                              //context.replace("/$screenMovieCategoriesThumbs")
                          widget.isLive == true ? Navigator.pushReplacementNamed(context, '/$screenMovieCategoriesThumbs') :
                          Navigator.pushNamed(context, '/$screenMovieCategoriesThumbs');
                        }: null,
                        style: ButtonStyle(
                          overlayColor: mFocusColor,
                          elevation: MaterialStateProperty.all<double>(0),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              jElementsBackgroundColor.withOpacity(0)),
                        ),

                        child: Icon(HeroiconsSolid.playCircle, color: jTextColorLight,size: 20.0,)
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: _isActive == true ? () {

                              //context.replace("/$screenSeriesCategoriesThumbs")
                          widget.isLive == true ? Navigator.pushReplacementNamed(context, '/$screenSeriesCategoriesThumbs') :
                          Navigator.pushNamed(context, '/$screenSeriesCategoriesThumbs');
                        } : null,
                        style: ButtonStyle(
                          overlayColor: mFocusColor,
                          elevation: MaterialStateProperty.all<double>(0),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              jElementsBackgroundColor.withOpacity(0)),
                        ),

                        child: Icon(HeroiconsSolid.film, color: jTextColorLight,size: 20.0,)
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: _isActive == true ? () {

                              //context.replace("/$screenFavorites")
                          widget.isLive == true ? Navigator.pushReplacementNamed(context, '/$screenFavorites') :
                          Navigator.pushNamed(context, '/$screenFavorites');
                        } : null,
                        style: ButtonStyle(
                          overlayColor: mFocusColor,
                          elevation: MaterialStateProperty.all<double>(0),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(
                              jElementsBackgroundColor.withOpacity(0)),
                        ),

                        child: Icon(HeroiconsSolid.bookmark, color: jTextColorLight,size: 20.0,)
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                    },
                    child: ElevatedButton(
                        onPressed: () {

                              //context.replace("/$screenSettings")

                          widget.isLive == true ? Navigator.pushReplacementNamed(context, '/$screenSettings') :
                              Navigator.pushNamed(context, '/$screenSettings');
                        },
                        style: ButtonStyle(
                            overlayColor: mFocusColor,
                            elevation: MaterialStateProperty.all<double>(0),
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                jElementsBackgroundColor.withOpacity(0)),
                            ),

                        child: Icon(HeroiconsSolid.cog6Tooth, color: jTextColorLight,size: 20.0,)
                    ),
                  ),
                ),

                const ClockWidget()
              ],
            ),
          )
        ],
      ),
    );
  }
}
