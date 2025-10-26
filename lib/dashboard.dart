import 'package:coinfy/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PriceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SOL/USDT Dashboard'), centerTitle: true),
      body: Center(
        child: provider.highPrice == null
            ? ElevatedButton(onPressed: () => provider.fetchPrices(), child: const Text("Fetch Prices"))
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
