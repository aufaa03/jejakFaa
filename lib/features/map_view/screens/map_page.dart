import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/core/services/gps_service.dart' as gps;
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:jejak_faa_new/features/map_view/providers/map_provider.dart';
import 'package:latlong2/latlong.dart';

// Import yang kita butuhkan untuk dialog
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as d;


// --- PERUBAHAN 1: Ubah menjadi ConsumerStatefulWidget ---
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  // --- AKHIR PERUBAHAN 1 ---

  static final _mapController = MapController();
  
  // --- PERUBAHAN 2: Tambah initState ---
  @override
  void initState() {
    super.initState();
    // Jalankan pengecekan SETELAH frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionStatus();
    });
  }

  /// Pengecekan proaktif saat halaman dibuka
  Future<void> _checkSessionStatus() async {
    // Pastikan widget masih ada (mounted)
    if (!mounted) return;
    
    final notifier = ref.read(mapNotifierProvider.notifier);
    
    // Cek Skenario 1: Ada sesi yang dijeda (paused=true)
    final bool hasPaused = await notifier.hasPausedSession;
    if (hasPaused) {
      print('[MapPage] Sesi dijeda ditemukan. Menampilkan dialog...');
      _showResumeDialog();
      return;
    }

    // Cek Skenario 2: Ada sesi yang berjalan (paused=false)
    // Ini terjadi jika app di-kill oleh OS (Bug B)
    // Getter 'pausedHikeId' sebenarnya mengambil 'ongoing_hike_id'
    final int? ongoingId = await notifier.pausedHikeId;
    if (ongoingId != null) {
      print('[MapPage] Sesi auto-resume ditemukan. Memulai ulang tracking...');
      // Ini akan memicu 'Case 1' (Auto-resuming) di dalam startTracking()
      await notifier.startTracking();
    }
  }

  /// Menampilkan dialog "Lanjutkan atau Buang"
  void _showResumeDialog() {
    // Pastikan widget masih ada (mounted)
    if (!mounted) return;

    final notifier = ref.read(mapNotifierProvider.notifier);
    
    showDialog(
      context: context,
      barrierDismissible: false, // Wajib pilih
      builder: (ctx) => AlertDialog(
        title: const Text('Sesi Ditemukan'),
        content: const Text('Anda memiliki sesi pendakian yang dijeda. Apa yang ingin Anda lakukan?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Panggil fungsi baru kita
              await notifier.discardPausedSession();
            },
            child: const Text('Buang Sesi', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Panggil fungsi resume
              await notifier.resumeTracking();
            },
            child: const Text('Lanjutkan Sesi'),
          ),
        ],
      ),
    );
  }
  // --- AKHIR PERUBAHAN 2 ---


  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN 3: 'ref' sudah jadi properti class ---
    final state = ref.watch(mapNotifierProvider);
    final notifier = ref.read(mapNotifierProvider.notifier);
    final initialGpsAsync = ref.watch(gps.currentGpsLocationProvider);
    // --- AKHIR PERUBAHAN 3 ---

    return Scaffold(
      body: Stack(
        children: [
          // ... (Sisa kode Peta/UI Anda dari sini ke bawah 100% SAMA) ...
          // ... (Saya salin dari kode Anda sebelumnya) ...
          
          // --- LAPISAN 1: PETA (PALING BAWAH) ---
          initialGpsAsync.when(
            loading: () => const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text('Mencari sinyal GPS...'),
                  ],
                ),
              ),
            ),
            error: (err, stack) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error GPS: $err'),
                  ],
                ),
              ),
            ),
            data: (initialPosition) {
              if (initialPosition == null) {
                return const Center(
                  child: Text('Gagal mendapatkan lokasi awal GPS.'),
                );
              }

              final liveGpsAsync = ref.watch(gps.gpsPositionProvider);
              final currentPosition =
                  liveGpsAsync.valueOrNull ?? initialPosition;
              final mapCenter = LatLng(
                currentPosition.latitude,
                currentPosition.longitude,
              );

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 17.0,
                  onPositionChanged: (position, hasGesture) {
                    // TODO: Hentikan 'auto-center' jika user menggeser peta
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jejak_faa_new',
                  ),
                  if (state.livePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.livePoints,
                          color: Colors.blue.withOpacity(0.8),
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                  if (state.liveWaypoints.isNotEmpty)
                    MarkerLayer(
                      markers: state.liveWaypoints.map((waypoint) {
                        return Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(waypoint.latitude, waypoint.longitude),
                          child: Tooltip(
                            message: waypoint.name,
                            child: Icon(
                              _getIconForCategory(waypoint.category),
                              color: Colors.purple.shade700,
                              size: 35,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 24,
                        height: 24,
                        point: mapCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
          // --- LAPISAN 2: POINTER TENGAH (HANYA MUNCUL DI MODE PILIH) ---
          if (state.isPickingWaypoint)
            Center(
              child: IgnorePointer( 
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0), 
                  child: Icon(
                    Icons.location_pin,
                    size: 50,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),

          // --- LAPISAN 3: TOMBOL KONTROL ATAS & BAWAH ---
          if (state.isPickingWaypoint)
            _buildPickingUI(context, ref, notifier)
          else
            _buildTrackingUI(context, ref, state, notifier),
        ],
      ),
    );
  }

  // --- WIDGET BARU: UI UNTUK MODE PILIH PETA ---
  Widget _buildPickingUI(BuildContext context, WidgetRef ref, MapNotifier notifier) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 16,
            child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                notifier.exitWaypointPickMode();
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Geser peta untuk memposisikan pin',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FloatingActionButton.extended(
                    heroTag: 'save_pick',
                    onPressed: () {
                      final LatLng pickedLocation = _mapController.camera.center;
                      _showAddWaypointDialog(context, ref, notifier, tappedLatLng: pickedLocation);
                      notifier.exitWaypointPickMode(); 
                    },
                    backgroundColor: Colors.blueAccent,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('TANDAI DI SINI', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LAMA (DIPINDAH): UI UNTUK TRACKING NORMAL ---
  Widget _buildTrackingUI(BuildContext context, WidgetRef ref, MapTrackingState state, MapNotifier notifier) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 16,
            child: IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                if (state.isTracking && !state.isPaused) {
                  _showExitConfirmationDialog(context);
                } else {
                  context.go('/home'); 
                }
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isTracking) _buildLiveStatsDashboard(context, state),
                const SizedBox(height: 20),
                
                // --- KONTROL TOMBOL UTAMA ---
                // Jika sedang tracking, TAMPILKAN KONTROL
                if (state.isTracking)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'poi_button',
                        onPressed: state.isPaused
                            ? null
                            : () {
                                _showWaypointSourceDialog(context, ref, notifier);
                              },
                        backgroundColor: state.isPaused
                            ? Colors.grey
                            : Colors.blueAccent,
                        child: const Icon(Icons.location_pin),
                      ),
                      FloatingActionButton(
                        heroTag: 'pause_button',
                        onPressed: () {
                          if (state.isPaused) {
                            notifier.resumeTracking();
                          } else {
                            notifier.pauseTracking();
                          }
                        },
                        backgroundColor: state.isPaused
                            ? Colors.orange
                            : Colors.grey[700],
                        child: Icon(
                          state.isPaused ? Icons.play_arrow : Icons.pause,
                        ),
                      ),
                      FloatingActionButton.large(
                        heroTag: 'stop_button',
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          try {
                            final Hike? finishedHike = await notifier
                                .stopTrackingAndGetHike();
                            if (finishedHike != null && context.mounted) {
                              context.go('/home/edit_hike', extra: finishedHike); 
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('SELESAI'),
                      ),
                    ],
                  )
                // Jika TIDAK tracking DAN TIDAK sedang memilih, TAMPILKAN MULAI
                // (Ini mencegah tombol "MULAI" muncul sesaat saat dialog resume tampil)
                else if (!state.isTracking && !state.isPickingWaypoint)
                  SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton.large(
                      heroTag: 'start_button',
                      onPressed: () async {
                        try {
                          await notifier.startTracking();
                        } catch (e, st) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('MULAI TRACKING'),
                    ),
                  ),
                // --- AKHIR KONTROL TOMBOL UTAMA ---
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG SUMBER WAYPOINT ---
  void _showWaypointSourceDialog(BuildContext context, WidgetRef ref, MapNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.blue),
            title: const Text('Tambah Lokasi Saat Ini'),
            subtitle: const Text('Menandai posisi Anda sekarang'),
            onTap: () {
              Navigator.of(ctx).pop(); 
              _showAddWaypointDialog(context, ref, notifier, tappedLatLng: null);
            },
          ),
          ListTile(
            leading: const Icon(Icons.push_pin, color: Colors.red),
            title: const Text('Pilih dari Peta'),
            subtitle: const Text('Menandai titik di peta secara manual'),
            onTap: () {
              Navigator.of(ctx).pop(); 
              notifier.enterWaypointPickMode(); 
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- DIALOG TAMBAH WAYPOINT (LENGKAP DENGAN FOTO) ---
  void _showAddWaypointDialog(
    BuildContext context, 
    WidgetRef ref,
    MapNotifier notifier,
    { required LatLng? tappedLatLng }
  ) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    String? selectedCategory; 
    final categories = {
      'POS': 'Pos Pendakian',
      'SUMBER_AIR': 'Sumber Air',
      'PUNCAK': 'Puncak',
      'CAMP': 'Area Camp',
      'LAINNYA': 'Lainnya',
    };
    XFile? _tempImageFile; 
    bool _isUploading = false; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            
            Future<void> _pickImage() async {
              final imagePicker = ImagePicker();
              
              final ImageSource? source = await showModalBottomSheet<ImageSource>(
                context: context,
                builder: (bottomSheetCtx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Ambil Foto (Kamera)'),
                      onTap: () => Navigator.of(bottomSheetCtx).pop(ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Pilih dari Galeri'),
                      onTap: () => Navigator.of(bottomSheetCtx).pop(ImageSource.gallery),
                    ),
                  ],
                ),
              );

              if (source == null) return;

              try {
                final XFile? imageFile = await imagePicker.pickImage(
                  source: source, imageQuality: 80,
                );
                
                if (imageFile == null) return;

                setDialogState(() {
                  _tempImageFile = imageFile;
                });
              } catch (e) {
                print("[MapPage] Gagal ambil gambar: $e");
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red)
                  );
                }
              }
            }
            
            Future<String> _uploadToStorage(XFile imageFile, String userId, int localHikeId) async {
              final supabase = Supabase.instance.client;
              final file = File(imageFile.path);
              final fileExtension = imageFile.path.split('.').last.toLowerCase();
              final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
              final path = '$userId/$localHikeId/$fileName'; 
              await supabase.storage.from('hike_photos').upload(path, file);
              final publicUrl = supabase.storage.from('hike_photos').getPublicUrl(path);
              return publicUrl;
            }

            return AlertDialog(
              title: Text(tappedLatLng == null 
                  ? 'Tandai Lokasi (POI)' 
                  : 'Tandai Pilihan Peta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField( controller: nameController, autofocus: true, decoration: const InputDecoration( hintText: 'Contoh: Pos 1, Sumber Air', labelText: 'Nama Lokasi', border: OutlineInputBorder(), ), readOnly: _isUploading, ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>( value: selectedCategory, isExpanded: true, decoration: const InputDecoration( labelText: 'Kategori', border: OutlineInputBorder(), ), hint: const Text('Pilih Kategori'), items: categories.entries.map((entry) { return DropdownMenuItem( value: entry.key, child: Text(entry.value), ); }).toList(), onChanged: _isUploading ? null : (value) { setDialogState(() { selectedCategory = value; }); }, ),
                    const SizedBox(height: 16),
                    TextField( controller: descController, maxLines: 2, decoration: const InputDecoration( hintText: 'Opsional', labelText: 'Deskripsi', border: OutlineInputBorder(), ), readOnly: _isUploading, ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration( border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: _isUploading ? Colors.grey.shade100 : Colors.white, ),
                      child: _tempImageFile == null
                        ? InkWell(
                            onTap: _isUploading ? null : _pickImage,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600),
                                const SizedBox(height: 8),
                                Text('Tambah Foto (Opsional)', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(_tempImageFile!.path), fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: InkWell(
                                  onTap: _isUploading ? null : () => setDialogState(() => _tempImageFile = null),
                                  child: Container(
                                    decoration: BoxDecoration( color: Colors.black.withOpacity(0.6), shape: BoxShape.circle, ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              )
                            ],
                          ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUploading ? null : () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: _isUploading ? null : () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar( const SnackBar(content: Text('Nama Lokasi wajib diisi'), backgroundColor: Colors.orange), );
                      return;
                    }
                    setDialogState(() => _isUploading = true);
                    try {
                      final hikeId = ref.read(mapNotifierProvider).currentHikeId;
                      if (hikeId == null) throw Exception("Hike ID tidak ditemukan");

                      final HikeWaypoint? newWaypoint = await notifier.addWaypoint(
                        nameController.text.trim(),
                        descController.text.trim().isEmpty ? null : descController.text.trim(),
                        selectedCategory,
                        tappedLatLng,
                      );
                      if (newWaypoint == null) throw Exception("Gagal menyimpan waypoint");

                      if (_tempImageFile != null) {
                        final userId = ref.read(authStateProvider).value!.id;
                        final photoDao = ref.read(hikePhotoDaoProvider);
                        final photoUrl = await _uploadToStorage(_tempImageFile!, userId, hikeId);
                        final photoEntry = HikePhotosCompanion(
                          hikeId: d.Value(hikeId),
                          waypointId: d.Value(newWaypoint.id),
                          photoUrl: d.Value(photoUrl),
                          syncStatus: const d.Value(SyncStatus.pending),
                        );
                        await photoDao.insertHikePhoto(photoEntry);
                      }
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar( content: Text('POI "${nameController.text}" disimpan'), duration: const Duration(seconds: 2), ),
                          );
                        }
                      }
                    } catch (e) {
                      setDialogState(() => _isUploading = false);
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: _isUploading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- FUNGSI HELPER IKON KATEGORI ---
  static IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'POS': return Icons.signpost_outlined;
      case 'SUMBER_AIR': return Icons.water_drop_outlined;
      case 'PUNCAK': return Icons.flag_outlined;
      case 'CAMP': return Icons.local_fire_department_outlined;
      default: return Icons.location_pin;
    }
  }

  // --- FUNGSI HELPER STATS DASHBOARD ---
  Widget _buildLiveStatsDashboard( BuildContext context, MapTrackingState state, ) {
    final duration = state.liveDuration;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatColumn( context, (state.liveDistanceMeters / 1000).toStringAsFixed(2), 'km', ),
            _buildStatColumn(context, '$hours:$minutes:$seconds', 'Waktu'),
            _buildStatColumn( context, state.liveElevationGainMeters.toStringAsFixed(0), 'm Naik', ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI HELPER STATS KOLOM ---
  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text( value, style: Theme.of( context, ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), ),
        const SizedBox(height: 4),
        Text( label, style: Theme.of(context).textTheme.bodySmall, ),
      ],
    );
  }

  // --- DIALOG KONFIRMASI KELUAR ---
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Batalkan Tracking?'),
          content: const Text( 'Anda masih melakukan tracking. Apakah Anda yakin ingin membatalkan?', ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Lanjutkan Tracking'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/home');
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}