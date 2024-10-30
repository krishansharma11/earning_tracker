import 'dart:convert';
import 'package:earning_tracker/screens/EarningsChartScreen.dart';
import 'package:earning_tracker/utiliti/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EarningsScreen extends StatefulWidget {
  final String ticker;

  EarningsScreen({required this.ticker});

  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  List<Map<String, dynamic>>? earningsData;
  @override
  void initState() {
    super.initState();
    fetchEarningsData(widget.ticker);
  }

  Future<void> fetchEarningsData(String ticker) async {
    final apiUrl =
        'https://api.api-ninjas.com/v1/earningscalendar?ticker=$ticker';
    final headers = {
      'X-Api-Key': Constant.apiKey,
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          earningsData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        print("earning data : >>>>>>>>$earningsData");
      } else {
        setState(() {
          earningsData = [
            {'error': 'Error ${response.statusCode}: ${response.body}'}
          ];
        });
      }
    } catch (e) {
      setState(() {
        earningsData = [
          {'error': 'Failed to fetch data: $e'}
        ];
      });
    }
  }

  void navigateToChartScreen() {
    if (earningsData != null && earningsData!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EarningsChartScreen(
            ticker: widget.ticker,
            earningsData: earningsData!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No earnings data available.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Earnings for ${widget.ticker}')),
      body: earningsData == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: earningsData!.length,
              itemBuilder: (context, index) {
                final earnings = earningsData![index];

                if (earnings['error'] != null) {
                  return ListTile(
                    title: Text(earnings['error']),
                  );
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Date: ${earnings['pricedate']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimated EPS: ${earnings['estimated_eps']}'),
                        Text(
                            'Actual EPS: ${earnings['actual_eps'] ?? "Not reported"}'),
                        Text(
                            'Estimated Revenue: ${earnings['estimated_revenue']}'),
                        Text(
                            'Actual Revenue: ${earnings['actual_revenue'] ?? "Not reported"}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.show_chart),
                      onPressed: navigateToChartScreen,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
