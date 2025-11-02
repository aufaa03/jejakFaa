import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. IMPORT PROVIDER GALERI (dari file di Canvas)
import 'package:jejak_faa_new/features/gallery/providers/gallery_provider.dart';
// 2. IMPORT MODEL DARI DRIFT (ASUMSI 2)
import 'package:jejak_faa_new/data/local_db/database.dart';
// 3. IMPORT PROVIDER HIKE (ASUMSI 1)
import 'package:jejak_faa_new/features/hike_log/providers/hike_list_provider.dart';
// 4. IMPORT HALAMAN DETAIL (file kedua di bawah)
import 'package:jejak_faa_new/features/gallery/screens/photo_detail_page.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
// --- DEFINISI STATE UNTUK SORTIR ---
// (Menggunakan 'capturedAt' dari HikePhoto)
enum SortType { dateDesc, dateAsc }
final sortTypeProvider = StateProvider<SortType>((ref) => SortType.dateDesc);

// --- DEFINISI STATE UNTUK FILTER ---
// 'ALL' = Semua foto
// 'LOCAL' = Foto lokal (syncStatus == 'pending')
// 'hike_id_int' = Foto dari gunung tertentu (berdasarkan ID lokal 'Hikes')
final galleryFilterProvider = StateProvider<String>((ref) => 'ALL');

