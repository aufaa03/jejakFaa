import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jejak_faa_new/routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:jejak_faa_new/core/services/background_tracker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'; // Tambahkan import ini
import 'package:http_cache_file_store/http_cache_file_store.dart'; // Tambahkan import ini
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // Tambahkan import ini untuk Platform.pathSeparator
import 'package:intl/date_symbol_data_local.dart';

// Biar bisa update notifikasi dari background
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

// Variabel global untuk menyimpan CacheStore
late final CacheStore globalCacheStore;

/// Fungsi untuk mendapatkan CacheStore.
/// Kami menggunakan FileCacheStore untuk menyimpan tile di sistem file.
Future<CacheStore> getCacheStore() async {
  // Dapatkan direktori sementara (cache) aplikasi.
  final dir = await getTemporaryDirectory();
  
  // Buat path untuk penyimpanan tile peta.
  // Penting: Gunakan Platform.pathSeparator untuk kompatibilitas OS.
  final cachePath = '${dir.path}${Platform.pathSeparator}MapTiles';
  
  // Inisialisasi FileCacheStore.
  return FileCacheStore(cachePath);
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'jejak_faa_location',
    'Jejak FAA Location',
    description: 'Layanan ini melacak lokasi untuk pendakian Anda.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'jejak_faa_location',
      initialNotificationTitle: 'Jejak Faa',
      initialNotificationContent: 'Menunggu perintah tracking...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.on('updateNotification').listen((payload) {
    if (payload == null) return;

    final title = payload['title'] as String?;
    final content = payload['content'] as String?;

    if (title != null && content != null) {
      _updateNotification(title, content);
      print('[Main] ✅ Notification updated: $title - $content');
    }
  });

  print('[Main] ✅ Service initialized');
}

// Update notif helper
Future<void> _updateNotification(String title, String content) async {
  try {
    await flutterLocalNotificationsPlugin.show(
      888,
      title,
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'jejak_faa_location',
          'Jejak FAA Location',
          channelDescription: 'Layanan ini melacak lokasi untuk pendakian Anda.',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  } catch (e) {
    print('[Main] ❌ Error updating notification: $e');
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  print('Layanan Latar Belakang iOS Dimulai');
  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Inisialisasi CacheStore secara global
    globalCacheStore = await getCacheStore();
    print('[Main] ✅ flutter_map_cache (FileCacheStore) initialized.');
  } catch (e) {
    print('[Main] ❌ Gagal inisialisasi cache: $e');
    // Anda mungkin ingin menangani error ini lebih lanjut, 
    // misalnya dengan menampilkan pesan error ke pengguna.
  }

  print('[Main] 📝 Loading .env file...');
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY missing in .env!');
  }

  print('[Main] 🔐 Initializing Supabase...');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  print('[Main] 🇮🇩 Initializing Indonesian locale...');
  await initializeDateFormatting('id_ID', null);
  
  print('[Main] 📍 Initializing background service...');
  await initializeService();

  print('[Main] ✅ All services initialized, launching app...');

  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Jejak Faa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}