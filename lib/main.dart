import 'package:earning_tracker/screens/EarningsScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Earnings Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TickerInputScreen(),
    );
  }
}

class TickerInputScreen extends StatefulWidget {
  @override
  _TickerInputScreenState createState() => _TickerInputScreenState();
}

class _TickerInputScreenState extends State<TickerInputScreen> {
  final _tickerController = TextEditingController();

  void _submitTicker() {
    final ticker = _tickerController.text.trim().toUpperCase();
    if (ticker.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EarningsScreen(ticker: ticker),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Please enter a valid ticker symbol.',
          style: TextStyle(
            color: Colors.red,
          ),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Company Ticker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _tickerController,
              decoration: InputDecoration(
                labelText: 'Company Ticker (e.g., MSFT)',
                border: OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                  ),
                  onPressed: _submitTicker,
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Color.fromARGB(255, 5, 17, 93),
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }
}
