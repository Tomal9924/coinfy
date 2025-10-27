// This file defines the callbackDispatcher that Workmanager will call.
// Make sure this file is imported where you call Workmanager().initialize(...) (as you already do).
@pragma('vm:entry-point')
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'notification.dart'; // adjust path to your notification service file

// The task name must match what you register in main.
const fetchTask = "fetchPriceTask";

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
        final response = await http.get(
          Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=SOLUSDT'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final high = data['highPrice'];
          final low = data['lowPrice'];

          debugPrint('Workmanager: fetched high=$high, low=$low');

          await NotificationService.showNotification(
            title: 'SOL/USDT Update',
            body: 'High: $high | Low: $low',
          );
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