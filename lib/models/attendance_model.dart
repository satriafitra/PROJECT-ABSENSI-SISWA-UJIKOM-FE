class AttendanceModel {
  final String date;
  final String status;
  final String? guruName;
  final int? guruId;

  AttendanceModel({
    required this.date,
    required this.status,
    this.guruName,
    this.guruId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      date: json['date'],
      status: json['status'],
      guruId: json['guru_id'],
      guruName: json['guru'] != null ? json['guru']['nama'] : '-',
    );
  }
}
