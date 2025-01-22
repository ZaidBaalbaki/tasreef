import 'package:easy_exchange/services/networking/custom-exception.dart';
import 'package:easy_exchange/util/url.dart';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class ApiProvider {
  final String _baseUrl = Url.exchangeBaseUrl;
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final uri = Uri.parse(_baseUrl + url);
      final response = await _client.get(uri);
      return _handleResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on FormatException {
      throw FetchDataException('Invalid response format');
    } catch (e) {
      throw FetchDataException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final responseJson = json.decode(response.body) as Map<String, dynamic>;
        return responseJson;
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 404:
        throw NotFoundException(response.body);
      case 500:
        throw ServerException(response.body);
      default:
        throw FetchDataException(
          'Error occurred while communicating with server. Status code: ${response.statusCode}',
        );
    }
  }

  void dispose() {
    _client.close();
  }
}