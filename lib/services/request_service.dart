
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class RequestService {
  Future<Map<String, dynamic>> acceptRequest({
    required String requestId,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.requestsEndpoint}/$requestId/accept',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'waiterId': ApiConfig.waiterId,
          'waiterName': ApiConfig.waiterName,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response from the server.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          decoded['message'] ??
              decoded['error'] ??
              'Could not accept request (${response.statusCode}).',
        );
      }

      return decoded;
    } catch (error) {
      debugPrint('Accept request error: $error');
      rethrow;
    }
  }
}
