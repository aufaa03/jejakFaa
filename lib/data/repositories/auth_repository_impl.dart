import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:jejak_faa_new/data/datasources/remote/auth_remote_data_source.dart';
import 'package:jejak_faa_new/domain/entities/user_entity.dart';
import 'package:jejak_faa_new/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get onAuthStateChange {
    // Mapping stream User Supabase ke UserEntity kita
    return remoteDataSource.onAuthStateChange.map((user) => _mapSupabaseUser(user));
  }

  @override
  UserEntity? get currentUser {
    // Mapping User Supabase saat ini ke UserEntity kita
    return _mapSupabaseUser(remoteDataSource.currentUser);
  }

  @override
  Future<void> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  // Helper mapping
  UserEntity? _mapSupabaseUser(supabase.User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['full_name'], // Ambil nama dari metadata
    );
  }
}