import 'package:fl_chart/fl_chart.dart';
import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyHistoryGraph extends StatefulWidget {
  final String originCurrencyCode;
  final String destinationCurrencyCode;
  final DateTime startDate;
  final DateTime endDate;

  const CurrencyHistoryGraph({
    super.key,
    required this.originCurrencyCode,
    required this.destinationCurrencyCode,
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
    _bloc.fetchRatesHistory(
      widget.originCurrencyCode,
      widget.destinationCurrencyCode,
      widget.startDate,
      widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Response<HistoricalRates>>(
      stream: _bloc.historyRatesStream,
      builder: (context, AsyncSnapshot<Response<HistoricalRates>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final response = snapshot.data!;
        switch (response.status) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.COMPLETED:
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: _buildHistoryChart(response.data!),
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

  Widget _buildHistoryChart(HistoricalRates historicalRates) {
    final spots = historicalRates.rates.map((point) {
      final rate = point.findRate(widget.destinationCurrencyCode);
      return FlSpot(
        point.date.millisecondsSinceEpoch.toDouble(),
        rate?.rate ?? 0.0,
      );
    }).toList();

    return Column(
      children: [
        Text(
          '${widget.originCurrencyCode}/${widget.destinationCurrencyCode} Exchange Rate',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MMM d').format(date),
                          style: const TextStyle(fontSize: 10),
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
              borderData: FlBorderData(show: true),
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
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.white.withOpacity(0.8),
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        touchedSpot.x.toInt(),
                      );
                      return LineTooltipItem(
                        '${DateFormat('MMM d, yyyy').format(date)}\n${touchedSpot.y.toStringAsFixed(4)}',
                        const TextStyle(color: Colors.black),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
