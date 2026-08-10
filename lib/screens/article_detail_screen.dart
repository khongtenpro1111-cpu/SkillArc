import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00D2FF) : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                article['category'],
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Title
            Text(
              article['title'],
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withValues(alpha: 0.2),
                  child: Text(
                    article['author'][0],
                    style: TextStyle(color: accentColor),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['author'],
                      style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${article['readTime']} đọc • 2 ngày trước',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Placeholder Image
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=1000&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                  opacity: isDark ? 0.5 : 0.9,
                ),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 30),
            
            // Content
            Text(
              'Đây là nội dung chi tiết của bài viết "${article['title']}".\n\n'
              'Trong bài viết này, chúng ta sẽ tìm hiểu sâu về các khái niệm quan trọng trong ${article['category']}. '
              'Nội dung bao gồm các kiến thức từ cơ bản đến nâng cao, giúp bạn làm chủ kỹ năng này một cách nhanh chóng.\n\n'
              '1. Giới thiệu tổng quan\n'
              'Nội dung phần giới thiệu sẽ giúp bạn hiểu rõ lý do tại sao ${article['category']} lại quan trọng trong năm 2024.\n\n'
              '2. Các bước thực hiện\n'
              'Chúng ta sẽ đi qua từng bước cụ thể để áp dụng kiến thức vào thực tế.\n\n'
              '3. Kết luận\n'
              'Tóm tắt các điểm chính và lộ trình học tập tiếp theo cho bạn.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 16,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bottom Action
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
              ),
              child: Column(
                children: [
                  Text(
                    'Bạn thấy bài viết này hữu ích?',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(Icons.thumb_up_off_alt, 'Thích', isDark, theme),
                      const SizedBox(width: 20),
                      _buildActionButton(Icons.comment_outlined, 'Bình luận', isDark, theme),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.primary.withValues(alpha: 0.05),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
