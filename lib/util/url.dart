class Url {
  // Using the free Frankfurter API
  static const String exchangeBaseUrl = 'https://api.frankfurter.app/';
  
  static String getLatestRatesUrl([String? baseCurrency]) {
    return 'latest?from=${baseCurrency ?? "USD"}';
  }
  
  static String getHistoricalRatesUrl(String date, [String? baseCurrency]) {
    return '$date?from=${baseCurrency ?? "USD"}';
  }
}