import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';
}

class ApiService {
  final String baseUrl;
  final http.Client _httpClient;
  final Logger _logger;

  ApiService({required this.baseUrl, http.Client? httpClient, Logger? logger})
      : _logger = logger ?? Logger(),
        _httpClient = http.Client();

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _httpClient.get(Uri.parse('$baseUrl$endpoint'));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      _logger.e('Network error occurred', error: e);
      throw ApiException('Network error occurred: ${e.message}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      _logger.e(
        'API error',
        time: DateTime.now(),
        error: 'Status Code: ${response.statusCode}, Body: ${response.body}',
      );
      throw ApiException('API request failed', statusCode: response.statusCode);
    }
  }
}

@riverpod
ApiService apiService(ApiServiceRef ref) {
  return ApiService(baseUrl: 'iptv-org.github.io');
}
