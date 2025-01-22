import 'package:easy_exchange/ui/widget/currency-rates-list.widget.dart';
import 'package:flutter/material.dart';

typedef CurrencyCallback = void Function(String code, double? rate);

class CurrenciesBottomSheet extends StatefulWidget {
  final String baseCurrency;
  final CurrencyCallback onCurrencySelected;

  const CurrenciesBottomSheet({
    super.key,
    required this.baseCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<CurrenciesBottomSheet> createState() => _CurrenciesBottomSheetState();
}

class _CurrenciesBottomSheetState extends State<CurrenciesBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select a currency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search currency...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: CurrencyRateList(
                  baseCurrency: widget.baseCurrency,
                  onCurrencySelected: widget.onCurrencySelected,
                  searchQuery: _searchQuery,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
