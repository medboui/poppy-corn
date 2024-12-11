//import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/models/functionality.dart';
import 'package:poppycorn/pages/home.dart';
import 'package:poppycorn/pages/live_pages/tv_all.dart';
import 'package:poppycorn/pages/live_pages/tv_categories.dart';
import 'package:poppycorn/pages/movies_pages/all_movies.dart';
import 'package:poppycorn/pages/movies_pages/movie_details.dart';
import 'package:poppycorn/pages/movies_pages/movie_thumbs_categories.dart';
import 'package:poppycorn/pages/series_pages/all_series.dart';
import 'package:poppycorn/pages/series_pages/series_details.dart';
import 'package:poppycorn/pages/series_pages/series_thumbs_categories.dart';
import 'package:poppycorn/pages/settings/changeKey.dart';
import 'package:poppycorn/pages/settings/choosePlayer.dart';
import 'package:poppycorn/pages/settings/favorite.dart';
import 'package:poppycorn/pages/settings/playlist_form.dart';
import 'package:poppycorn/pages/settings/playlists.dart';
import 'package:poppycorn/pages/settings/privacy.dart';
import 'package:poppycorn/pages/settings/settings.dart';
import 'helpers/helpers.dart';
import 'dart:async';
import 'dart:convert';
import 'package:media_kit/media_kit.dart';                      // Provides [Player], [Media], [Playlist] etc.

//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

/*Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  //await Firebase.initializeApp();

  print("Handling a background message: ${message.data}");


}*/

/*Future<void> initPlatformState() async {
  final _deviceUuidPlugin = DeviceUuid();
  String uuid;
  try {
    uuid = await _deviceUuidPlugin.getUUID() ?? 'Unknown uuid version';
  } on PlatformException {
    uuid = 'Failed to get uuid version.';
  }
  String deviceID = uuid;
  String deviceKey = ShortId(uuid);
  var jupiterBox = Hive.box('jupiterBox');
  jupiterBox.put('deviceID', deviceID);
  jupiterBox.put('deviceKey', deviceKey);
}*/

Future<void> initPlatformState() async {

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String uuid = '';
  try {


    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      uuid = build.id;
    } else if (Platform.isIOS) {
      var data = await deviceInfo.iosInfo;
      uuid = data.identifierForVendor ?? 'Unknown';  // iOS vendor identifier
    } else if (Platform.isWindows) {
      var data = await deviceInfo.windowsInfo;
      uuid = data.computerName;  // Windows computer name
    } else if (Platform.isMacOS) {
      var data = await deviceInfo.macOsInfo;
      uuid = data.computerName;  // MacOS computer name
    } else if (Platform.isLinux) {
      var data = await deviceInfo.linuxInfo;
      uuid = data.id;  // Linux machine ID
    }else
    {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

      uuid = webBrowserInfo!.userAgent??'web';

    }

  } catch (e) {
    uuid = "Uknown";
  }





  /*final _deviceUuidPlugin = Uuid();
  String uuid;
  try {
    uuid = await _deviceUuidPlugin.v4() ?? 'Unknown uuid version';
  } on PlatformException {
    uuid = 'Failed to get uuid version.';
  }*/

  String deviceID = uuid.toString();
  String deviceKey = Functionality.ShortId(deviceID, 8);
print(deviceKey);
  var jupiterBox = Hive.box('jupiterBox');
  jupiterBox.put('deviceID', Functionality.ShortId(deviceID, 16));
  jupiterBox.put('deviceKey', deviceKey);

}

Future<void> checkAccountStatus() async {
  final dio = Dio();
  var isActiveAccount = Hive.box('isActiveAccount');
  var jupiterBox = Hive.box('jupiterBox');
  String device_key = jupiterBox.get('deviceKey');
  String email = jupiterBox.get('email') ?? '';
  final response = await dio.get('$mainUrl/checkaccount?email=$email&device_key=$device_key');


  if (response.statusCode == 200) {
    final status = response.data;

    isActiveAccount.put('isActiveAccount', int.parse(status));

    if (int.parse(status) != 0) {
      await _getHostPlaylists();
    }
  } else {
    // Handle error
  }
}

