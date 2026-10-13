
import 'package:flutter/material.dart';
import 'screens/waiter_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
