import 'dart:convert';

class AssessmentModel {
  final int id;
  final String period;
  final String? generalNotes;
  final List<AssessmentDetail> details;

  AssessmentModel({
    required this.id,
    required this.period,
    this.generalNotes,
    required this.details,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'],
      period: json['period'],
      generalNotes: json['general_notes'],
      details: (json['details'] as List)
          .map((i) => AssessmentDetail.fromJson(i))
          .toList(),
    );
  }

  // Helper untuk hitung rata-rata skor
  double get averageScore {
    if (details.isEmpty) return 0.0;
    double total = details.fold(0, (sum, item) => sum + item.score);
    return total / details.length;
  }
}

class AssessmentDetail {
  final int score;
  final String categoryName;
  final String? categoryDescription;
  final String indicatorName; // Tambahan: Teks pertanyaan/indikator

  AssessmentDetail({
    required this.score,
    required this.categoryName,
    this.categoryDescription,
    required this.indicatorName,
  });

  factory AssessmentDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentDetail(
      score: json['score'] ?? 0,
      // Sesuaikan dengan struktur JSON dari Backend (Eloquent relationship)
      categoryName:
          json['category'] != null ? json['category']['name'] : 'Umum',
      indicatorName: json['question'] != null
          ? json['question']['question_text']
          : 'Penilaian Karakter',
    );
  }
}
