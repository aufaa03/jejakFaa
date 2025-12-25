// Salin ke: lib/features/profile/providers/profile_provider.dart
import 'package:jejak_faa_new/data/models/profile.dart';
import 'package:jejak_faa_new/main.dart'; // Impor supabase client
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart'; // <-- 1. IMPORT TAMBAHAN
import 'dart:io';
part 'profile_provider.g.dart';

// 1. Definisikan Notifier
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  // Ambil Supabase client
  final _client = supabase;

  @override
  Future<Profile> build() async {
    // 1. Cek User ID (Tetap di atas)
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User tidak login');
    }

    Map<String, dynamic>? data; // Deklarasi di luar 'try'

    // 2. Blok TRY #1: HANYA untuk mengambil data
    try {
      data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      print('Gagal ambil profil: $e');
      throw Exception('Gagal memuat profil');
    }

    // 3. Logika SETELAH 'try' selesai
    if (data == null) {
      print('Profil tidak ditemukan (user lama). Membuat profil baru...');

      // 4. Blok TRY #2: HANYA untuk membuat data baru
      try {
        final user = _client.auth.currentUser;
        final newProfileData = {
          'id': userId,
          'display_name': user?.userMetadata?['full_name'],
          'photo_url': user?.userMetadata?['avatar_url'],
          'phone': null,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _client.from('profiles').insert(newProfileData);
        // KEMBALIKAN data baru
        return Profile.fromJson(newProfileData);
      } catch (e) {
        print('Gagal MEMBUAT profil: $e');
        throw Exception('Gagal membuat profil baru');
      }
    }

    // 5. KEMBALIKAN data (jika 'data' tidak null)
    return Profile.fromJson(data);
  }
  // 2. Method untuk UPLOAD foto profil
  Future<void> uploadProfilePicture() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    // Tampilkan loading di UI
    state = const AsyncValue.loading();

    try {
      // 1. Ambil Gambar
      final imagePicker = ImagePicker();
      final XFile? imageFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres sedikit
      );
      
      if (imageFile == null) {
        // Jika user membatalkan, kembalikan state seperti semula
        ref.invalidateSelf(); 
        await future; // Tunggu data lama dimuat ulang
        return;
      }
      
      final file = File(imageFile.path);
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      // Buat nama file unik, tapi di dalam "folder" ID user
      final filePath = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // 2. Upload ke Supabase Storage
      await _client.storage
          .from('profile-photos')
          .upload(filePath, file); // Upload file

      // 3. Ambil URL Publik
      final publicUrl = _client.storage
          .from('profile-photos')
          .getPublicUrl(filePath);

      // 4. Update tabel 'profiles'
      await _client
          .from('profiles')
          .update({'photo_url': publicUrl})
          .eq('id', userId);

      // 5. Muat ulang data profil
      ref.invalidateSelf();
      await future; // Tunggu data baru (dengan foto baru) dimuat
      print('Foto profil berhasil di-upload!');

    } catch (e) {
      print('Gagal upload foto: $e');
      // Kembalikan ke state error jika gagal
      state = AsyncValue.error('Gagal upload: $e', StackTrace.current);
    }
  }
  // 2. Method untuk UPDATE profil
  Future<void> updateProfile({
    required String displayName,
    required String phone,
  }) async {
    // Ambil user ID
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak login');

    // Tampilkan loading di UI
    state = const AsyncValue.loading();

    try {
      // Data yang akan di-update
      final updates = {
        'display_name': displayName,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Jalankan query UPDATE ke Supabase
      await _client.from('profiles').update(updates).eq('id', userId);

      // Jika berhasil, muat ulang data (invalidate) agar UI terupdate
      ref.invalidateSelf();
      
      // Tunggu data baru termuat
      await future; 
      
      print('Profil berhasil diupdate');

    } catch (e) {
      print('Gagal update profil: $e');
      // Kembalikan ke state error jika gagal
      state = AsyncValue.error('Gagal menyimpan: $e', StackTrace.current);
      // Jangan lempar exception agar state error bisa ditangani UI
    }
  }

  // (Nanti kita bisa tambahkan method updatePhotoProfile di sini)
}