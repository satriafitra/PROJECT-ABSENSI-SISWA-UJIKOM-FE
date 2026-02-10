class Guru {
  final String nama;

  Guru({required this.nama});

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      nama: json['nama'] ?? '-',
    );
  }
}
