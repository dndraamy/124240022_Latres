// Service API Rick and Morty

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../models/episode_model.dart';

class Info {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  Info({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      count: (json['count'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }
}

class CharacterResponse {
  final Info info;
  final List<Character> results;

  CharacterResponse({
    required this.info,
    required this.results,
  });

  factory CharacterResponse.fromJson(Map<String, dynamic> json) {
    return CharacterResponse(
      info: Info.fromJson(json['info'] ?? {}),
      results: (json['results'] as List? ?? [])
          .map((e) => Character.fromJson(e))
          .toList(),
    );
  }

  // Getters kompatibilitas penuh (bisa diakses via .results maupun .characters)
  List<Character> get characters => results;
  int get totalCount => info.count;
  int get totalPages => info.pages;
  bool get hasNext => info.next != null;
}

class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  // Instance method agar bisa dipanggil via _apiService.getCharacters(...)
  Future<CharacterResponse> getCharacters({
    int page = 1,
    String? status, // 'alive', 'dead', 'unknown'
    String? name,
  }) async {
    List<String> queryParams = ['page=$page'];
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams.add('status=${status.toLowerCase()}');
    }
    if (name != null && name.trim().isNotEmpty) {
      queryParams.add('name=${Uri.encodeComponent(name.trim())}');
    }

    String url = '$_baseUrl/character?${queryParams.join('&')}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CharacterResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      return CharacterResponse(
        info: Info(count: 0, pages: 0),
        results: [],
      );
    } else {
      throw Exception('Gagal memuat data karakter (${response.statusCode})');
    }
  }

  // Detail satu karakter berdasarkan ID
  Future<Character> getCharacterDetail(int id) => getCharacterById(id);
  static Future<Character> getCharacterById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/character/$id'));

    if (response.statusCode == 200) {
      return Character.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail karakter ($id)');
    }
  }

  // Ambil list episode
  Future<List<Episode>> getEpisodesList() => getEpisodes();
  static Future<List<Episode>> getEpisodes() async {
    List<Episode> allEpisodes = [];
    String? nextUrl = '$_baseUrl/episode';

    while (nextUrl != null) {
      final response = await http.get(Uri.parse(nextUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        allEpisodes.addAll(results.map((e) => Episode.fromJson(e)));
        final info = data['info'];
        nextUrl = info != null ? info['next'] as String? : null;
      } else {
        throw Exception('Gagal memuat daftar episode (${response.statusCode})');
      }
    }

    return allEpisodes;
  }
}
