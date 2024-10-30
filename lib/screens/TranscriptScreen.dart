import 'dart:convert';
import 'package:earning_tracker/utiliti/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TranscriptScreen extends StatefulWidget {
  final String ticker;
  final int quarter;
  final int year;

  TranscriptScreen(
      {required this.ticker, required this.quarter, required this.year});

  @override
  _TranscriptScreenState createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  String? transcript;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTranscript();
  }

  Future<void> fetchTranscript() async {
    final apiUrl =
        'https://api.api-ninjas.com/v1/earningstranscript?ticker=${widget.ticker}&year=${widget.year}&quarter=${widget.quarter}';

    final headers = {
      'X-Api-Key': Constant.apiKey,
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transcript =
              data.isNotEmpty ? data['transcript'] : 'No transcript available.';
          print('transcript data >>>>>>>>>> ${data['transcript']}');
          isLoading = false;
        });
      } else {
        setState(() {
          transcript = 'Error fetching transcript: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        transcript = 'Failed to fetch transcript: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings Call Transcript for ${widget.ticker}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  transcript ?? 'No transcript available.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
    );
  }
}
