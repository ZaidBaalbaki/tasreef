import 'dart:convert';
import 'dart:io';
import 'package:easy_exchange/services/exceptions.dart';
import 'package:easy_exchange/util/url.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('Fetching data from: $endpoint'); // Debug log
      final response = await _client.get(Uri.parse(endpoint));
      return _handleResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      print('Error during API call: $e'); // Debug log
      throw FetchDataException('Error occurred: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response status code: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log
    
    switch (response.statusCode) {
      case 200:
        try {
          final Map<String, dynamic>? decodedJson = json.decode(response.body) as Map<String, dynamic>?;
          if (decodedJson == null) {
            throw FetchDataException('Response body is null');
          }
          if (!decodedJson.containsKey('rates')) {
            throw FetchDataException('Response missing rates data');
          }
          return decodedJson;
        } catch (e) {
          print('Error parsing response: $e'); // Debug log
          throw FetchDataException('Invalid response format: $e');
        }
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 404:
        throw NotFoundException(response.body);
      case 500:
      default:
        throw ServerException('Server error: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}