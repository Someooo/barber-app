import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.descriptionEn,
    required super.descriptionAr,
    required super.price,
    required super.durationMinutes,
    required super.iconName,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      nameEn: (map['nameEn'] as String?) ?? '',
      nameAr: (map['nameAr'] as String?) ?? '',
      descriptionEn: (map['descriptionEn'] as String?) ?? '',
      descriptionAr: (map['descriptionAr'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      iconName: (map['iconName'] as String?) ?? 'content_cut',
    );
  }

  factory ServiceModel.fromEntity(ServiceEntity entity) {
    return ServiceModel(
      id: entity.id,
      nameEn: entity.nameEn,
      nameAr: entity.nameAr,
      descriptionEn: entity.descriptionEn,
      descriptionAr: entity.descriptionAr,
      price: entity.price,
      durationMinutes: entity.durationMinutes,
      iconName: entity.iconName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn,
      'nameAr': nameAr,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'price': price,
      'durationMinutes': durationMinutes,
      'iconName': iconName,
    };
  }
}
