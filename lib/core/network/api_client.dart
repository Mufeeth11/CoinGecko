import 'dart:async';
import 'dart:convert';

import 'package:coingecko_mini/core/config/api_config.dart';
import 'package:coingecko_mini/core/error/exception.dart';
import 'package:http/http.dart' as http;

/// Thin, testable HTTP wrapper. It only knows about transport and JSON
/// decoding; endpoint semantics belong in the data sources.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final decoded = await _get(path, queryParameters: queryParameters);
    if (decoded is! Map) {
      throw const ParsingException('Expected a JSON object from the API.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final decoded = await _get(path, queryParameters: queryParameters);
    if (decoded is! List) {
      throw const ParsingException('Expected a JSON list from the API.');
    }
    return List<dynamic>.from(decoded);
  }

  String? _workingBaseUrl;

  Future<dynamic> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final candidateBases = _workingBaseUrl != null
        ? [_workingBaseUrl!]
        : ApiConfig.candidateBaseUrls;

    http.Response? response;
    Exception? lastException;

    for (final base in candidateBases) {
      final uri = Uri.parse('$base$path').replace(
        queryParameters: queryParameters == null || queryParameters.isEmpty
            ? null
            : queryParameters,
      );

      try {
        response = await _client.get(uri).timeout(ApiConfig.requestTimeout);
        _workingBaseUrl = base;
        break;
      } on TimeoutException catch (e) {
        lastException = e;
      } on http.ClientException catch (e) {
        lastException = e;
      }
    }

    if (response == null) {
      if (lastException is TimeoutException) {
        throw const ConnectionException(
          'The server took too long to respond. Please try again.',
        );
      }
      throw const ConnectionException(
        'Could not reach the market server. Check your connection and start the backend.',
      );
    }

    if (response.statusCode == 404) {
      throw ServerException(
        'The requested resource was not found.',
        statusCode: 404,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(
        'Market server returned ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ParsingException('The API returned malformed JSON.');
    }
  }
}
