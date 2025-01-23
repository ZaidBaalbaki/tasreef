class Currency {
  final String code;
  final String name;

  Currency(this.code) : name = _getCurrencyName(code);

  static String _getCurrencyName(String code) {
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
  final Currency baseCurrency;
  final List<Rate> rates;

  CurrencyRates(this.baseCurrency, this.rates);

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
      Currency(baseCurrency),
      _parseRates(rates, baseCurrency),
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
  final Currency baseCurrency;
  final List<HistoryRatePoint> rates;

  HistoricalRates(this.baseCurrency, this.rates);

  List<HistoryRatePoint> getRatesForCurrency(String currencyCode) {
    return rates.where((point) => 
      point.rates.any((rate) => rate.currency.code == currencyCode)
    ).toList();
  }
}

class HistoryRatePoint {
  final DateTime date;
  final List<Rate> rates;

  HistoryRatePoint(this.date, this.rates);

  Rate? findRate(String currencyCode) {
    return rates.cast<Rate?>().firstWhere(
          (rate) => rate?.currency.code == currencyCode,
          orElse: () => null,
        );
  }
}

class Rate {
  final Currency currency;
  final double rate;

  Rate(this.currency, this.rate);

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
        return Rate(Currency(entry.key), value.toDouble());
      })
      .toList()
    ..sort((a, b) => a.currency.code.compareTo(b.currency.code));
}
