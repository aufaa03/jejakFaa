  import 'dart:io' show Platform;
  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';

  class SupabaseService {
    static final client = Supabase.instance.client;

    static bool get isLoggedIn => client.auth.currentSession != null;

    // Di file supabase_service.dart
    static Future<AuthResponse?> signInWithGoogle() async {
      try {
        // 🟢 Platform Mobile (Menggunakan sintaks v6, seperti proyek lama Anda)
        if (Platform.isAndroid || Platform.isIOS) {
          
          // 1. Ambil Web Client ID dari .env
          final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
          // final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
          if (webClientId == null) {
            throw Exception('GOOGLE_WEB_CLIENT_ID tidak ditemukan di .env');
          }

          // 2. Gunakan .instance (CARA LAMA YANG BENAR UNTUK VERSI ANDA)
          final GoogleSignIn signIn = GoogleSignIn.instance;

          // 3. Initialize
          await signIn.initialize(
            clientId: webClientId,
            serverClientId: webClientId, // Opsional jika Anda punya
          );

          // 4. Authenticate (bukan .signIn)
          final googleAccount = await signIn.authenticate();

          if (googleAccount == null) {
            print('❌ Pengguna membatalkan sign in');
            return null;
          }

          final auth = googleAccount.authentication;
          if (auth.idToken == null) {
            throw Exception('Google auth failed: Missing idToken');
          }

          // 5. Login ke Supabase
          final response = await client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: auth.idToken!,
          );

          return response;
          
        } else {
          // 🌐 Platform Web — redirect flow (ini tetap sama)
          await client.auth.signInWithOAuth(
            OAuthProvider.google, 
            redirectTo: 'io.supabase.flutter://login-callback/',
          );
          return null;
        }
      } catch (e) {
        print('❌ Google sign-in error: $e');
        return null;
      }
    }


    static Future<void> signOut() async {
      try {
        // Gunakan .instance di sini juga
        final googleSignIn = GoogleSignIn.instance; 
        await googleSignIn.signOut();
      } catch (_) {}
      await client.auth.signOut();
    }

    static User? get currentUser => client.auth.currentUser;
  }
