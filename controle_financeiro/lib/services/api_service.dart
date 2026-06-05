import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Usando uma API pública de notícias financeiras
  final String _url = 'https://newsapi.org/v2/top-headlines?category=business&language=pt&apiKey=62b1e17d984c4a45a6c117833a693991';

  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        return json.decode(response.body)['articles'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}