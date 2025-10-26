import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrency = 'AED';

  final Map<String, String> _currencies = {
    'AED': 'د.إ',
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

  String get selectedCurrency => _selectedCurrency;
  String get selectedCurrencySymbol =>
      _currencies[_selectedCurrency] ?? _selectedCurrency;
  Map<String, String> get currencies => _currencies;

  void changeCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners();
  }
}
