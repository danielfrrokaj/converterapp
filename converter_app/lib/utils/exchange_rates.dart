import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl =
    'https://data.fixer.io/api/latest?access_key=c04ab06a9dcede14f2c6b9bacedf96ee&format=1';

class ExchangeRatesPage extends StatefulWidget {
  @override
  _ExchangeRatesPageState createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  String _baseCurrency = 'EUR'; // Default base currency
  Map<String, dynamic>? _exchangeRates;
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _currencies = [
    'EUR', 'USD', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD', 'SEK', 'CHF'
  ]; // Example currencies

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _exchangeRates = data['rates'];
            _isLoading = false;
          });
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exchange Rates'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown to select the base currency
                      DropdownButton<String>(
                        value: _baseCurrency,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _baseCurrency = value;
                            });
                          }
                        },
                        items: _currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      // List of exchange rates
                      Expanded(
                        child: ListView.builder(
                          itemCount: _exchangeRates!.keys.length,
                          itemBuilder: (context, index) {
                            String currency = _exchangeRates!.keys.elementAt(index);
                            double rate = _exchangeRates![currency] /
                                (_exchangeRates![_baseCurrency] ?? 1);

                            return currency == _baseCurrency
                                ? SizedBox.shrink()
                                : ExpansionTile(
                                    title: Text(
                                      '$currency: ${rate.toStringAsFixed(2)} $_baseCurrency',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          '1 $_baseCurrency = ${rate.toStringAsFixed(4)} $currency',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