// --- PROVIDER BARU: FOTO YANG SUDAH DIFILTER & DISORTIR ---
final filteredGalleryProvider = Provider<List<HikePhoto>>((ref) {
  // 1. Tonton provider 'allPhotosProvider' (ini masih mengambil SEMUA foto)
  final allPhotos = ref.watch(allPhotosProvider).valueOrNull ?? [];
  
  // 2. Tonton state filter & sortir (tidak berubah)
  final filter = ref.watch(galleryFilterProvider);
  final sort = ref.watch(sortTypeProvider);

  // --- 💡 PERBAIKAN: LANGKAH 1 (FILTER FOTO WAYPOINT) ---
  // Kita buat daftar foto "Umum" terlebih dahulu,
  // yaitu foto yang TIDAK terikat ke waypoint (waypointId == null).
  final List<HikePhoto> generalPhotos = allPhotos
      .where((photo) => photo.waypointId == null) // <-- INI FILTER UTAMANYA
      .toList();

  // --- 💡 PERBAIKAN: LANGKAH 2 (TERAPKAN FILTER UI) ---
  // Sekarang, terapkan filter 'ALL', 'LOCAL', atau 'hikeId' ke 'generalPhotos',
  // BUKAN ke 'allPhotos'.
  List<HikePhoto> filteredList;
  if (filter == 'ALL') {
    filteredList = List.of(generalPhotos); // <-- Menggunakan generalPhotos
  } else if (filter == 'LOCAL') {
    // FIX: Anda membandingkan dengan String 'pending', harusnya ENUM
    filteredList = generalPhotos // <-- Menggunakan generalPhotos
        .where((photo) => photo.syncStatus == SyncStatus.pending) 
        .toList();
  } else {
    // Filter berdasarkan ID (tidak berubah)
    final filterId = int.tryParse(filter) ?? -1;
    filteredList = generalPhotos // <-- Menggunakan generalPhotos
        .where((photo) => photo.hikeId == filterId)
        .toList();
  }

  // --- Langkah 3: Sortir (Kode Anda sudah benar) ---
  return [...filteredList]..sort((a, b) {
    // Gunakan field 'capturedAt' dari 'tables.dart' (bisa null)
    final dateA = a.capturedAt ?? DateTime(1970); // Default jika null
    final dateB = b.capturedAt ?? DateTime(1970); // Default jika null
    
    if (sort == SortType.dateAsc) {
      return dateA.compareTo(dateB); // Terlama
    } else {
      return dateB.compareTo(dateA); // Terbaru
    }
  });
});

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton state sortir & filter
    final currentSort = ref.watch(sortTypeProvider);
    final currentFilter = ref.watch(galleryFilterProvider);

    // Tonton data (hanya untuk loading/error state)
    final allPhotosAsync = ref.watch(allPhotosProvider);
    // Tonton data yang sudah diolah (untuk ditampilkan)
    final filteredPhotos = ref.watch(filteredGalleryProvider);

    // Tonton daftar gunung (untuk UI filter)
    // ASUMSI 1: hikeListProvider mengembalikan List<Hike> (dari Drift)
    final hikeList = ref.watch(hikeListStreamProvider);

    return Scaffold(
      // --- 5. APPBAR DENGAN FILTER & SORTIR ---
      appBar: AppBar(
        title: const Text("Foto Pendakian"),
        actions: [
          // --- Tombol Filter ---
          // Gunakan .when untuk handle loading/error list gunung
          hikeList.when(
            data: (hikes) {
              // Cari nama filter yang sedang aktif
              String activeFilterName;
              if (currentFilter == 'ALL') {
                activeFilterName = "Semua";
              } else if (currentFilter == 'LOCAL') {
                activeFilterName = "Lokal";
              } else {
                final filterId = int.tryParse(currentFilter);
                // Gunakan model Hike (dari Drift)
                // (Gunakan 'mountainName' dari 'tables.dart')
                activeFilterName = hikes
                    .firstWhere(
                      (h) => h.id == filterId, 
                      // Fallback jika ID tidak ditemukan
                      // FIX: Menambahkan parameter 'syncStatus' yang wajib ada
                      orElse: () => Hike(id: -1, userId: '', mountainName: '...', cloudId: '',hikeDate: DateTime.now(), syncStatus: SyncStatus.pending, isDeleted: false)
                    )
                    .mountainName;
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                tooltip: "Filter: $activeFilterName",
                onSelected: (value) {
                  ref.read(galleryFilterProvider.notifier).state = value;
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> menuItems = [];
                  
                  // Item Default
                  menuItems.add(PopupMenuItem(
                    value: 'ALL',
                    child: Text("Semua Foto", style: TextStyle(fontWeight: currentFilter == 'ALL' ? FontWeight.bold : FontWeight.normal)),
                  ));
                  menuItems.add(PopupMenuItem(
                    value: 'LOCAL',
                    child: Text("Lokal (Belum Sync)", style: TextStyle(fontWeight: currentFilter == 'LOCAL' ? FontWeight.bold : FontWeight.normal)),
                  ));
                  menuItems.add(const PopupMenuDivider());

                  // Tambah semua gunung dari provider (model Hike)
                  for (var hike in hikes) {
                    menuItems.add(PopupMenuItem(
                      // Gunakan ID (int) sebagai value, ubah ke String
                      value: hike.id.toString(), 
                      // Gunakan 'mountainName'
                      child: Text(hike.mountainName, style: TextStyle(fontWeight: currentFilter == hike.id.toString() ? FontWeight.bold : FontWeight.normal)),
                    ));
                  }
                  return menuItems;
                },
              );
            },
            // Tampilkan ikon disabled saat loading/error
            error: (err, stack) => const IconButton(onPressed: null, icon: Icon(Icons.error)),
            loading: () => const IconButton(onPressed: null, icon: Icon(Icons.filter_list_off, color: Colors.grey)),
          ),

          // --- Tombol Sortir ---
          // PopupMenuButton<SortType>(
          //   icon: const Icon(Icons.sort),
          //   tooltip: currentSort == SortType.dateDesc ? "Urutkan: Terbaru" : "Urutkan: Terlama",
          //   onSelected: (sort) {
          //     ref.read(sortTypeProvider.notifier).state = sort;
          //   },
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: SortType.dateDesc,
          //       child: Text("Urutkan: Terbaru", style: TextStyle(fontWeight: currentSort == SortType.dateDesc ? FontWeight.bold : FontWeight.normal)),
          //     ),
          //     PopupMenuItem(
          //       value: SortType.dateAsc,
          //       child: Text("Urutkan: Terlama", style: TextStyle(fontWeight: currentSort == SortType.dateAsc ? FontWeight.bold : FontWeight.normal)),
          //     ),
          //   ],
          // ),
        ],
      ),
      // --- END APPBAR ---

      // --- 6. BODY MENGGUNAKAN DATA BARU ---
      body: allPhotosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Gagal memuat galeri: $err\n\n$stack")), // Tambah stacktrace
        data: (photos) {
          
          // UI 'Kosong' yang lebih dinamis
          if (filteredPhotos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      currentFilter == 'ALL' ? 'Galeri Masih Kosong' : 'Tidak Ada Foto',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentFilter == 'ALL' 
                        ? 'Upload foto di halaman Jejak Pendakian untuk melihatnya di sini.'
                        : 'Tidak ada foto yang cocok dengan filter yang Anda pilih.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          // GridView + tap + Hero
          return GridView.builder(
            padding: const EdgeInsets.all(8.0), 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredPhotos.length,
            itemBuilder: (context, index) {
              final photo = filteredPhotos[index];
              
              // Hero tag harus unik. Gunakan ID lokal (int) -> String.
              final heroTag = photo.id.toString(); 
              
              return GestureDetector(
                onTap: () {
                  // Buka halaman detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // FIX: Tambahkan parameter photoUrl dan heroTag
                      builder: (context) => PhotoDetailPage(
                        photo: photo,
                        photoUrl: photo.photoUrl,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      photo.photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

