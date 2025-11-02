import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/data/datasources/remote/auth_remote_data_source.dart';
import 'package:jejak_faa_new/data/repositories/auth_repository_impl.dart';
import 'package:jejak_faa_new/domain/entities/user_entity.dart';
import 'package:jejak_faa_new/domain/repositories/auth_repository.dart';

// 1. Provider untuk Data Source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// 2. Provider untuk Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

// 3. Provider untuk STATE (Status Login)
// Ini adalah provider terpenting.
// StreamProvider secara otomatis akan "listen" ke stream dan memberitahu UI jika ada perubahan.
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.onAuthStateChange;
});

// 4. Provider untuk ACTION (Controller)
// Ini untuk men-trigger login/logout dari UI.
final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

class AuthController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<void> signInWithGoogle() {
    return _authRepository.signInWithGoogle();
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }
}