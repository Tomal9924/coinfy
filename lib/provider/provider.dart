import 'dart:convert';
import 'package:coinfy/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PriceProvider with ChangeNotifier {
  double? highPrice;
  double? lowPrice;
  double? currentPrice;

  void updatePrices(double? high, double? low, double? current) {
    highPrice = high;
    lowPrice = low;
    currentPrice = current;
    notifyListeners();
  }

  Future<void> fetchPrices() async {
    final url = Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=SOLUSDT');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final highPrice = double.tryParse(data['highPrice'] ?? '0')?.toStringAsFixed(2);
      final lowPrice = double.tryParse(data['lowPrice'] ?? '0')?.toStringAsFixed(2);
      final currentPrice = double.tryParse(data['lastPrice'] ?? '0')?.toStringAsFixed(2);

      updatePrices(double.tryParse(highPrice ?? '0'), double.tryParse(lowPrice ?? '0'), double.tryParse(currentPrice ?? '0'));
      await NotificationService.showNotification(title: 'SOL/USDT Update', body: 'H: $highPrice | L: $lowPrice | C: $currentPrice');
      notifyListeners();
    } else {
      throw Exception('Failed to fetch prices');
    }
  }
}
