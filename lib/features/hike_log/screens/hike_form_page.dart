import 'dart:io';
import 'package:intl/intl.dart';
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
  final _partnersController = TextEditingController();
  final _notesController = TextEditingController();
  final _jarakController = TextEditingController();
  final _tanjakanController = TextEditingController();
  int? _durationInSeconds;
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
      _durationInSeconds = hike.durationSeconds;
      _partnersController.text = hike.partners ?? '';
      _notesController.text = hike.notes ?? '';
      _jarakController.text = hike.totalDistanceKm?.toString() ?? '';
      _tanjakanController.text = hike.totalElevationGainMeters?.toString() ?? '';
    }
  }

  Future<void> _saveOrUpdateHike() async {
    if (_mountainNameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama gunung & tanggal wajib diisi'),
          backgroundColor: const Color(0xFFE07A5F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final double? jarakKm = double.tryParse(_jarakController.text);
    final double? tanjakanM = double.tryParse(_tanjakanController.text);
    
    if (_jarakController.text.isNotEmpty && jarakKm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Format jarak salah (contoh: 10.5)'),
          backgroundColor: const Color(0xFFE07A5F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    if (_tanjakanController.text.isNotEmpty && tanjakanM == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Format tanjakan salah (contoh: 1200)'),
          backgroundColor: const Color(0xFFE07A5F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final userId = ref.read(authStateProvider).value?.id;
      if (userId == null) throw Exception('User tidak login!');

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
        durationSeconds: d.Value(_durationInSeconds),
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
        totalDistanceKm: d.Value(jarakKm), 
        totalElevationGainMeters: d.Value(tanjakanM),
        totalElevationLossMeters: _isEditMode
            ? d.Value(widget.hikeToEdit!.totalElevationLossMeters)
            : const d.Value.absent(),
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
      );

      final hikeDao = ref.read(hikeDaoProvider);
      final photoDao = ref.read(hikePhotoDaoProvider);
      int savedHikeId; 

      if (_isEditMode) {
        await hikeDao.updateHike(hikeEntry);
        savedHikeId = widget.hikeToEdit!.id;
      } else {
        final insertedHike = await hikeDao.insertHike(hikeEntry);
        savedHikeId = insertedHike.id;
      }

      if (_temporaryImages.isNotEmpty) {
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
        }
        _temporaryImages = [];
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jejak berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
            ),
            backgroundColor: const Color(0xFF1A535C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            backgroundColor: const Color(0xFFE07A5F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

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
      imageQuality: 85,
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
          waypointId: const d.Value(null),
        );
        await ref.read(hikePhotoDaoProvider).insertHikePhoto(photoEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto berhasil ditambahkan!'),
            backgroundColor: const Color(0xFF1A535C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: const Color(0xFFE07A5F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        SnackBar(
          content: const Text('Foto ditambahkan ke antrian'),
          backgroundColor: const Color(0xFF1A535C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    _partnersController.dispose();
    _notesController.dispose();
    _jarakController.dispose();
    _tanjakanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Pilih tanggal'
        : DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF1A535C)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditMode ? 'Edit Jejak' : 'Jejak Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A535C),
                    Color(0xFF4ECDC4),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.terrain_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? 'Edit Jejak Pendakian' : 'Catatan Jejak Baru',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Isi detail petualangan Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Mountain Name
            Text(
              'Nama Gunung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _mountainNameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Gunung Rinjani',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date and Duration Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDatePicker(dateText),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDurationPicker(),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Distance and Elevation Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jarak (km)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _jarakController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: '0.0',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF1A1A1A),
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
                      Text(
                        'Tanjakan (m)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _tanjakanController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Partners
            Text(
              'Partner Pendakian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _partnersController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Budi, Ani, Cici',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notes
            Text(
              'Catatan Perjalanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ceritakan pengalaman pendakian Anda...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Gallery Section
            Text(
              'Galeri Jejak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),

            if (_isEditMode) _buildSavedPhotoGallery(),
            if (_temporaryImages.isNotEmpty) _buildTemporaryPhotoGallery(),
            if (!_isEditMode && _temporaryImages.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada foto',
                        style: TextStyle(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Add Photo Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_isUploading ? 'Mengupload...' : 'Tambah Foto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A535C),
                  side: const BorderSide(color: Color(0xFF1A535C)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveOrUpdateHike,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A535C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Perbarui Jejak' : 'Simpan Jejak',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String dateText) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate == null 
                    ? const Color(0xFF999999)
                    : const Color(0xFF1A1A1A),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: const Color(0xFF1A535C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    return GestureDetector(
      onTap: _pickDuration,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_durationInSeconds),
              style: TextStyle(
                fontSize: 16,
                color: _durationInSeconds == null 
                    ? const Color(0xFF999999)
                    : const Color(0xFF1A1A1A),
              ),
            ),
            Icon(
              Icons.timer_outlined,
              color: const Color(0xFF1A535C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPhotoGallery() {
    final photosAsync = ref.watch(hikePhotosProvider(_localHikeId!));
    return photosAsync.when(
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Gagal memuat foto',
            style: TextStyle(color: const Color(0xFF666666)),
          ),
        ),
      ),
      data: (photos) {
        if (photos.isEmpty && _temporaryImages.isEmpty) {
          return const SizedBox.shrink();
        }
        if (photos.isEmpty) return const SizedBox.shrink();
        
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
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                photo.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFF0F0F0),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF0F0F0),
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey.shade400,
                    ),
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
    
    return GridView.builder(
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
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imageFile.path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
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
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds == 0) return 'Pilih durasi';
    
    final duration = Duration(seconds: totalSeconds);
    final int days = duration.inDays;
    final int hours = duration.inHours.remainder(24);
    final int minutes = duration.inMinutes.remainder(60);

    final List<String> parts = [];
    if (days > 0) parts.add('${days}h');
    if (hours > 0) parts.add('${hours}j');
    if (minutes > 0) parts.add('${minutes}m');

    return parts.join(' ').isEmpty ? '0m' : parts.join(' ');
  }

  Future<void> _pickDuration() async {
    final newDurationInSeconds = await showDialog<int>(
      context: context,
      builder: (ctx) => _DurationPickerDialog(initialSeconds: _durationInSeconds ?? 0),
    );

    if (newDurationInSeconds != null) {
      setState(() {
        _durationInSeconds = newDurationInSeconds;
      });
    }
  }
}

class _DurationPickerDialog extends StatefulWidget {
  final int initialSeconds;
  const _DurationPickerDialog({required this.initialSeconds});

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _daysController = TextEditingController();
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();

    if (widget.initialSeconds > 0) {
      final duration = Duration(seconds: widget.initialSeconds);
      final days = duration.inDays;
      final hours = duration.inHours.remainder(24);
      final minutes = duration.inMinutes.remainder(60);

      if (days > 0) _daysController.text = days.toString();
      if (hours > 0) _hoursController.text = hours.toString();
      if (minutes > 0) _minutesController.text = minutes.toString();
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durasi Pendakian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Masukkan durasi pendakian Anda',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hari',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _hoursController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _minutesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A535C),
                      side: const BorderSide(color: Color(0xFF1A535C)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final int days = int.tryParse(_daysController.text) ?? 0;
                      final int hours = int.tryParse(_hoursController.text) ?? 0;
                      final int minutes = int.tryParse(_minutesController.text) ?? 0;
                      final totalSeconds = (days * 86400) + (hours * 3600) + (minutes * 60);
                      Navigator.of(context).pop(totalSeconds);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A535C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}