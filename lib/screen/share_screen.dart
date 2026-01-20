import 'package:flutter/material.dart';
import '../model/device_snapshot.dart';
import '../network/peer.dart';
import '../services/udp_service.dart';

class ShareScreen extends StatefulWidget {
  final DeviceSnapshot snapshot;
  const ShareScreen({super.key, required this.snapshot});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final service = UDPService();
  List<Peer> peers = [];

  @override
  void initState() {
    super.initState();
    service.startDiscovery((list) {
      setState(() => peers = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Peer")),
      body: peers.isEmpty
          ? const Center(child: Text("No peers found"))
          : ListView.builder(
        itemCount: peers.length,
        itemBuilder: (_, i) {
          final peer = peers[i];
          return ListTile(
            title: Text(peer.name),
            subtitle: Text(peer.ip),
            trailing: const Icon(Icons.send),
            onTap: () {
              service.sendSnapshot(peer, widget.snapshot);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sent to ${peer.name}")),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }
}
