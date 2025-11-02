class UserEntity {
  final String id;
  final String? email;
  final String? name; // Ambil dari metadata

  UserEntity({required this.id, this.email, this.name});
}