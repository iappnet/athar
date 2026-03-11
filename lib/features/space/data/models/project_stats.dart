class ProjectStats {
  final int total;
  final int completed;

  ProjectStats({required this.total, required this.completed});

  // دالة مساعدة لحساب النسبة المئوية (0.0 إلى 1.0)
  double get progress {
    if (total == 0) return 0.0;
    return completed / total;
  }

  // دالة مساعدة للنص (مثلاً: "5/10")
  String get fraction => "$completed/$total";
}
