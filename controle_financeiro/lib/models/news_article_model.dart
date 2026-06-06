/// Modelo tipado para artigos de notícias financeiras da API.
class NewsArticle {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? url;
  final String source;
  final DateTime? publishedAt;

  NewsArticle({
    required this.title,
    this.description,
    this.imageUrl,
    this.url,
    required this.source,
    this.publishedAt,
  });

  /// Factory para converter JSON da API em modelo tipado.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Sem título',
      description: json['description'],
      imageUrl: json['urlToImage'],
      url: json['url'],
      source: json['source']?['name'] ?? 'Desconhecido',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': imageUrl,
      'url': url,
      'source': {'name': source},
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }
}
