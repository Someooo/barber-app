import '../../domain/entities/barber_entity.dart';

class BarberModel extends BarberEntity {
  const BarberModel({
    required super.id,
    required super.name,
    required super.specialtyEn,
    required super.specialtyAr,
    required super.rating,
    required super.experienceYears,
    required super.isAvailableToday,
    super.imageUrl,
  });

  factory BarberModel.fromMap(Map<String, dynamic> map, String id) {
    return BarberModel(
      id: id,
      name: (map['name'] as String?) ?? '',
      specialtyEn: (map['specialtyEn'] as String?) ?? '',
      specialtyAr: (map['specialtyAr'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 1,
      isAvailableToday: (map['isAvailableToday'] as bool?) ?? true,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  factory BarberModel.fromEntity(BarberEntity entity) {
    return BarberModel(
      id: entity.id,
      name: entity.name,
      specialtyEn: entity.specialtyEn,
      specialtyAr: entity.specialtyAr,
      rating: entity.rating,
      experienceYears: entity.experienceYears,
      isAvailableToday: entity.isAvailableToday,
      imageUrl: entity.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialtyEn': specialtyEn,
      'specialtyAr': specialtyAr,
      'rating': rating,
      'experienceYears': experienceYears,
      'isAvailableToday': isAvailableToday,
      'imageUrl': imageUrl,
    };
  }
}
