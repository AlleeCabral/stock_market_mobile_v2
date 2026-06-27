import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_article.dart';
import '../services/news_service.dart';
import '../theme/app_theme.dart';

class NewsCard extends StatefulWidget {
  const NewsCard({super.key});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService().fetchMarketNews();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'News',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              if (snapshot.connectionState == ConnectionState.waiting)
                const _NewsStatusMessage(
                  message: 'Loading latest market news...',
                )
              else if (snapshot.hasError)
                const _NewsStatusMessage(
                  message: 'Unable to load market news right now.',
                )
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                  const _NewsStatusMessage(
                    message: 'No market news available right now. Check back later.',
                  )
                else
                  ...snapshot.data!.map(
                        (article) => _HeadlineItem(article: article),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _HeadlineItem extends StatelessWidget {
  final NewsArticle article;

  const _HeadlineItem({
    required this.article,
  });

  Future<void> _openArticle(BuildContext context) async {
    final Uri uri = Uri.parse(article.url);

    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open article'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openArticle(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColorLighter,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            if (article.imageUrl.isNotEmpty) ...[
              const SizedBox(width: 10),
              _Thumbnail(imageUrl: article.imageUrl),
            ],
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String imageUrl;

  const _Thumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 52,
        height: 52,
        color: AppTheme.chipColor,
        child: imageUrl.isEmpty
            ? const Icon(Icons.article_outlined, color: AppTheme.secondaryTextColor)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppTheme.secondaryTextColor,
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _NewsStatusMessage extends StatelessWidget {
  final String message;

  const _NewsStatusMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: AppTheme.textColor.withValues(alpha: 0.75),
        fontSize: 14,
      ),
    );
  }
}
