import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Tonton state auth untuk info user
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      // Tidak perlu AppBar lagi, karena sudah ada di HomePage
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- Bagian Info User ---
          if (user != null) ...[
            CircleAvatar(
              radius: 40,
              // Nanti kita bisa ambil foto profil Google di sini
              // backgroundImage: NetworkImage(user.photoUrl ?? ''),
              backgroundColor: Colors.grey[200],
              child: Text(
                user.name?.substring(0, 1).toUpperCase() ?? 'U', // Inisial
                style: const TextStyle(fontSize: 32, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name ?? 'Nama Pengguna',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.email ?? 'email@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          if (user == null) ...[
            // Tampilan jika user belum ter-load (jarang terjadi)
            const Center(child: CircularProgressIndicator()),
          ],

          const Divider(height: 48),

          // --- Bagian Aksi ---
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text(
              'Keluar',
              style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Panggil fungsi logout dari AuthController
              ref.read(authControllerProvider).signOut();
            },
          ),
          
          // Tombol Sinkronisasi sudah DIHAPUS, karena otomatis

          // Nanti bisa ditambahkan menu lain di sini
          // ListTile(
          //   leading: Icon(Icons.settings_outlined),
          //   title: Text('Pengaturan'),
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }
}

