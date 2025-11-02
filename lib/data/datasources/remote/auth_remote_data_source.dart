import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 1. Hapus const 'googleRedirectUrl', kita tidak membutuhkannya lagi

class AuthRemoteDataSource {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  
  // 2. GANTI DENGAN WEB CLIENT ID KAMU DARI GOOGLE CLOUD
  final String _googleWebClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']!;
  // Stream dan currentUser tetap sama
  Stream<User?> get onAuthStateChange {
    return _auth.onAuthStateChange.map((state) => state.session?.user);
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<void> signInWithGoogle() async {
  print('Loaded GOOGLE_WEB_CLIENT_ID: $_googleWebClientId');
    try {
      print('=== START GOOGLE SIGN IN (API LAMA) ===');

      if (_googleWebClientId == 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com') {
        throw 'TOLONG GANTI WEB CLIENT ID di auth_remote_data_source.dart';
      }

      final GoogleSignIn signIn = GoogleSignIn.instance;
      print('GoogleSignIn instance created');

      // 1. Menggunakan .initialize() (API Lama)
      await signIn.initialize(
        clientId: _googleWebClientId,
        serverClientId: _googleWebClientId,
      );
      print('GoogleSignIn initialized');

      // 2. Menggunakan .authenticate() (API Lama)
      final googleAccount = await signIn.authenticate();
      print('Google account: ${googleAccount?.email}');

      if (googleAccount == null) {
        throw 'User membatalkan sign in';
      }

      final authentication = googleAccount.authentication;
      print('Authentication obtained');

      final idToken = authentication.idToken;
      print('ID Token: ${idToken != null ? 'OK' : 'NULL'}');

      if (idToken == null) {
        throw 'Gagal mendapatkan ID token dari Google.';
      }

      print('Attempting Supabase login...');
      try {
      await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      // Cek apakah user sudah tersimpan meskipun ada error
      if (_auth.currentUser != null) {
        print('⚠️ Error tapi user sudah tersimpan: ${_auth.currentUser?.email}');
        // Lanjut ke next page, jangan rethrow
      } else {
        rethrow; // Kalau truly error, baru throw
      }
    }

      print('=== SIGN IN SUCCESS (API LAMA) ===');
    } catch (e, stackTrace) {
      print('=== ERROR (API LAMA) ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signOut: $e');
      throw Exception('Gagal logout: $e');
    }
  }
}
