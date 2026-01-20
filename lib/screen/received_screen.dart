
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/device_snapshot.dart';
import '../services/native_service.dart';



class ReceivedScreen extends StatelessWidget {
  const ReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('snapshots');

    return Scaffold(
      appBar: AppBar(title: const Text("Received Pulses")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (_, Box box, __) {
          if (box.isEmpty) {
            return const Center(child: Text("No data received"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, i) {
              final json = Map<String, dynamic>.from(box.getAt(i));
              final snap = DeviceSnapshot.fromJson(json);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(snap.deviceName),
                  subtitle: Text(
                    "Battery: ${snap.batteryLevel}% | Temp: ${snap.batteryTemp}°C\n"
                        "Health: ${snap.batteryHealth}\n"
                        "Android: ${snap.androidVersion}",
                  ),
                  trailing: Text(
                    snap.timestamp.toLocal().toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}