import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';
import '../utils/time_ago.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  Future<void> _openArticle() async {
    if (post.url.isEmpty) {
      print("🔴 URL is empty");
      return;
    }

    print("🔵 Attempting to open: ${post.url}");
    final uri = Uri.parse(post.url);

    final canLaunch = await canLaunchUrl(uri);
    print("🟡 canLaunchUrl: $canLaunch");

    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print("🟢 Launched");
    } else {
      print("🔴 Cannot launch URL");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              post.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.25,
              ),
            ),
            SizedBox(height: 16),

            // Meta info
            Row(
              children: [
                if (post.createdAt != null) ...[
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    timeAgo(post.createdAt!),
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  SizedBox(width: 12),
                ],
                Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  post.authorName,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(height: 24),

            Divider(color: Colors.white.withOpacity(0.08)),
            SizedBox(height: 24),

            // Description
            Text(
              post.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
                height: 1.6,
              ),
            ),
            SizedBox(height: 24),

            // Tags
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 40),

            // Read Full Article button
            if (post.url.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openArticle,
                  icon: Icon(Icons.open_in_new, size: 18),
                  label: Text('Read Full Article'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
