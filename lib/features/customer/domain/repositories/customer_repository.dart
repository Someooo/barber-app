import '../entities/barber_entity.dart';
import '../entities/booking_entity.dart';
import '../entities/service_entity.dart';

abstract class CustomerRepository {
  Future<List<ServiceEntity>> getServices();

  Future<List<BarberEntity>> getBarbers();

  Future<List<BookingEntity>> getCustomerBookings(String customerId);

  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  });

  Future<BookingEntity> createInstantBooking({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<ServiceEntity> services,
    required DateTime dateTime,
    required double totalPrice,
    required int totalDurationMinutes,
    String? notes,
  });

  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  });
}
