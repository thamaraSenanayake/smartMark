import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/mode_selector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartMarkApp());
}

class SmartMarkApp extends StatelessWidget {
  const SmartMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartMark - Teacher Assessment & Analytics System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ModeSelectorScreen(),
    );
  }
}
