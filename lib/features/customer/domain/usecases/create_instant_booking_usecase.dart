import '../entities/booking_entity.dart';
import '../entities/service_entity.dart';
import '../repositories/customer_repository.dart';

class CreateInstantBookingUseCase {
  const CreateInstantBookingUseCase(this._repository);

  final CustomerRepository _repository;

  Future<BookingEntity> call({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<ServiceEntity> services,
    required DateTime dateTime,
    required double totalPrice,
    required int totalDurationMinutes,
    String? notes,
  }) {
    return _repository.createInstantBooking(
      customerId: customerId,
      customerName: customerName,
      barberId: barberId,
      barberName: barberName,
      services: services,
      dateTime: dateTime,
      totalPrice: totalPrice,
      totalDurationMinutes: totalDurationMinutes,
      notes: notes,
    );
  }
}
