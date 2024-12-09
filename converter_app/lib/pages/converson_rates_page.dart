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

  // List of 15 major currencies
  final List<String> _majorCurrencies = [
    'USD', 'EUR', 'JPY', 'GBP', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK',
    'NZD', 'MXN', 'SGD', 'HKD', 'NOK', 'INR'
  ];

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
                      Row(
                        children: [
                          Text(
                            "Base Currency: ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _baseCurrency,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _baseCurrency = value;
                                });
                              }
                            },
                            items: _majorCurrencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // List of exchange rates as static tiles
                      Expanded(
                        child: ListView.builder(
                          itemCount: _majorCurrencies.length,
                          itemBuilder: (context, index) {
                            String currency = _majorCurrencies[index];
                            if (_exchangeRates == null ||
                                !_exchangeRates!.containsKey(currency) ||
                                !_exchangeRates!.containsKey(_baseCurrency)) {
                              return SizedBox.shrink(); // Skip unavailable currencies
                            }

                            double rate = _exchangeRates![currency] /
                                (_exchangeRates![_baseCurrency] ?? 1);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: Text(
                                  currency,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '1 $_baseCurrency = ${rate.toStringAsFixed(4)} $currency',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Text(
                                  rate.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
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
