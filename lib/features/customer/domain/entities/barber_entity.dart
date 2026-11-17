import 'package:equatable/equatable.dart';

class BarberEntity extends Equatable {
  const BarberEntity({
    required this.id,
    required this.name,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.rating,
    required this.experienceYears,
    required this.isAvailableToday,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String specialtyEn;
  final String specialtyAr;
  final double rating;
  final int experienceYears;
  final bool isAvailableToday;
  final String? imageUrl;

  @override
  List<Object?> get props => [
        id,
        name,
        specialtyEn,
        specialtyAr,
        rating,
        experienceYears,
        isAvailableToday,
        imageUrl,
      ];
}
