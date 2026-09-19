import 'dart:convert';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String cacheKey = 'cached_posts';

  Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> jsonList = posts
        .map((post) => post.toJson())
        .toList();

    String jsonString = json.encode(jsonList);

    await prefs.setString(cacheKey, jsonString);
  }

  Future<List<Post>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString(cacheKey);

    if (jsonString == null) {
      return [];
    }

    List<dynamic> jsonList = json.decode(jsonString);

    List<Post> posts = jsonList.map((item) => Post.fromJson(item)).toList();

    return posts;
  }
}
