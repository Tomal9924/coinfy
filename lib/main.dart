import 'dart:io';

import 'package:coinfy/dashboard.dart';
import 'package:coinfy/handshake.dart';
import 'package:coinfy/notification.dart';
import 'package:coinfy/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'background_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides(allowBadCertificates: true);
  await NotificationService.init();
  await Permission.notification.request();

  // Initialize Workmanager and wait for initialization to complete
  // Use isInDebugMode: true while debugging so you get logs
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Register the periodic task and await it
  await Workmanager().registerPeriodicTask(
    "fetch_price_unique_name", // unique name for this work
    fetchTask,                 // task name used inside callbackDispatcher
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(seconds: 10),
  );

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
      debugShowCheckedModeBanner: false,
      title: 'SOL/USDT Tracker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const DashboardScreen(),
    );
  }
}