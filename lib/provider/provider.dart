import 'dart:convert';
import 'package:coinfy/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PriceProvider with ChangeNotifier {
  double? highPrice;
  double? lowPrice;

  Future<void> fetchPrices() async {
    final url = Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=SOLUSDT');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      highPrice = double.tryParse(data['highPrice'] ?? '0');
      lowPrice = double.tryParse(data['lowPrice'] ?? '0');
      await NotificationService.showNotification(title: 'SOL/USDT Update', body: 'High: $highPrice | Low: $lowPrice');
      notifyListeners();
    } else {
      throw Exception('Failed to fetch prices');
    }
  }
}
