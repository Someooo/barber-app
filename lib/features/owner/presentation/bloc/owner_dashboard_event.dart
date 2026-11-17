import 'package:equatable/equatable.dart';

abstract class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardLoadRequested extends OwnerDashboardEvent {
  const OwnerDashboardLoadRequested();
}

class OwnerServiceAdded extends OwnerDashboardEvent {
  const OwnerServiceAdded({
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.durationMinutes,
    required this.iconName,
  });

  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final int durationMinutes;
  final String iconName;

  @override
  List<Object?> get props => [
        nameEn,
        nameAr,
        descriptionEn,
        descriptionAr,
        price,
        durationMinutes,
        iconName,
      ];
}

class OwnerServiceDeleted extends OwnerDashboardEvent {
  const OwnerServiceDeleted(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

class OwnerBarberAdded extends OwnerDashboardEvent {
  const OwnerBarberAdded({
    required this.name,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.experienceYears,
    this.imageUrl,
  });

  final String name;
  final String specialtyEn;
  final String specialtyAr;
  final int experienceYears;
  final String? imageUrl;

  @override
  List<Object?> get props => [
        name,
        specialtyEn,
        specialtyAr,
        experienceYears,
        imageUrl,
      ];
}

class OwnerBarberDeleted extends OwnerDashboardEvent {
  const OwnerBarberDeleted(this.barberId);

  final String barberId;

  @override
  List<Object?> get props => [barberId];
}
