import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/features/gallery/providers/gallery_provider.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/features/hike_log/providers/hike_list_provider.dart';
import 'package:jejak_faa_new/features/gallery/screens/photo_detail_page.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';

// --- STATE DEFINITIONS ---
enum SortType { dateDesc, dateAsc }

final sortTypeProvider = StateProvider<SortType>((ref) => SortType.dateDesc);
final galleryFilterProvider = StateProvider<String>((ref) => 'ALL');

// --- PROVIDER: FILTERED & SORTED PHOTOS ---
final filteredGalleryProvider = Provider<List<HikePhoto>>((ref) {
  final allPhotos = ref.watch(allPhotosProvider).valueOrNull ?? [];
  final filter = ref.watch(galleryFilterProvider);
  final sort = ref.watch(sortTypeProvider);

  // Filter out waypoint photos and apply UI filter
  final List<HikePhoto> generalPhotos = allPhotos
      .where((photo) => photo.waypointId == null)
      .toList();

  List<HikePhoto> filteredList;
  if (filter == 'ALL') {
    filteredList = List.of(generalPhotos);
  } else if (filter == 'LOCAL') {
    filteredList = generalPhotos
        .where((photo) => photo.syncStatus == SyncStatus.pending)
        .toList();
  } else {
    final filterId = int.tryParse(filter) ?? -1;
    filteredList = generalPhotos
        .where((photo) => photo.hikeId == filterId)
        .toList();
  }

  // Sort by date
  return [...filteredList]..sort((a, b) {
    final dateA = a.capturedAt ?? DateTime(1970);
    final dateB = b.capturedAt ?? DateTime(1970);
    
    if (sort == SortType.dateAsc) {
      return dateA.compareTo(dateB);
    } else {
      return dateB.compareTo(dateA);
    }
  });
});

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    final currentSort = ref.watch(sortTypeProvider);
    final currentFilter = ref.watch(galleryFilterProvider);
    final allPhotosAsync = ref.watch(allPhotosProvider);
    final filteredPhotos = ref.watch(filteredGalleryProvider);
    final hikeList = ref.watch(hikeListStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Galeri Jejak',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          _buildFilterButton(hikeList, currentFilter),
          _buildSortButton(currentSort),
        ],
      ),
      body: allPhotosAsync.when(
        loading: () => const _GalleryLoadingState(),
        error: (err, stack) => _GalleryErrorState(error: err.toString()),
        data: (photos) {
          if (filteredPhotos.isEmpty) {
            return _GalleryEmptyState(currentFilter: currentFilter);
          }
          return _GalleryContent(filteredPhotos: filteredPhotos);
        },
      ),
    );
  }

  Widget _buildFilterButton(AsyncValue<List<Hike>> hikeList, String currentFilter) {
    return hikeList.when(
      data: (hikes) {
        String activeFilterName;
        if (currentFilter == 'ALL') {
          activeFilterName = "Semua";
        } else if (currentFilter == 'LOCAL') {
          activeFilterName = "Lokal";
        } else {
          final filterId = int.tryParse(currentFilter);
          activeFilterName = hikes
              .firstWhere(
                (h) => h.id == filterId,
                orElse: () => Hike(
                  id: -1,
                  userId: '',
                  mountainName: '...',
                  cloudId: '',
                  hikeDate: DateTime.now(),
                  syncStatus: SyncStatus.pending,
                  isDeleted: false,
                ),
              )
              .mountainName;
        }

        return IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A535C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: const Color(0xFF1A535C),
              size: 20,
            ),
          ),
          onPressed: () {
            _showFilterBottomSheet(hikes, currentFilter);
          },
        );
      },
      error: (err, stack) => IconButton(
        onPressed: null,
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ),
      ),
      loading: () => IconButton(
        onPressed: null,
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton(SortType currentSort) {
    return IconButton(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A535C).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          currentSort == SortType.dateDesc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: const Color(0xFF1A535C),
          size: 20,
        ),
      ),
      onPressed: () {
        final newSort = currentSort == SortType.dateDesc ? SortType.dateAsc : SortType.dateDesc;
        ref.read(sortTypeProvider.notifier).state = newSort;
      },
    );
  }

  void _showFilterBottomSheet(List<Hike> hikes, String currentFilter) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true, // Tambahkan ini untuk bottom sheet yang bisa di-scroll
    builder: (ctx) {
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8, // Batasi tinggi maksimum
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Galeri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter options utama (fixed height)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterOption(
                      value: 'ALL',
                      label: 'Semua Foto',
                      isSelected: currentFilter == 'ALL',
                    ),
                    _buildFilterOption(
                      value: 'LOCAL',
                      label: 'Foto Lokal',
                      isSelected: currentFilter == 'LOCAL',
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Text(
                  'Filter Berdasarkan Gunung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                
                // List gunung dengan scrollable
                Expanded( // Tambahkan Expanded di sini
                  child: ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: hikes.map((hike) => _buildFilterOption(
                      value: hike.id.toString(),
                      label: hike.mountainName,
                      isSelected: currentFilter == hike.id.toString(),
                    )).toList(),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildFilterOption({
    required String value,
    required String label,
    required bool isSelected,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A535C) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF1A535C) : const Color(0xFFE0E0E0),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      onTap: () {
        ref.read(galleryFilterProvider.notifier).state = value;
        Navigator.of(context).pop();
      },
    );
  }
}

class _GalleryContent extends StatelessWidget {
  final List<HikePhoto> filteredPhotos;

  const _GalleryContent({required this.filteredPhotos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredPhotos.length,
      itemBuilder: (context, index) {
        final photo = filteredPhotos[index];
        final heroTag = photo.id.toString();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      photo.photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gagal memuat',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Sync status indicator
                    if (photo.syncStatus == SyncStatus.pending)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Lokal',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GalleryLoadingState extends StatelessWidget {
  const _GalleryLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1A535C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.photo_library_rounded,
              size: 40,
              color: const Color(0xFF1A535C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat Galeri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mengambil foto-foto pendakian Anda',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryErrorState extends StatelessWidget {
  final String error;

  const _GalleryErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE07A5F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: const Color(0xFFE07A5F),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal Memuat Galeri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement retry functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A535C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _GalleryEmptyState extends StatelessWidget {
  final String currentFilter;

  const _GalleryEmptyState({required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A535C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: const Color(0xFF1A535C),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentFilter == 'ALL' ? 'Galeri Masih Kosong' : 'Tidak Ada Foto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              currentFilter == 'ALL'
                  ? 'Mulai petualangan Anda dan abadikan momen melalui fitur tracking atau tambahkan foto di halaman detail jejak'
                  : 'Tidak ada foto yang sesuai dengan filter yang dipilih',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}