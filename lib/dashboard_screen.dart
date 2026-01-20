import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/native_service.dart';
import '../services/udp_service.dart';
import '../model/device_snapshot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;
  final UDPService udpService = UDPService(); // UDPService instance

  Future<void> load() async {
    try {
      final d = await NativeService.getDeviceData();
      if (d is Map<String, dynamic>) {
        data = d;
        data!['timestamp'] = DateTime.now().toIso8601String();
      } else {
        data = {'error': 'Invalid data'};
      }
    } catch (e) {
      data = {'error': 'Failed to get device data: $e'};
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
    UDPService.startListening(); // UDP listener start
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Live Device Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (data is Map<String, dynamic>)
            ...data!.entries.map(
                  (entry) => Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 16),
              ),
            )
          else
            Text(
              'Data is not valid: $data',
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (data != null && data is Map<String, dynamic> && !data!.containsKey('error')) {
                await udpService.broadcast(data!); // share data over UDP
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pulse shared!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot share: Invalid data')),
                );
              }
            },
            child: const Text('Share My Pulse'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    udpService.dispose(); // stop UDP listener
    super.dispose();
  }
}
