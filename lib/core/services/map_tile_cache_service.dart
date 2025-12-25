// // Alternatif jika class tidak dikenali
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

// class MapTileCacheService {
//   static final MapTileCacheService _instance = MapTileCacheService._internal();
//   factory MapTileCacheService() => _instance;
//   MapTileCacheService._internal();

//   bool _initialized = false;
//   late final dynamic _store; // Gunakan dynamic sementara

//   dynamic get store => _store;
//   bool get isInitialized => _initialized;

//   // TileProvider dengan fallback
//   TileProvider get tileProvider {
//     if (!_initialized) {
//       throw Exception('MapTileCacheService belum diinisialisasi');
//     }
//     return _store.tileProvider;
//   }

//   Future<void> initialize() async {
//     if (_initialized) return;
    
//     try {
//       print('[MapCache] 🗺️ Memulai inisialisasi FMTC...');

//       // Inisialisasi
//       await FlutterMapTileCaching.initialise();
      
//       // Buat store
//       _store = await FlutterMapTileCaching.instance.createStore('defaultStore');
      
//       print('[MapCache] ✅ Inisialisasi Berhasil');
//       _initialized = true;
//     } catch (e) {
//       print('[MapCache] ❌ Error: $e');
//       rethrow;
//     }
//   }
// }