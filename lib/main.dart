import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/services/hive_service.dart';
import 'package:fintrack_app/features/home/presentation/home_screen.dart';
import 'package:fintrack_app/core/providers/core_providers.dart'; // Import core providers

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  // For debugging: Clear all transactions
  //todo: remove this before submission
  final container = ProviderContainer();
  await container.read(hiveServiceProvider.future); // Ensure HiveService is initialized
  final transactionRepository = await container.read(transactionRepositoryProvider.future);
  await transactionRepository.clearAllTransactions();
  container.dispose();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
