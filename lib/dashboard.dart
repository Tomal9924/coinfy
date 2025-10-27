import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/provider.dart'; // adjust the path to your PriceProvider file

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Run after build to ensure provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // use context.read to invoke a one-time call
      debugPrint('Dashboard: calling fetchPrices from initState');
      context.read<PriceProvider>().fetchPrices().catchError((e) {
        debugPrint('Dashboard: fetchPrices error: $e');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PriceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SOL/USDT Dashboard'), centerTitle: true),
      body: Center(
        child: provider.highPrice == null
            ? ElevatedButton(
                onPressed: () {
                  debugPrint('Fetch button pressed');
                  provider.fetchPrices();
                },
                child: const Text("Fetch Prices"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Highest Price (24h): ${provider.highPrice} USDT', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('Lowest Price (24h): ${provider.lowPrice} USDT', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: () => provider.fetchPrices(), child: const Text('Refresh')),
                ],
              ),
      ),
    );
  }
}