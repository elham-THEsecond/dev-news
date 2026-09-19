import 'package:dev_news/providers/post_provider.dart';
import 'package:dev_news/utils/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:dev_news/widgets/particle_sphere.dart';
import 'package:dev_news/screens/post_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PostProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          title: Center(
            child: Text(
              'Dev News',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 800),
          child: provider.isLoading
              ? Container(
                  key: ValueKey('loading'),
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ParticleSphere(
                          configPath: 'assets/particle_sphere.json',
                          width: 300,
                          height: 300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Fetching from the server...',
                          style: TextStyle(
                            color: Color(0xFFD0D0D0),
                            fontSize: 16,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : provider.errorMessage != null
              ? Container(
                  key: ValueKey('error'),
                  color: Colors.black,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'The server is on vacation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            provider.errorMessage!,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: provider.loadPosts,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  key: ValueKey('list'),
                  children: [
                    // ── Offline banner (only shows when using cache) ──
                    if (provider.isShowingCachedData)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: Color(0xFF2A2A1A),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 18,
                              color: Colors.amber[300],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "You're offline ",
                                style: TextStyle(
                                  color: Colors.amber[300],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── The list itself ──
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.loadPosts(),
                        color: Color(0xFFD0D0D0),
                        backgroundColor: Color(0xFF1A1A1A),
                        strokeWidth: 2.0,
                        displacement: 40,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: provider.postList.length,
                          itemBuilder: (context, index) {
                            final post = provider.postList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostDetailScreen(post: post),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.06),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      post.description,

                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (post.createdAt != null) ...[
                                      SizedBox(height: 8),
                                      Text(
                                        timeAgo(post.createdAt!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
