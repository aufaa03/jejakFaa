import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kita juga bisa 'watch' state untuk menampilkan loading
    // final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.login), // Ganti dengan logo Google nanti
              label: const Text('Masuk dengan Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // Memanggil method login dari controller
                ref.read(authControllerProvider).signInWithGoogle();
              },
            ),
            // Jika kamu ingin menampilkan loading:
            // if (authState.isLoading) ...[
            //   const SizedBox(height: 16),
            //   const CircularProgressIndicator(),
            // ]
          ],
        ),
      ),
    );
  }
}