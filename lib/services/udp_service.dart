// udp_service.dart
import 'dart:convert';
import 'dart:io';
import '../model/device_snapshot.dart';
import '../network/peer.dart';

typedef DiscoveryCallback = void Function(List<Peer> peers);

class UDPService {
  static const int port = 4040;

  static RawDatagramSocket? _listenerSocket;
  List<Peer> _peers = [];
  DiscoveryCallback? _discoveryCallback;

  /// Start listening (Dashboard & ShareScreen)
  static Future<void> startListening() async {
    _listenerSocket ??= await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _listenerSocket!.broadcastEnabled = true;
    _listenerSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _listenerSocket!.receive();
        if (dg != null) {
          try {
            final decoded = utf8.decode(dg.data);
            final map = jsonDecode(decoded) as Map<String, dynamic>;
            print('UDP: Received: $decoded');
          } catch (e) {
            print('UDP: Error decoding data: $e');
          }
        }
      }
    });
    print('UDP: Listener started on port $port');
  }

  /// Broadcast data to all devices
  Future<void> broadcast(Map<String, dynamic> data) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final bytes = utf8.encode(jsonEncode(data));
    socket.send(bytes, InternetAddress('255.255.255.255'), port);
    socket.close();
    print('UDP: Broadcast sent: $data');
  }

  /// Start discovery (ShareScreen)
  void startDiscovery(DiscoveryCallback callback) {
    _discoveryCallback = callback;

    // UDP ping to discover peers
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      socket.broadcastEnabled = true;
      final message = utf8.encode(jsonEncode({'type': 'ping'}));
      socket.send(message, InternetAddress('255.255.255.255'), port);

      // Listen for responses
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = socket.receive();
          if (dg != null) {
            try {
              final decoded = utf8.decode(dg.data);
              final map = jsonDecode(decoded) as Map<String, dynamic>;
              if (map['type'] == 'pong' && !_peers.any((p) => p.ip == dg.address.address)) {
                _peers.add(Peer(name: map['deviceName'], ip: dg.address.address));
                _discoveryCallback?.call(_peers);
              }
            } catch (_) {}
          }
        }
      });
    });
  }

  /// Send snapshot to a peer
  Future<void> sendSnapshot(Peer peer, DeviceSnapshot snapshot) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final bytes = utf8.encode(jsonEncode(snapshot.toJson()));
    socket.send(bytes, InternetAddress(peer.ip), port);
    socket.close();
    print('UDP: Snapshot sent to ${peer.name}');
  }

  void dispose() {
    _listenerSocket?.close();
    _listenerSocket = null;
    print('UDP: Listener stopped');
  }
}
