import 'package:fl_chart/fl_chart.dart';
import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyHistoryGraph extends StatefulWidget {
  final String originCurrency;
  final String destinationCurrency;
  final DateTime startDate;
  final DateTime endDate;

  const CurrencyHistoryGraph({
    super.key,
    required this.originCurrency,
    required this.destinationCurrency,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CurrencyHistoryGraph> createState() => _CurrencyHistoryGraphState();
}

class _CurrencyHistoryGraphState extends State<CurrencyHistoryGraph> {
  final CurrencyRatesListBloc _bloc = CurrencyRatesListBloc();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    _bloc.fetchRatesHistory(
      widget.originCurrency,
      widget.destinationCurrency,
      widget.startDate,
      widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Response<List<HistoricalRates>>>(
      stream: _bloc.historyRatesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final response = snapshot.data!;
        switch (response.status) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.COMPLETED:
            final historicalRates = response.data!;
            if (historicalRates.isEmpty) {
              return const Center(
                child: Text(
                  'No historical data available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            final spots = historicalRates.map((point) {
              return FlSpot(
                point.date.millisecondsSinceEpoch.toDouble(),
                point.rate,
              );
            }).toList();

            return SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM d').format(date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          case Status.ERROR:
            return Center(
              child: Text(
                'Error: ${response.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
