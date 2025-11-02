import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jejak_faa_new/routes/app_router.dart'; // Asumsi kamu pakai GoRouter
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Pastikan binding Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

 await dotenv.load(fileName: ".env");
  // Pastikan await dotenv.load(fileName: ".env"); sudah dipanggil SEBELUM ini

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Jalankan aplikasi dengan ProviderScope (untuk Riverpod)
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Helper untuk akses cepat client Supabase
final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan router yang kamu buat
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Jejak Faa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}