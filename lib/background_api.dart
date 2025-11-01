@pragma('vm:entry-point')
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'notification.dart'; // adjust path to your notification service file

// The task name must match what you register in main.
const fetchTask = "fetchPriceTask";
const _lastPriceKey = 'last_notified_price';

@pragma('vm:entry-point')
void callbackDispatcher() {
  // Workmanager requires this top-level entry point with the vm:entry-point pragma
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Workmanager: executeTask called for task: $task');

    // Initialize notifications in the background isolate
    await NotificationService.init();

    if (task == fetchTask) {
      try {
        // final payload= await rootBundle.loadString('assets/mocks/mock.json');
        // final http.Response response= http.Response(payload,200);
        final response = await http.get(Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=SOLUSDT'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final high = double.tryParse((data['highPrice'] ?? '0').toString())?.toStringAsFixed(2);
          final low = double.tryParse((data['lowPrice'] ?? '0').toString())?.toStringAsFixed(2);
          final currentPriceStr = double.tryParse((data['lastPrice'] ?? '0').toString())?.toStringAsFixed(2);

          debugPrint('Workmanager: fetched high=$high, low=$low, current=$currentPriceStr');

          final prefs = await SharedPreferences.getInstance();
          final lastStored = prefs.getString(_lastPriceKey);

          // If there is no stored price yet, store the current but do not notify (first run)
          if (lastStored == null) {
            await prefs.setString(_lastPriceKey, currentPriceStr ?? '0');
            debugPrint('Workmanager: stored initial price $currentPriceStr, no notification on first run.');
          } else {
            // Compare numeric values to avoid formatting differences
            final lastVal = double.tryParse(lastStored);
            final currentVal = double.tryParse(currentPriceStr ?? '0');

            if (lastVal == null || currentVal == null) {
              // If parsing fails, just store and don't notify
              await prefs.setString(_lastPriceKey, currentPriceStr ?? '0');
              debugPrint('Workmanager: parsing failed for comparison. Stored current price.');
            } else if (lastVal != currentVal) {
              // Price changed -> show notification and update stored value
              await NotificationService.showNotification(
                title: 'SOL/USDT Update',
                body: 'H: $high | L: $low | C: $currentPriceStr',
              );
              await prefs.setString(_lastPriceKey, currentPriceStr ?? '0');
              debugPrint('Workmanager: price changed from $lastVal to $currentVal. Notification shown and stored.');
            } else {
              // Price unchanged -> do nothing but maybe update other data if you want
              debugPrint('Workmanager: price unchanged ($currentPriceStr). No notification.');
            }
          }
        } else {
          debugPrint('Workmanager: HTTP error: ${response.statusCode}');
        }
      } catch (e, st) {
        debugPrint('Workmanager: exception while fetching data: $e\n$st');
      }
    }

    // Return true when the task executed successfully.
    return Future.value(true);
  });
}