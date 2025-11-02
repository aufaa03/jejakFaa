// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';

// // Gunakan Equatable agar objek Photo bisa dibandingkan
// class Photo extends Equatable {
//   final String id;
//   final String photoUrl;
//   final String hikeId; // Untuk filter "berdasarkan gunung"
//   final DateTime createdAt; // Untuk sortir "terbaru/terlama"
//   final bool isLocal; // Untuk filter "lokal"

//   const Photo({
//     required this.id,
//     required this.photoUrl,
//     required this.hikeId,
//     required this.createdAt,
//     this.isLocal = false, // Default-nya false (sudah di cloud)
//   });

//   /// Konversi dari Dokumen Firestore ke objek Photo
//   factory Photo.fromJson(Map<String, dynamic> json, String docId) {
//     return Photo(
//       id: docId,
//       photoUrl: json['photoUrl'] as String? ?? '',
//       hikeId: json['hikeId'] as String? ?? '',
//       // Ambil Timestamp dari Firestore dan ubah jadi DateTime
//       createdAt: (json['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
//       // Foto yang datang dari Firestore sudah pasti TIDAK lokal
//       isLocal: false,
//     );
//   }

//   /// Konversi dari objek Photo ke Map untuk diupload ke Firestore
//   /// (Perhatikan kita tidak menyimpan 'id' atau 'isLocal' ke cloud)
//   Map<String, dynamic> toJson() {
//     return {
//       'photoUrl': photoUrl,
//       'hikeId': hikeId,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }

//   /// Helper copyWith untuk update state (best practice)
//   Photo copyWith({
//     String? id,
//     String? photoUrl,
//     String? hikeId,
//     DateTime? createdAt,
//     bool? isLocal,
//   }) {
//     return Photo(
//       id: id ?? this.id,
//       photoUrl: photoUrl ?? this.photoUrl,
//       hikeId: hikeId ?? this.hikeId,
//       createdAt: createdAt ?? this.createdAt,
//       isLocal: isLocal ?? this.isLocal,
//     );
//   }

//   // Tentukan field mana yang digunakan untuk perbandingan '=='
//   @override
//   List<Object?> get props => [id, photoUrl, hikeId, createdAt, isLocal];
// }
