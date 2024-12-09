import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'converson_rates_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? fromCurrency;
  String? toCurrency = "USD"; // Default target currency
  String result = "0.0";
  double amount = 0.0;

  Map<String, dynamic> exchangeRates = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  // Initialize App by Setting Default Currency and Fetching Rates
  void initializeApp() async {
    await _setDefaultCurrency();
    fetchExchangeRates();
  }

  // Set default currency based on device location
Future<void> _setDefaultCurrency() async {
  try {
    // Ensure location permission
    LocationPermission permission = await Geolocator.checkPermission();
    print('Permission status: $permission');
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        print('Permission not granted, using default currency (USD)');
        setState(() {
          fromCurrency = 'USD'; // Default currency if permission is denied
        });
        return;
      }
    }

    // Get the user's current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print("Position retrieved: Latitude: ${position.latitude}, Longitude: ${position.longitude}");

    // Reverse geocode to get country code
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print('Placemark data: $placemarks');

    if (placemarks.isNotEmpty) {
      String? countryCode = placemarks.first.isoCountryCode;
      print('Country code retrieved: $countryCode');

      // Map country codes to main currencies
      final currencyMap = {
        'SE': 'SEK', // Sweden
        'US': 'USD', // United States
        'GB': 'GBP', // United Kingdom
        'DE': 'EUR', // Germany
        'FR': 'EUR', // France
        'JP': 'JPY', // Japan
        'CN': 'CNY', // China
        'IN': 'INR', // India
        'AU': 'AUD', // Australia
        'CA': 'CAD', // Canada
        'RU': 'RUB', // Russia
        'BR': 'BRL', // Brazil
        'ZA': 'ZAR', // South Africa
        'KR': 'KRW', // South Korea
        'CH': 'CHF', // Switzerland
      };

      setState(() {
        fromCurrency = currencyMap[countryCode] ?? 'USD'; // Default to USD if no match
        print('Currency set to: $fromCurrency');
      });
    } else {
      print("No placemarks found.");
      setState(() {
        fromCurrency = 'USD'; // Default to USD if no placemarks found
      });
    }
  } catch (e) {
    print('Error getting location: $e');
    setState(() {
      fromCurrency = 'USD'; // Default to USD on error
    });
  }
}





  Future<void> fetchExchangeRates() async {
    const apiUrl =
        "https://data.fixer.io/api/latest?access_key=c04ab06a9dcede14f2c6b9bacedf96ee&format=1";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = data['rates'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      print("Error fetching exchange rates: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateConversion() {
    if (exchangeRates.isNotEmpty && fromCurrency != null && toCurrency != null) {
      double fromRate = exchangeRates[fromCurrency] ?? 1.0;
      double toRate = exchangeRates[toCurrency] ?? 1.0;
      setState(() {
        result = ((amount / fromRate) * toRate).toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Input Amount
                  Row(
                    children: [
                      const Text("Amount: "),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              amount = double.tryParse(value) ?? 0.0;
                            });
                            calculateConversion();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dropdowns for Currency Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // From Currency
                      DropdownButton<String>(
                        value: fromCurrency,
                        items: exchangeRates.keys
                            .map((currency) => DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            fromCurrency = value;
                            calculateConversion();
                          });
                        },
                      ),
                      const Icon(Icons.arrow_forward),
                      // To Currency
                      DropdownButton<String>(
                        value: toCurrency,
                        items: exchangeRates.keys
                            .map((currency) => DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            toCurrency = value;
                            calculateConversion();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Result Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Converted Amount: "),
                      Text(
                        result,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Navigate to Exchange Rates Page
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExchangeRatesPage(),
                        ),
                      );
                    },
                    child: const Text("View Exchange Rates"),
                  ),
                ],
              ),
            ),
    );
  }
}
