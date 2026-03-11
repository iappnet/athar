import 'package:equatable/equatable.dart';

// ✅ توحيد الحالة هنا فقط
enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled,
  archived,
}

class ProjectEntity extends Equatable {
  final String uuid;
  final String title;
  final String? description;
  final ProjectStatus status;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? completedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isArchived;
  final double progressPercentage;
  final bool reminderEnabled;
  final String? spaceUuid;

  const ProjectEntity({
    required this.uuid,
    required this.title,
    this.description,
    this.status = ProjectStatus.inProgress,
    this.dueDate,
    this.startDate,
    this.completedDate,
    this.createdAt,
    this.updatedAt,
    this.isArchived = false,
    this.progressPercentage = 0.0,
    this.reminderEnabled = true,
    this.spaceUuid,
  });

  @override
  List<Object?> get props => [
    uuid,
    title,
    status,
    dueDate,
    spaceUuid,
    isArchived,
  ];
}
