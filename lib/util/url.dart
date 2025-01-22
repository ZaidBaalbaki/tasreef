class Url {
  // Using the free Exchange Rate API
  static const String exchangeBaseUrl = 'https://open.er-api.com/v6/';
  
  static String getLatestRatesUrl([String? baseCurrency]) {
    return 'latest/${baseCurrency ?? "USD"}';
  }
  
  static String getHistoricalRatesUrl(String date, [String? baseCurrency]) {
    return '$date/${baseCurrency ?? "USD"}';
  }
}