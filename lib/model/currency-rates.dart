class Currency {
  final String code;
  final String name;

  Currency({
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code ($name)';
}

class CurrencyRates {
  final Currency base;
  final List<Rate> rates;

  CurrencyRates({
    required this.base,
    required this.rates,
  });

  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('base') || !json.containsKey('rates')) {
      throw FormatException('Invalid JSON format: missing required fields');
    }

    final baseCurrency = json['base'] as String;
    final rates = json['rates'];
    
    if (rates is! Map<String, dynamic>) {
      throw FormatException('Invalid rates format');
    }

    return CurrencyRates(
      base: Currency(code: baseCurrency, name: _getCurrencyName(baseCurrency)),
      rates: _parseRates(rates, baseCurrency),
    );
  }

  Rate? findRate(String currencyCode) {
    return rates.cast<Rate?>().firstWhere(
          (rate) => rate?.currency.code == currencyCode,
          orElse: () => null,
        );
  }
}

class HistoricalRates {
  final DateTime date;
  final double rate;

  HistoricalRates({
    required this.date,
    required this.rate,
  });
}

class Rate {
  final Currency currency;
  final double rate;

  Rate({
    required this.currency,
    required this.rate,
  });

  @override
  String toString() => '${currency.code}: $rate';
}

List<Rate> _parseRates(Map<String, dynamic> ratesMap, String baseCurrencyCode) {
  return ratesMap.entries
      .where((entry) => entry.key != baseCurrencyCode)
      .map((entry) {
        final value = entry.value;
        if (value is! num) {
          throw FormatException('Invalid rate value for ${entry.key}');
        }
        return Rate(currency: Currency(code: entry.key, name: _getCurrencyName(entry.key)), rate: value.toDouble());
      })
      .toList()
    ..sort((a, b) => a.currency.code.compareTo(b.currency.code));
}

String _getCurrencyName(String code) {
  const Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'SYP': 'Syrian Pound',
    'LBP': 'Lebanese Pound',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'TRY': 'Turkish Lira',
  };
  return currencyNames[code] ?? code;
}
