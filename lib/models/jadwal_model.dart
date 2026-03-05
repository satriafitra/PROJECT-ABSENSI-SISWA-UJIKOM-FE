class Jadwal {
  final int id;
  final String hari;
  final String mataPelajaran;
  final String jamMulai;
  final String jamSelesai;
  final String ruangan;
  final String namaGuru;

  Jadwal({
    required this.id,
    required this.hari,
    required this.mataPelajaran,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.namaGuru,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'],
      hari: json['hari'],
      mataPelajaran: json['mata_pelajaran'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      ruangan: json['ruangan'] ?? 'Ruang Umum',
      namaGuru: json['guru']['nama'],
    );
  }
}