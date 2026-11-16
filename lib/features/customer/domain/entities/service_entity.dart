import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  const ServiceEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.durationMinutes,
    required this.iconName,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final int durationMinutes;
  final String iconName;

  @override
  List<Object?> get props => [
        id,
        nameEn,
        nameAr,
        descriptionEn,
        descriptionAr,
        price,
        durationMinutes,
        iconName,
      ];
}
