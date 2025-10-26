import 'dart:convert';
import 'package:coinfy/notification.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

const fetchTask = "fetchPriceTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchTask) {
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=SOLUSDT'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final high = data['highPrice'];
        final low = data['lowPrice'];

        await NotificationService.showNotification(
          title: 'SOL/USDT Update',
          body: 'High: $high | Low: $low',
        );
      }
    }
    return Future.value(true);
  });
}
