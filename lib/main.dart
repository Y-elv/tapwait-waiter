
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const TapWaitApp());
}

class TapWaitApp extends StatelessWidget {
  const TapWaitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapWait',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WaiterScreen(),
    );
  }
}

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  String status = 'Waiting for a customer request';
  bool hasRequest = false;
  bool accepted = false;

  Future<void> triggerTestAlert() async {
    setState(() {
      hasRequest = true;
      accepted = false;
      status = 'Table 8 needs a waiter!';
    });

    try {
      final supported = await Vibration.hasVibrator();

      if (supported) {
        await Vibration.vibrate(pattern: [0, 500, 200, 500]);
      }
    } catch (error) {
      debugPrint('Vibration error: $error');
    }
  }

  void acceptRequest() {
    setState(() {
      accepted = true;
      status = 'You accepted Table 8!';
    });
  }

  void resetDemo() {
    setState(() {
      hasRequest = false;
      accepted = false;
      status = 'Waiting for a customer request';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TapWait — Waiter')),
      body: Center(
        child: Padding(
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
              const SizedBox(height: 32),
              if (!hasRequest)
                FilledButton.icon(
                  onPressed: triggerTestAlert,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Trigger Test Alert'),
                ),
              if (hasRequest && !accepted)
                FilledButton.icon(
                  onPressed: acceptRequest,
                  icon: const Icon(Icons.check),
                  label: const Text('Accept Request'),
                ),
              if (accepted)
                FilledButton.tonal(
                  onPressed: resetDemo,
                  child: const Text('Reset Demo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
