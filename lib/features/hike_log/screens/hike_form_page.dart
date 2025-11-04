import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:drift/drift.dart' as d;
import 'package:image_picker/image_picker.dart';
import 'package:jejak_faa_new/features/hike_log/providers/hike_photo_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jejak_faa_new/data/local_db/daos/hike_photo_dao.dart';

class HikeFormPage extends ConsumerStatefulWidget {
  final Hike? hikeToEdit;
  const HikeFormPage({super.key, this.hikeToEdit});

  @override
  ConsumerState<HikeFormPage> createState() => _HikeFormPageState();
}

class _HikeFormPageState extends ConsumerState<HikeFormPage> {
  final _mountainNameController = TextEditingController();
  final _durationController = TextEditingController(); 
  final _partnersController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false; 
  bool _isUploading = false; 
  List<XFile> _temporaryImages = [];

  bool get _isEditMode => widget.hikeToEdit != null;
  int? get _localHikeId => widget.hikeToEdit?.id;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final hike = widget.hikeToEdit!;
      _mountainNameController.text = hike.mountainName;
      _selectedDate = hike.hikeDate;
      // Baca dari 'durationSeconds'
      _durationController.text = hike.durationSeconds?.toString() ?? '';
      _partnersController.text = hike.partners ?? '';
      _notesController.text = hike.notes ?? '';
    }
  }

  Future<void> _saveOrUpdateHike() async {
    if (_mountainNameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama gunung & Tanggal wajib diisi')),
      );
      return;
    }
    // "duration" sekarang adalah detik
    final int? duration = int.tryParse(_durationController.text);
    if (_durationController.text.isNotEmpty && duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durasi harus berupa angka (detik)')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final userId = ref.read(authStateProvider).value?.id;
      if (userId == null) throw Exception('User tidak login!');

      // Logika "pintar" untuk sync status
      SyncStatus newSyncStatus;
      if (!_isEditMode) {
        newSyncStatus = SyncStatus.pending;
      } else {
        final currentHike = widget.hikeToEdit;
        if (currentHike == null) throw Exception("Hike to edit is null");
        final currentStatus = currentHike.syncStatus;
        if (currentStatus == SyncStatus.synced) {
          newSyncStatus = SyncStatus.pending_update;
        } else {
          newSyncStatus = currentStatus;
        }
      }

      final hikeEntry = HikesCompanion(
        id: _isEditMode
            ? d.Value(widget.hikeToEdit!.id)
            : const d.Value.absent(),
        userId: d.Value(userId),
        mountainName: d.Value(_mountainNameController.text),
        hikeDate: d.Value(_selectedDate!),
        
        // Simpan ke 'durationSeconds'
        durationSeconds: d.Value(duration),
        
        partners: d.Value(
          _partnersController.text.isEmpty ? null : _partnersController.text,
        ),
        notes: d.Value(
          _notesController.text.isEmpty ? null : _notesController.text,
        ),
        syncStatus: d.Value(newSyncStatus),
        isDeleted: _isEditMode
            ? d.Value(widget.hikeToEdit!.isDeleted)
            : const d.Value(false),
        cloudId: _isEditMode
            ? d.Value(widget.hikeToEdit!.cloudId)
            : const d.Value.absent(),
            
        // --- PERBAIKAN: Salin SEMUA field statistik ---
        totalDistanceKm: _isEditMode
            ? d.Value(widget.hikeToEdit!.totalDistanceKm)
            : const d.Value.absent(),
        totalElevationGainMeters: _isEditMode
            ? d.Value(widget.hikeToEdit!.totalElevationGainMeters)
            : const d.Value.absent(),
        totalElevationLossMeters: _isEditMode
            ? d.Value(widget.hikeToEdit!.totalElevationLossMeters)
            : const d.Value.absent(),
        // Ganti 'averageSpeedKmh' dengan 'averagePaceMinPerKm'
        averagePaceMinPerKm: _isEditMode 
            ? d.Value(widget.hikeToEdit!.averagePaceMinPerKm) 
            : const d.Value.absent(),
        maxSpeedKmh: _isEditMode
            ? d.Value(widget.hikeToEdit!.maxSpeedKmh)
            : const d.Value.absent(),
        startWeatherCondition: _isEditMode
            ? d.Value(widget.hikeToEdit!.startWeatherCondition)
            : const d.Value.absent(),
        startTemperature: _isEditMode
            ? d.Value(widget.hikeToEdit!.startTemperature)
            : const d.Value.absent(),
        // --- AKHIR PERBAIKAN ---
      );

      final hikeDao = ref.read(hikeDaoProvider);
      final photoDao = ref.read(hikePhotoDaoProvider);
      int savedHikeId; 

      if (_isEditMode) {
        await hikeDao.updateHike(hikeEntry);
        savedHikeId = widget.hikeToEdit!.id;
        print('[Form] Jejak berhasil diperbarui (ID Lokal: $savedHikeId).');
      } else {
        final insertedHike = await hikeDao.insertHike(hikeEntry);
        savedHikeId = insertedHike.id;
        print('[Form] Jejak baru berhasil disimpan (ID Lokal: $savedHikeId).');
      }

      if (_temporaryImages.isNotEmpty) {
        print(
          '[Form] Memulai upload ${_temporaryImages.length} foto sementara...',
        );
        for (final imageFile in _temporaryImages) {
          final photoUrl = await _uploadToStorage(
            imageFile,
            userId,
            savedHikeId,
          );
          final photoEntry = HikePhotosCompanion(
            hikeId: d.Value(savedHikeId),
            photoUrl: d.Value(photoUrl),
            syncStatus: const d.Value(SyncStatus.pending),
            waypointId: const d.Value(null), 
          );
          await photoDao.insertHikePhoto(photoEntry);
          print('[Form] Foto ${imageFile.name} berhasil disimpan ke lokal.');
        }
        _temporaryImages = [];
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jejak berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal ${_isEditMode ? 'memperbarui' : 'menyimpan'}: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // ... (Fungsi _pickDate, _pickImage, _uploadToStorage, dispose TETAP SAMA) ...
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? imageFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imageFile == null) return;

    if (_isEditMode) {
      setState(() {
        _isUploading = true;
      });
      try {
        final userId = ref.read(authStateProvider).value!.id;
        final photoUrl = await _uploadToStorage(
          imageFile,
          userId,
          _localHikeId!,
        );
        final photoEntry = HikePhotosCompanion(
          hikeId: d.Value(_localHikeId!),
          photoUrl: d.Value(photoUrl),
          syncStatus: const d.Value(SyncStatus.pending),
        );
        await ref.read(hikePhotoDaoProvider).insertHikePhoto(photoEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } else {
      setState(() {
        _temporaryImages.add(imageFile);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto ditambahkan ke antrian.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<String> _uploadToStorage(
    XFile imageFile,
    String userId,
    int localHikeId,
  ) async {
    final file = File(imageFile.path);
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final path = '$userId/$localHikeId/$fileName';
    await Supabase.instance.client.storage
        .from('hike_photos')
        .upload(path, file);
    final publicUrl = Supabase.instance.client.storage
        .from('hike_photos')
        .getPublicUrl(path);
    return publicUrl;
  }

  @override
  void dispose() {
    _mountainNameController.dispose();
    _durationController.dispose();
    _partnersController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Pilih tanggal...'
        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Jejak Pendakian' : 'Catatan Pendakian Baru',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Nama Gunung, Tanggal) ...
            Text( 'Nama Gunung 🏔️', style: Theme.of(context).textTheme.titleMedium, ),
            const SizedBox(height: 8),
            TextField( controller: _mountainNameController, decoration: const InputDecoration( hintText: 'Misal: Gunung Slamet', border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(12.0)), ), ), ),
            const SizedBox(height: 24),
            Text( 'Tanggal Pendakian 📅', style: Theme.of(context).textTheme.titleMedium, ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration( border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12.0), ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _selectedDate == null ? Colors.grey.shade600 : null,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    Icon( Icons.calendar_month_outlined, color: Colors.grey.shade600, ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- PERUBAHAN LABEL DURASI ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durasi (Detik) ⏱️', // Ganti label
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Misal: 3600', // Ganti hint
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( 'Partner 🧑‍🤝‍🧑', style: Theme.of(context).textTheme.titleMedium, ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _partnersController,
                        decoration: const InputDecoration(
                          hintText: 'Misal: Budi, Ani',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // --- AKHIR PERUBAHAN LABEL ---
            
            const SizedBox(height: 24),
            Text( 'Catatan ✍️ (Opsional)', style: Theme.of(context).textTheme.titleMedium, ),
            const SizedBox(height: 8),
            TextField( controller: _notesController, decoration: const InputDecoration( hintText: 'Tulis ceritamu di sini...', border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(12.0)), ), ), maxLines: 5, ),

            // ... (Sisa kode build Anda: Galeri, Tombol Simpan, dll. TETAP SAMA) ...
            const Divider(height: 48),
            Text( 'Galeri Jejak 📸', style: Theme.of(context).textTheme.titleMedium, ),
            const SizedBox(height: 16),
            if (_isEditMode) _buildSavedPhotoGallery(),
            if (_temporaryImages.isNotEmpty) _buildTemporaryPhotoGallery(),
            if (!_isEditMode && _temporaryImages.isEmpty)
              Center(
                child: Text( 'Belum ada foto.', style: TextStyle(color: Colors.grey[600]), ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: _isUploading
                    ? const SizedBox( width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2), )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text( _isUploading ? 'Mengupload...' : 'Tambah Foto dari Galeri', ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(16), ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveOrUpdateHike,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D3B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(16), ),
                ),
                child: _isLoading
                    ? const SizedBox( height: 24, width: 24, child: CircularProgressIndicator( color: Colors.white, strokeWidth: 3,), )
                    : Text(
                        _isEditMode ? 'Update Jejak' : 'Simpan Jejak',
                        style: const TextStyle( fontSize: 16, fontWeight: FontWeight.bold, ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Sisa kode _buildSavedPhotoGallery dan _buildTemporaryPhotoGallery TETAP SAMA) ...
  Widget _buildSavedPhotoGallery() {
    final photosAsync = ref.watch(hikePhotosProvider(_localHikeId!));
    return photosAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, s) => Center(
        child: Text(
          'Gagal memuat foto: $e',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (photos) {
        if (photos.isEmpty && _temporaryImages.isEmpty) {
          if (_isEditMode) {
            return Center(
              child: Text(
                'Belum ada foto.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        if (photos.isEmpty)
          return const SizedBox.shrink(); 
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                photo.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemporaryPhotoGallery() {
    if (_temporaryImages.isEmpty) return const SizedBox.shrink();
    final bool needsSpacing =
        _isEditMode &&
        ref.watch(hikePhotosProvider(_localHikeId!)).hasValue &&
        ref.watch(hikePhotosProvider(_localHikeId!)).value!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(top: needsSpacing ? 16.0 : 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: _temporaryImages.length,
        itemBuilder: (context, index) {
          final imageFile = _temporaryImages[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(File(imageFile.path), fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _temporaryImages.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}