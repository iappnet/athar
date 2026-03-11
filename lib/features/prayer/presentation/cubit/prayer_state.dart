import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:equatable/equatable.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

/// ✅ إضافة loading state
class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTime nextPrayer;
  final List<PrayerTime> allPrayers;
  final String cityName;

  const PrayerLoaded({
    required this.nextPrayer,
    required this.allPrayers,
    required this.cityName,
  });

  @override
  List<Object?> get props => [nextPrayer, allPrayers, cityName];
}

class PrayerError extends PrayerState {
  final String message;

  const PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}

// import 'package:equatable/equatable.dart';
// import '../../../task/data/models/prayer_item.dart';

// abstract class PrayerState extends Equatable {
//   const PrayerState();

//   @override
//   List<Object?> get props => [];
// }

// class PrayerInitial extends PrayerState {}

// class PrayerLoaded extends PrayerState {
//   final PrayerItem nextPrayer;
//   final List<PrayerItem> allPrayers;
//   final String cityName; // ✅ تمت الإضافة

//   const PrayerLoaded({
//     required this.nextPrayer,
//     required this.allPrayers,
//     required this.cityName,
//   });

//   @override
//   List<Object?> get props => [nextPrayer, allPrayers, cityName];
// }

// // ✅ تأكد من وجود كلاس الخطأ
// class PrayerError extends PrayerState {
//   final String message;
//   const PrayerError(this.message);

//   @override
//   List<Object?> get props => [message];
// }
