class SurveyData {
  String nama = '';
  int umur = 0;
  String pekerjaan = '';
  List<String> hobi = [];
  String tingkatKepuasan = '';
  String feedback = '';
  
  SurveyData({
    this.nama = '',
    this.umur = 0,
    this.pekerjaan = '',
    List<String>? hobi,
    this.tingkatKepuasan = '',
    this.feedback = '',
  }) : hobi = hobi ?? [];
  
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'umur': umur,
      'pekerjaan': pekerjaan,
      'hobi': hobi,
      'tingkatKepuasan': tingkatKepuasan,
      'feedback': feedback,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      nama: json['nama'] ?? '',
      umur: json['umur'] ?? 0,
      pekerjaan: json['pekerjaan'] ?? '',
      hobi: List<String>.from(json['hobi'] ?? []),
      tingkatKepuasan: json['tingkatKepuasan'] ?? '',
      feedback: json['feedback'] ?? '',
    );
  }
  
  @override
  String toString() {
    return '''
Nama: $nama
Umur: $umur tahun
Pekerjaan: $pekerjaan
Hobi: ${hobi.join(', ')}
Tingkat Kepuasan: $tingkatKepuasan
Feedback: $feedback
''';
  }
}