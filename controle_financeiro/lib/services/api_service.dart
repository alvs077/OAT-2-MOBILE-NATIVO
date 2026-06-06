import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';

/// Exceção personalizada para erros de rede.
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

/// Exceção personalizada para erros da API.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Serviço de API para buscar notícias financeiras.
/// Implementa cache em memória e tratamento de erros robusto.
class ApiService {
  // API de notícias de negócios
  final String _baseUrl =
      'https://newsapi.org/v2/top-headlines?category=business&language=pt&apiKey=62b1e17d984c4a45a6c117833a693991';

  // Cache em memória para evitar requisições repetidas
  List<NewsArticle>? _cachedNews;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 15);

  /// Busca notícias financeiras da API com cache e tratamento de erros.
  Future<List<NewsArticle>> fetchNews({bool forceRefresh = false}) async {
    // Retorna cache se ainda válido
    if (!forceRefresh &&
        _cachedNews != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedNews!;
    }

    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List<dynamic>?)
                ?.where((a) => a['title'] != null && a['title'] != '[Removed]')
                .map((a) => NewsArticle.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [];

        // Atualiza cache
        _cachedNews = articles;
        _lastFetch = DateTime.now();

        return articles;
      } else if (response.statusCode == 429) {
        throw ApiException(429, 'Limite de requisições excedido. Tente novamente mais tarde.');
      } else {
        throw ApiException(response.statusCode, 'Erro ao carregar notícias');
      }
    } on TimeoutException {
      throw NetworkException('Tempo de conexão esgotado. Verifique sua internet.');
    } on http.ClientException {
      throw NetworkException('Sem conexão com a internet.');
    } catch (e) {
      if (e is NetworkException || e is ApiException) rethrow;
      throw NetworkException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Limpa o cache de notícias.
  void clearCache() {
    _cachedNews = null;
    _lastFetch = null;
  }
}