import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_article.dart';

class NewsService {
  static const String _newsDataApiKey =
      "pub_f63e015c14ae4c019531dddf1771fc23";

  Future<List<NewsArticle>> fetchMarketNews() async {
    if (_newsDataApiKey.isEmpty) {
      throw Exception('Missing NewsData.io API key');
    }

    final Uri url = Uri.parse(
      'https://newsdata.io/api/1/latest'
          '?apikey=$_newsDataApiKey'
          '&country=de'
          '&language=en'
          '&category=business,technology'
          '&video=0',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load news. Status code: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception('NewsData API returned an error');
    }

    final List results = data['results'] ?? [];

    return results
        .map((article) => NewsArticle.fromNewsDataJson(article))
        .where(
          (article) =>
      article.title.isNotEmpty &&
          article.title != 'No title available' &&
          article.url.isNotEmpty,
    )
        .take(3)
        .toList();
  }

  /// Takes just the first word of the company name for a focused query.
  /// "Apple Inc." → "Apple", "NVIDIA Corp." → "NVIDIA", etc.
  static String _buildCompanyQuery(String companyName, String symbol) {
    final firstWord = companyName.trim().split(' ').first;
    return firstWord;
  }

  Future<List<NewsArticle>> fetchCompanyNews(String companyName, String symbol) async {
    if (_newsDataApiKey.isEmpty) {
      throw Exception('Missing NewsData.io API key');
    }

    final String query = _buildCompanyQuery(companyName, symbol);

    final Uri url = Uri.parse(
      'https://newsdata.io/api/1/latest'
          '?apikey=$_newsDataApiKey'
          '&language=en'
          '&qInTitle=${Uri.encodeComponent(query)}'
          '&category=business,technology'
          '&video=0',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load news. Status code: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception('NewsData API returned an error');
    }

    final List results = data['results'] ?? [];

    return results
        .map((article) => NewsArticle.fromNewsDataJson(article))
        .where(
          (article) =>
      article.title.isNotEmpty &&
          article.title != 'No title available' &&
          article.url.isNotEmpty,
    )
        .take(3)
        .toList();
  }
}