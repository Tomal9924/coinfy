// lib/http_overrides.dart
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  final bool allowBadCertificates;

  MyHttpOverrides({this.allowBadCertificates = false});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    if (allowBadCertificates) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    }
    return client;
  }
}