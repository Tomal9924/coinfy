import 'package:coinfy/dashboard.dart';
import 'package:coinfy/notification.dart';
import 'package:coinfy/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'background_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await Permission.notification.request();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask("1", fetchTask, frequency: const Duration(minutes: 10));

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PriceProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOL/USDT Tracker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const DashboardScreen(),
    );
  }
}
