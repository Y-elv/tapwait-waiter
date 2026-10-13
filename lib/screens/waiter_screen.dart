
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/socket_service.dart';
import '../services/vibration_service.dart';
import '../services/request_service.dart';

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  final SocketService _socketService = SocketService();
  final RequestService _requestService = RequestService();

  String status = 'Connecting to TapWait...';

  bool connected = false;
  bool hasRequest = false;
  bool accepted = false;
  bool isAccepting = false;

  String? requestId;
  String? tableNumber;
  String? acceptError;

  @override
  void initState() {
    super.initState();

    _socketService.connect(
      onConnectionChanged: (isConnected) {
        if (!mounted) return;

        setState(() {
          connected = isConnected;

          if (!hasRequest) {
            status = isConnected
                ? 'Connected — waiting for customer requests'
                : 'Connecting to TapWait server...';
          }
        });
      },
      onNewRequest: (request) async {
        if (!mounted) return;

        final incomingRestaurantId =
            request['restaurantId']?.toString();

        if (incomingRestaurantId != ApiConfig.restaurantId) {
          return;
        }

        final incomingStatus = request['status']?.toString();

        if (incomingStatus != 'pending') {
          return;
        }

        final incomingRequestId = request['id']?.toString();

        if (incomingRequestId == null ||
            incomingRequestId.isEmpty) {
          debugPrint('Received request without an ID: $request');
          return;
        }

        setState(() {
          requestId = incomingRequestId;
          tableNumber = request['tableNumber']?.toString() ?? '?';
          hasRequest = true;
          accepted = false;
          isAccepting = false;
          acceptError = null;
          status = 'Table $tableNumber needs a waiter!';
        });

        await VibrationService.alert();
      },
    );
  }

  Future<void> acceptCurrentRequest() async {
    final currentRequestId = requestId;

    if (currentRequestId == null ||
        isAccepting ||
        accepted) {
      return;
    }

    setState(() {
      isAccepting = true;
      acceptError = null;
      status = 'Accepting request...';
    });

    try {
      await _requestService.acceptRequest(
        requestId: currentRequestId,
      );

      if (!mounted) return;

      await VibrationService.stop();

      if (!mounted) return;

      setState(() {
        isAccepting = false;
        accepted = true;
        status = 'You accepted Table ${tableNumber ?? '?'}!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted successfully!'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isAccepting = false;
        acceptError = error.toString();
        status = 'Could not accept the request';
      });
    }
  }

  void resetRequest() {
    if (isAccepting) return;

    setState(() {
      hasRequest = false;
      accepted = false;
      isAccepting = false;
      requestId = null;
      tableNumber = null;
      acceptError = null;

      status = connected
          ? 'Connected — waiting for customer requests'
          : 'Connecting to TapWait server...';
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    VibrationService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TapWait — Waiter'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.circle,
              size: 12,
              color: connected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                accepted
                    ? Icons.check_circle
                    : hasRequest
                        ? Icons.notifications_active
                        : Icons.restaurant,
                size: 76,
                color: accepted ? Colors.green : Colors.teal,
              ),
              const SizedBox(height: 24),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                connected
                    ? 'Server connected'
                    : 'Server disconnected',
                style: TextStyle(
                  color: connected ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 32),

              if (hasRequest && !accepted)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        isAccepting ? null : acceptCurrentRequest,
                    icon: isAccepting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      isAccepting
                          ? 'Accepting...'
                          : 'Accept Request',
                    ),
                  ),
                ),

              if (acceptError != null) ...[
                const SizedBox(height: 12),
                Text(
                  acceptError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your internet connection and try again.',
                  textAlign: TextAlign.center,
                ),
              ],

              if (accepted)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: resetRequest,
                    child: const Text('Clear Request'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
