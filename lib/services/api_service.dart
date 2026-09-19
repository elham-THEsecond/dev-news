import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dev_news/models/post.dart';

class ApiService {
  static const String baseUrl = "https://lobste.rs";
  Future<List<Post>> fetchApi() async {
    final response = await http
        .get(Uri.parse('$baseUrl/newest.json'))
        .timeout(Duration(seconds: 15));
    print("🟢 Status: ${response.statusCode}");
    print("🟢 Response length: ${response.body.length}");

    if (response.statusCode == 200) {
      // Lobste.rs returns a flat JSON array — same as Dev.to
      List<dynamic> jsonData = json.decode(response.body);
      List<Post> posts = jsonData.map((item) {
        return Post.fromJson(item);
      }).toList();

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
