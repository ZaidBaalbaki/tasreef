import 'package:easy_exchange/model/currency-rates.dart';
import 'package:flutter/material.dart';

class CurrencyButton extends StatelessWidget {
  final String currencyCode;
  final VoidCallback onPressed;

  const CurrencyButton({
    super.key,
    required this.currencyCode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currency = Currency(
      code: currencyCode,
      name: _getCurrencyName(currencyCode),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        currency.code,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getCurrencyName(String code) {
    const names = {
      'USD': 'US Dollar',
      'SYP': 'Syrian Pound',
      'LBP': 'Lebanese Pound',
      'AED': 'UAE Dirham',
      'SAR': 'Saudi Riyal',
      'TRY': 'Turkish Lira',
    };
    return names[code] ?? code;
  }
}
