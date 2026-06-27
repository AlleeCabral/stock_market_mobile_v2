class NewsArticle {
  final String title;
  final String source;
  final String publishedAt;
  final String imageUrl;
  final String url;

  const NewsArticle({
    required this.title,
    required this.source,
    required this.publishedAt,
    required this.imageUrl,
    required this.url,
  });

  factory NewsArticle.fromNewsDataJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title available',
      source: json['source_name'] ?? json['source_id'] ?? 'Unknown source',
      publishedAt: json['pubDate'] ?? '',
      imageUrl: json['image_url'] ?? '',
      url: json['link'] ?? '',
    );
  }
}