import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/post.dart';

class PostProvider extends ChangeNotifier {
  List<Post> postList = [];
  bool isLoading = true;
  String? errorMessage;
  bool isShowingCachedData = false;
  final CacheService _cacheService = CacheService();

  Future<void> loadPosts() async {
    isLoading = true;
    isShowingCachedData = false;
    errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      List<Post> posts = await apiService.fetchApi();

      postList = posts;
      isLoading = false;
      isShowingCachedData = false;
      notifyListeners();

      await _cacheService.savePosts(posts);
    } catch (e) {
      List<Post> cachedPosts = await _cacheService.loadPosts();

      if (cachedPosts.isNotEmpty) {
        postList = cachedPosts;
        isLoading = false;
        isShowingCachedData = true;
        errorMessage = null;
        notifyListeners();
      } else {
        errorMessage = e.toString();
        isLoading = false;
        isShowingCachedData = false;
        notifyListeners();
      }
    }
  }
}
