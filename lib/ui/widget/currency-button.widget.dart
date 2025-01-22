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
    final currency = Currency(currencyCode);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency.code,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
