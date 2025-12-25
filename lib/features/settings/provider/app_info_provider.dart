// Salin ke: lib/features/settings/provider/app_info_provider.dart
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_provider.g.dart';

// Provider ini akan mengambil versi aplikasi
@riverpod
Future<String> appVersion(AppVersionRef ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  // Mengembalikan string seperti "1.0.0" atau "1.0.0+1"
  return '${packageInfo.version} (${packageInfo.buildNumber})'; 
}