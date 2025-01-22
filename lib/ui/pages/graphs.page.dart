import 'package:easy_exchange/ui/widget/currency-button.widget.dart';
import 'package:easy_exchange/ui/widget/currency-history-graph.widget.dart';
import 'package:flutter/material.dart';

class GraphsPage extends StatefulWidget {
  const GraphsPage({super.key});

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  String _originCurrencyCode = 'USD';
  String _destinationCurrencyCode = 'EUR';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = '1M';

  void _updatePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case '1W':
          _startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '1M':
          _startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '3M':
          _startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        case '6M':
          _startDate = DateTime.now().subtract(const Duration(days: 180));
          break;
        case '1Y':
          _startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
      }
      _endDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CurrencyButton(
                currencyCode: _originCurrencyCode,
                onPressed: () async {
                  // TODO: Implement currency selection
                },
              ),
              const Icon(Icons.compare_arrows),
              CurrencyButton(
                currencyCode: _destinationCurrencyCode,
                onPressed: () async {
                  // TODO: Implement currency selection
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['1W', '1M', '3M', '6M', '1Y'].map((period) {
                final isSelected = period == _selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => _updatePeriod(period),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Theme.of(context).primaryColor,
                      elevation: isSelected ? 2 : 1,
                    ),
                    child: Text(period),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CurrencyHistoryGraph(
              originCurrencyCode: _originCurrencyCode,
              destinationCurrencyCode: _destinationCurrencyCode,
              startDate: _startDate,
              endDate: _endDate,
            ),
          ),
        ],
      ),
    );
  }
}
