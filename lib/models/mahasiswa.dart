class Mahasiswa {
  final String id;
  final String userId;
  final String nama;
  final String nim;
  final String universitas;
  final String jurusan;
  final int? semester;
  final String? profileImageUrl;

  Mahasiswa({
    required this.id,
    required this.userId,
    required this.nama,
    required this.nim,
    required this.universitas,
    required this.jurusan,
    this.semester,
    this.profileImageUrl,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      id: json['id'],
      userId: json['user_id'],
      nama: json['nama'],
      nim: json['nim'],
      universitas: json['universitas'],
      jurusan: json['jurusan'],
      semester: json['semester'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'nim': nim,
      'universitas': universitas,
      'jurusan': jurusan,
      'semester': semester,
      'profile_image_url': profileImageUrl,
    };
  }
}
