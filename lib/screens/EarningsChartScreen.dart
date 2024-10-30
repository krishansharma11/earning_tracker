import 'dart:convert';
import 'package:earning_tracker/screens/TranscriptScreen.dart';
import 'package:earning_tracker/utiliti/constant.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class EarningsChartScreen extends StatelessWidget {
  final String ticker;
  final List<Map<String, dynamic>> earningsData;

  EarningsChartScreen({required this.ticker, required this.earningsData});

  Future<String> fetchEarningsTranscript(String date) async {
    final apiUrl =
        'https://api.api-ninjas.com/v1/earningscalltranscript?date=$date&ticker=$ticker';
    final headers = {
      'X-Api-Key': Constant.apiKey,
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['transcript'] ?? "No transcript available.";
    } else {
      return "Error fetching transcript: ${response.statusCode}";
    }
  }

  void onDataPointClick(BuildContext context, String ticker, String pricedate) {
    final DateTime dateTime = DateTime.parse(pricedate);
    final int quarter = (dateTime.month - 1) ~/ 3 + 1;
    final int year = dateTime.year;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TranscriptScreen(ticker: ticker, quarter: quarter, year: year),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Earnings Chart for $ticker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      earningsData[value.toInt()]['pricedate'],
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: earningsData
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(entry.key.toDouble(),
                        entry.value['estimated_eps'] ?? 0.0))
                    .toList(),
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                belowBarData: BarAreaData(show: false),
                dotData:
                    FlDotData(show: true, checkToShowDot: (spot, _) => true),
              ),
              LineChartBarData(
                spots: earningsData
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(
                        entry.key.toDouble(), entry.value['actual_eps'] ?? 0.0))
                    .toList(),
                isCurved: true,
                barWidth: 2,
                color: Colors.green,
                belowBarData: BarAreaData(show: false),
                dotData:
                    FlDotData(show: true, checkToShowDot: (spot, _) => true),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: const LineTouchTooltipData(),
              handleBuiltInTouches: true,
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse? touchResponse) {
                if (touchResponse != null &&
                    touchResponse.lineBarSpots != null &&
                    touchResponse.lineBarSpots!.isNotEmpty) {
                  final index = touchResponse.lineBarSpots!.first.spotIndex;
                  onDataPointClick(
                      context, ticker, earningsData[index]['pricedate']);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
