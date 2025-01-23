import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String currencyCode;
  final bool autofocus;
  final bool readOnly;
  final Function(String) onChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.currencyCode,
    required this.onChanged,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        suffixText: currencyCode,
        suffixStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('-')),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: onChanged,
    );
  }
}