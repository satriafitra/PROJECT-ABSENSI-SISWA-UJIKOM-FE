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
    // Memanggil API berdasarkan ID siswa yang dikirim dari menu
    _assessmentFuture = ApiService.fetchLatestAssessment(widget.studentId);
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
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
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
                const Text("RINCIAN PARAMETER", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey, 
                    letterSpacing: 1.2, 
                    fontSize: 12
                  )),
                const SizedBox(height: 15),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.details.length,
                  itemBuilder: (context, index) {
                    final detail = data.details[index];
                    return _buildScoreCard(detail);
                  },
                ),

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
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Periode ${data.period}", 
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                const Text("Skor Rata-rata", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              "${data.averageScore.toStringAsFixed(0)}%", 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 28, 
                fontWeight: FontWeight.bold // Perbaikan Error di sini
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScoreCard(AssessmentDetail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(detail.categoryName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
              Text("${detail.score}", 
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: detail.score / 100,
              backgroundColor: Colors.orange.shade50,
              color: Colors.orange,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_quote_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text("CATATAN GURU", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Text("\"$note\"", 
            style: TextStyle(
              fontStyle: FontStyle.italic, 
              color: Colors.orange.shade900,
              fontSize: 14,
              height: 1.5
            )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Belum ada penilaian tersedia", 
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text("Silahkan hubungi guru pengajar kamu.", 
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }
}