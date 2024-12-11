
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poppycorn/helpers/helpers.dart';
import 'package:poppycorn/models/submodels/ChannelLive.dart';
import 'package:poppycorn/models/submodels/categoryModel.dart';
import 'package:poppycorn/models/submodels/channel_movie.dart';
import 'package:poppycorn/models/submodels/channel_serie.dart';
import 'package:poppycorn/models/submodels/movieCasts.dart';


class iptvApi {

  /// Categories
  Future<List<CategoryModel>> getCategories(String type) async {
    try {

      final playlistsBox = Hive.box('playlists_box');

      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      CancelToken cancelToken = CancelToken();


      var url = "${data['playlistLink']}/player_api.php";

      final response = await dio.get(
        url,
        queryParameters: {
          "password": data['password'],
          "username": data['username'],
          "action": type,
        },
        cancelToken: cancelToken
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data ?? "[]";

        final list = json.map((e) => CategoryModel.fromJson(e)).toList();

        final allCaty = CategoryModel(
          categoryId: "all",
          categoryName: "ALL",
          parentId: "0"
        );

        list.insert(0, allCaty);

        return list;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Channels Live
  Future<List<ChannelLive>> getLiveChannels(String catyId) async {
    try {
      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      CancelToken cancelToken = CancelToken();

      final url = "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_live_streams&category_id=$catyId";

      final response = await dio.get(url,
          cancelToken: cancelToken);

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.data ?? "[]");

        final list = json.map((e) => ChannelLive.fromJson(e)).toList();
        //TODO: save list to locale

        return list;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Channels Movie
  Future<List<ChannelMovie>> getMovieChannels(String catId) async {
    try {

      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      CancelToken cancelToken = CancelToken();

      final url = "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_vod_streams&category_id=$catId";

      final response = await dio.get(url,
          cancelToken: cancelToken);

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data ?? "[]";

        final list = json.map((e) => ChannelMovie.fromJson(e)).toList();

        return list;
      }

      return [];
    } catch (e) {

      return [];
    }
  }

  Future<List<ChannelMovie>> getThumbsMovies(String catId) async {
    try {

      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      CancelToken cancelToken = CancelToken();

      final url = "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_vod_streams&category_id=$catId";

      final response = await dio.get(url, cancelToken: cancelToken);

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data ?? "[]";

        final list = json.map((e) => ChannelMovie.fromJson(e)).take(10).toList();

        return list;
      }

      return [];
    } catch (e) {

      return [];
    }
  }

  /// Channels Series

  Future<List<ChannelSerie>> getSerieChannels(String catId) async {
    try {

      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      CancelToken cancelToken = CancelToken();

      final url = "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_series&category_id=$catId";

      final response = await dio.get(url, cancelToken: cancelToken);

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data ?? "[]";

        final list = json.map((e) => ChannelSerie.fromJson(e)).toList();

        return list;
      }

      return [];
    } catch (e) {

      return [];
    }
  }

  Future<List<ChannelSerie>> getThumbsSeries(String catId) async {
    try {

      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      CancelToken cancelToken = CancelToken();

      final url = "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_series&category_id=$catId";

      final response = await dio.get(url, cancelToken: cancelToken);

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data ?? "[]";

        final list = json.map((e) => ChannelSerie.fromJson(e)).take(10).toList();

        return list;
      }

      return [];
    } catch (e) {

      return [];
    }
  }

  /// Movie Detail
  /*static Future<MovieDetail?> getMovieDetails(String movieId) async {
    try {


      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final data = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      final url = "${data['playlistLink']}/player_api.php?username=${data['username']}&password=${data['password']}&action=get_vod_info&vod_id=$movieId";

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        // log(response.data.toString());
        final json = response.data ?? "[]";

        final movie = MovieDetail.fromJson(json);

        return movie;
      }

      return null;
    } catch (e) {
      return null;
    }
  }*/

  /// Serie Detail
  /*static Future<SerieDetails?> getSerieDetails(String serieId) async {
    try {

      final playlistsBox = Hive.box('playlists_box');
      final defaultPlaylist = Hive.box('default_playlist');

      final playList = await playlistsBox.get(defaultPlaylist.get('default'));

      final dio = Dio();

      final url =
          "${playList['playlistLink']}/player_api.php?username=${playList['username']}&password=${playList['password']}&action=get_series_info&series_id=$serieId";



      final response = await dio.get(url);

      if (response.statusCode == 200) {
        //log(response.data.toString());
        final json = jsonDecode(response.data ?? "");
        final serie = SerieDetails.fromJson(json);
        return serie;
      }

      return null;
    } catch (e) {
      return null;
    }
  }*/

  /// EPG LIVE
  /*static Future<List<EpgModel>> getEPGbyStreamId(String streamId) async {
    try {
      final user = await LocaleApi.getUser();

      if (user == null) {
        debugPrint("User is Null");
        return [];
      }

      var url = "${user.serverInfo!.serverUrl}/player_api.php";

      Response<String> response = await _dio.get(
        url,
        queryParameters: {
          "password": user.userInfo!.password,
          "username": user.userInfo!.username,
          "action": "get_short_epg",
          "stream_id": streamId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> json =
        jsonDecode(response.data ?? "")['epg_listings'];
        debugPrint("EPG length: ${json.length}");

        final list = json.map((e) => EpgModel.fromJson(e)).toList();
        return list;
      }

      return [];
    } catch (e) {
      debugPrint("Error EPG Series $streamId: $e");
      return [];
    }
  }*/


  /// Get MOVIE CASTS
  Future<List<MovieCasts>> getMovieCasts(String movieId, String type) async {

    try {
      final dio = Dio();
      CancelToken cancelToken = CancelToken();

      final url = "$tmdbBaseLink/$type/$movieId/$tmdbEndLink";


      final response = await dio.get(url, cancelToken: cancelToken);

      if (response.statusCode == 200) {
        final List<dynamic> json = response.data['cast'] ?? "[]";
        final list = json.map((e) => MovieCasts.fromJson(e)).take(6).toList();
        return list;
      }

      return [];
    } catch (e) {

      return [];
    }
  }

}
