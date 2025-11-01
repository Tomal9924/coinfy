import 'dart:convert';
import 'package:coinfy/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _lastPriceKey = 'last_notified_price';

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

  Future<void> fetchPrices({bool forceNotify = false}) async {
    final url = Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=SOLUSDT');
    final response = await http.get(url);
    // final payload = await rootBundle.loadString('assets/mocks/mock.json');
    // final http.Response response = http.Response(payload, 200);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final highStr = double.tryParse((data['highPrice'] ?? '0').toString())?.toStringAsFixed(2);
      final lowStr = double.tryParse((data['lowPrice'] ?? '0').toString())?.toStringAsFixed(2);
      final currentStr = double.tryParse((data['lastPrice'] ?? '0').toString())?.toStringAsFixed(2);

      final high = double.tryParse(highStr ?? '0');
      final low = double.tryParse(lowStr ?? '0');
      final current = double.tryParse(currentStr ?? '0');

      // Update the in-memory state so UI updates immediately
      updatePrices(high, low, current);

      // Now decide whether to notify by comparing with stored last price
      final prefs = await SharedPreferences.getInstance();
      final lastStored = prefs.getString(_lastPriceKey);

      if (lastStored == null) {
        // First time: store and optionally notify only if forceNotify is true
        await prefs.setString(_lastPriceKey, currentStr ?? '0');
        if (forceNotify) {
          await NotificationService.showNotification(title: 'SOL/USDT Update', body: 'H: $highStr | L: $lowStr | C: $currentStr');
        }
        debugPrint('Provider: stored initial price $currentStr');
      } else {
        final lastVal = double.tryParse(lastStored);
        final currentVal = current;

        if (lastVal == null || currentVal == null) {
          // If parsing fails, just store current
          await prefs.setString(_lastPriceKey, currentStr ?? '0');
          debugPrint('Provider: parsing failed for comparison. Stored current price.');
        } else if (lastVal != currentVal) {
          // Price changed
          await NotificationService.showNotification(title: 'SOL/USDT Update', body: 'H: $highStr | L: $lowStr | C: $currentStr');
          await prefs.setString(_lastPriceKey, currentStr ?? '0');
          debugPrint('Provider: price changed from $lastVal to $currentVal. Notification shown and stored.');
        } else {
          // Unchanged -> no notification
          debugPrint('Provider: price unchanged ($currentStr). No notification.');
        }
      }
    } else {
      throw Exception('Failed to fetch prices');
    }
  }
}
