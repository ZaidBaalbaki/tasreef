class Url {
  static const String _baseUrl = 'https://open.er-api.com/v6';

  static String getLatestRatesUrl([String base = 'USD']) {
    return '$_baseUrl/latest/$base';
  }

  static String getHistoricalRatesUrl(String date, [String base = 'USD']) {
    return '$_baseUrl/$date/$base';
  }

  static String getConvertUrl(String from, String to, String date) {
    return '$_baseUrl/convert/$from/$to/$date';
  }
}