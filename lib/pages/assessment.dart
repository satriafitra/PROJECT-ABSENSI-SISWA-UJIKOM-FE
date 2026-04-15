import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../services/api_services.dart';

class AssessmentScreen extends StatefulWidget {
  final int studentId;
  const AssessmentScreen({super.key, required this.studentId});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late Future<AssessmentModel?> _assessmentFuture;

  @override
  void initState() {
    super.initState();
    _assessmentFuture = ApiService.fetchLatestAssessment(widget.studentId);
  }

  // Fungsi Helper untuk mendapatkan Emote dan Warna berdasarkan Skor
  Map<String, dynamic> _getEmoteStyle(int score) {
    if (score <= 20) {
      return {
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.red,
        'label': 'Perlu Bimbingan'
      };
    } else if (score <= 45) {
      return {
        'icon': Icons.sentiment_dissatisfied,
        'color': Colors.orange,
        'label': 'Cukup'
      };
    } else if (score <= 75) {
      return {
        'icon': Icons.sentiment_satisfied,
        'color': Colors.amber.shade700,
        'label': 'Baik'
      };
    } else if (score <= 90) {
      return {
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.green,
        'label': 'Sangat Baik'
      };
    } else {
      return {
        'icon': Icons.stars_rounded,
        'color': Colors.indigo,
        'label': 'Istimewa'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Rapor Karakter",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<AssessmentModel?>(
        future: _assessmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildEmptyState();
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(data),

                const SizedBox(height: 30),
                const Row(
                  children: [
                    Icon(Icons.list_alt_rounded, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("RINCIAN PARAMETER PENILAIAN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 15),

                // Menampilkan rincian indikator secara langsung (tanpa nested ListView)
                ...data.details
                    .map((detail) => _buildIndicatorTile(detail))
                    .toList(),

                if (data.generalNotes != null && data.generalNotes!.isNotEmpty)
                  _buildTeacherNote(data.generalNotes!),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(AssessmentModel data) {
    final style = _getEmoteStyle(data.averageScore.toInt());

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Warna Slate 900 biar elegan
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: style['color'].withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Periode ${data.period}",
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Skor Rata-rata",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: style['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: style['color'].withOpacity(0.5))),
                  child: Text(
                    style['label'].toString().toUpperCase(),
                    style: TextStyle(
                        color: style['color'],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                )
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 85,
                height: 85,
                child: CircularProgressIndicator(
                  value: data.averageScore / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  color: style['color'],
                ),
              ),
              Text(
                "${data.averageScore.toStringAsFixed(0)}%",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIndicatorTile(AssessmentDetail detail) {
    final style = _getEmoteStyle(detail.score);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blueGrey.shade50),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Emote Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: style['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(style['icon'], color: style['color'], size: 24),
              ),
              const SizedBox(width: 15),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.categoryName.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.blueGrey.shade300,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(detail.indicatorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              // Score Text
              Text("${detail.score}",
                  style: TextStyle(
                      color: style['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ],
          ),
          const SizedBox(height: 15),
          // Dynamic Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: detail.score / 100,
              backgroundColor: Colors.blueGrey.shade50,
              color: style['color'],
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherNote(String note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100.withOpacity(0.3)
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mode_comment_rounded,
                  color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 8),
              Text("CATATAN EVALUASI",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.orange.shade800,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text("\"$note\"",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange.shade900,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined,
              size: 70, color: Colors.blueGrey.shade200),
          const SizedBox(height: 20),
          const Text("Belum Ada Rapor",
              style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Guru kamu belum menginput penilaian karakter untuk periode ini.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.blueGrey.shade400, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
