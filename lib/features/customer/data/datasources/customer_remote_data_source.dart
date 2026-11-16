import '../models/barber_model.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<ServiceModel>> getServices();

  Future<List<BarberModel>> getBarbers();

  Future<List<BookingModel>> getCustomerBookings(String customerId);

  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  });

  Future<BookingModel> createInstantBooking({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<ServiceModel> services,
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
