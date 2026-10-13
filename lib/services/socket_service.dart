
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/api_config.dart';

class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required void Function(Map<String, dynamic> request) onNewRequest,
    required void Function(bool connected) onConnectionChanged,
  }) {
    // Prevent creating duplicate socket connections.
    if (_socket != null) {
      return;
    }

    final socket = io.io(
      ApiConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket = socket;

    socket.onConnect((_) {
      debugPrint('TapWait Socket.io connected: ${socket.id}');

      socket.emitWithAck(
        'join_restaurant',
        ApiConfig.restaurantId,
        ack: (response) {
          debugPrint('Restaurant room response: $response');
        },
      );

      onConnectionChanged(true);
    });

    socket.on('new_waiter_request', (data) {
      try {
        if (data is Map) {
          final request = Map<String, dynamic>.from(data);
          debugPrint('New waiter request received: $request');
          onNewRequest(request);
        } else {
          debugPrint('Unexpected request payload: $data');
        }
      } catch (error) {
        debugPrint('Could not process waiter request: $error');
      }
    });

    socket.onDisconnect((_) {
      debugPrint('TapWait Socket.io disconnected');
      onConnectionChanged(false);
    });

    socket.onConnectError((error) {
      debugPrint('Socket connection error: $error');
      onConnectionChanged(false);
    });

    socket.onError((error) {
      debugPrint('Socket error: $error');
    });

    socket.connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
