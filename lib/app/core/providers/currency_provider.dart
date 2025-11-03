import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrency = 'AED';
  Map<String, double> _exchangeRates = {};
  final String _apiKey =
      '91ac4eaa3bd74ca4a4bb4545'; // Replace with your API key from https://www.exchangerate-api.com/

  final Map<String, String> _currencies = {
    'AED': 'AED',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'AUD': '\$',
    'CAD': '\$',
    'CHF': 'CHF',
  };

  CurrencyProvider() {
    _loadCurrency();
  }

  String get selectedCurrency => _selectedCurrency;
  String get selectedCurrencySymbol =>
      _currencies[_selectedCurrency] ?? _selectedCurrency;
  Map<String, String> get currencies => _currencies;

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('selectedCurrency') ?? 'AED';
    await fetchExchangeRates();
    notifyListeners();
  }

  Future<void> _saveCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrency', _selectedCurrency);
  }

  Future<void> fetchExchangeRates() async {
    if (_apiKey == '91ac4eaa3bd74ca4a4bb4545') {
      print(
        'Please replace YOUR_API_KEY with your actual API key from https://www.exchangerate-api.com/',
      );
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          'https://v6.exchangerate-api.com/v6/$_apiKey/latest/$_selectedCurrency',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _exchangeRates = Map<String, double>.from(data['conversion_rates']);
        notifyListeners();
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      print(e);
    }
  }

  double convert(double amount, String fromCurrency, String toCurrency) {
    if (_exchangeRates.isEmpty) {
      return amount;
    }
    double fromRate = _exchangeRates[fromCurrency] ?? 1.0;
    double toRate = _exchangeRates[toCurrency] ?? 1.0;
    return (amount / fromRate) * toRate;
  }

  Future<void> changeCurrency(String newCurrency) async {
    _selectedCurrency = newCurrency;
    await _saveCurrency();
    await fetchExchangeRates();
    notifyListeners();
  }
}
