import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart'; // Asumsi 1
import 'package:photo_view/photo_view.dart';
import 'package:drift/drift.dart' as d;

class PhotoDetailPage extends ConsumerWidget {
  final HikePhoto photo;
  final String photoUrl;
  final String heroTag;

  const PhotoDetailPage({
    super.key,
    required this.photo,
    required this.photoUrl,
    required this.heroTag,
  });

  // --- Fungsi untuk Hapus Foto (Soft Delete) ---
  Future<void> _deletePhoto(BuildContext context, WidgetRef ref) async {
    // 1. Tampilkan dialog konfirmasi
    final bool? didConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Anda yakin ingin menghapus foto ini? Tindakan ini akan menandai foto untuk dihapus saat sinkronisasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Konfirmasi
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // 2. Jika tidak dikonfirmasi, hentikan
    if (didConfirm != true) {
      return;
    }

    // 3. Jika dikonfirmasi, lakukan soft delete
    try {
      // Ambil DAO dari provider (Asumsi 1)
      final dao = ref.read(hikePhotoDaoProvider);
      
      // Panggil method update dari DAO
      // FIX: Gunakan .where() untuk mencari ID,
      // dan .write() untuk update field 'isDeleted' SAJA.
      // Ini menghindari error validasi 'required field'.
      await (dao.update(dao.hikePhotos)
            ..where((tbl) => tbl.id.equals(photo.id)))
          .write(const HikePhotosCompanion(
        isDeleted: d.Value(true),
      ));

      // Tampilkan pesan sukses
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil ditandai untuk dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        // Tutup halaman detail
        Navigator.pop(context); 
      }
    } catch (e) {
      // Tampilkan pesan error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // Buat AppBar transparan
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Hapus
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Hapus Foto',
            onPressed: () => _deletePhoto(context, ref), // Panggil fungsi hapus
          ),
        ],
      ),
      // Agar AppBar 'mengambang' di atas gambar
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.black,
      body: Hero(
        tag: heroTag,
        child: PhotoView(
          imageProvider: NetworkImage(photoUrl),
          // Tampilkan loading saat gambar besar dimuat
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(),
          ),
          // Tampilkan error jika gagal muat
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.white, size: 50),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

