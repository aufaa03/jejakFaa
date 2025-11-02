import 'package:jejak_faa_new/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Stream untuk memantau perubahan status auth (login/logout)
  Stream<UserEntity?> get onAuthStateChange;

  // Mendapatkan user yang sedang login
  UserEntity? get currentUser;

  // Method untuk login dengan Google
  Future<void> signInWithGoogle();

  // Method untuk logout
  Future<void> signOut();
}