Future<void> _createItem(Map<String, dynamic> newItem) async {
  var playlistsBox = Hive.box('playlists_box');
  await playlistsBox.add(newItem);
}

Future<void> _getHostPlaylists() async {
  final dio = Dio();
  var jupiterBox = Hive.box('jupiterBox');
  var playlistsBox = Hive.box('playlists_box');
  String device_key = jupiterBox.get('deviceKey');
  String device_email = jupiterBox.get('email');

  playlistsBox.clear();

  final url =
      "$mainUrl/getplaylists?email=$device_email&device_key=$device_key";

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final parsedJson = json.decode(response.data);
      for (int i = 0; i < parsedJson.length; i++) {
        _createItem(parsedJson[i]);
      }
    } else {
      throw Exception('Failed to load data from the server');
    }
  } catch (error) {
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);


 // MediaKit.ensureInitialized();
// ------------------ FIREBASE
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  requestNotificationPermission();

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {


    if (message.notification != null) {
      print(message.data);


    }
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();

  print(fcmToken);*/

  // ------------------ FIREBASE

  //FlutterNativeSplash.remove();

  await Hive.initFlutter();
  await Hive.openBox('jupiterBox');
  await Hive.openBox('playlists_box');
  await Hive.openBox('default_playlist');
  await Hive.openBox('isActiveAccount');
  await Hive.openBox('default_home_video');
  // Favorite Boxes
  await Hive.openBox('favorite_channels_box');
  await Hive.openBox('favorite_movies_box');
  await Hive.openBox('favorite_series_box');

  await initPlatformState();
  await checkAccountStatus();



  runApp(const MyApp());
}

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final _jupiterBox = Hive.box('jupiterBox');

    var first_launch = _jupiterBox.get('first_launch');

    if(first_launch == null){
      _jupiterBox.put('defaultPlayer', 0);
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);


    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.browserBack): const ActivateIntent(),
      },
      child: MaterialApp(
        theme: ThemeData(
            textTheme: GoogleFonts.nanumGothicTextTheme(
              Theme.of(context).textTheme,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            popupMenuTheme:
                const PopupMenuThemeData(surfaceTintColor: Colors.red)),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => //Splashscreen(),
              first_launch == null ? const PrivacyPage() : const HomePage(),
          '/$screenSplash': (context) => const HomePage(),

          ///--- LIVETV ROUTES
          '/$screenLiveCategories': (context) => const tvCategories(),//TvChannels(),//tvCategories(),
          '/$screenAllChannels': (context) => const AllChannels(),

          ///--- MOVIES ROUTES
          '/$screenMovieCategoriesThumbs': (context) =>
              const MoviesThumbsCategories(),
          '/$screenMovieDetails': (context) => MovieDetails(
              movie_id:
                  ModalRoute.of(context)!.settings.arguments.toString()),
          '/$screenAllMovies': (context) => const AllMovies(),

          ///--- SERIES ROUTES
          '/$screenSeriesCategoriesThumbs': (context) =>
              const SeriesThumbsCategories(),
          '/$screenSeriesDetails': (context) => SeriesPage(
              series_id:
                  ModalRoute.of(context)!.settings.arguments.toString()),
          '/$screenAllSeries': (context) => const AllSeries(),
          //'/$screenSeriesList': (context, [arguments]) => SeriesList(),
          //--- SETTINGS & PRIVACY & FAVORITE PAGE
          '/$screenFavorites': (context) => const FavoritePage(),
          '/$screenSettings': (context) => const SettingsPage(),
          '/$screenPlaylists': (context) => const Playlists(),
          '/$screenPlaylistForm': (context) => const PlayListForm(),
          '/$screenChoosePlayer': (context) => const ChoosePlayer(),
          '/$changeKey': (context) => ChangeKey(
              email: ModalRoute.of(context)!.settings.arguments.toString()),
        },
      ),
    );
  }
}
