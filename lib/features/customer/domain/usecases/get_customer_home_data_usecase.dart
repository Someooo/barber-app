import '../entities/booking_entity.dart';
import '../entities/booking_status.dart';
import '../entities/customer_home_data.dart';
import '../repositories/customer_repository.dart';

class GetCustomerHomeDataUseCase {
  const GetCustomerHomeDataUseCase(this._repository);

  final CustomerRepository _repository;

  Future<CustomerHomeData> call(String customerId) async {
    final services = await _repository.getServices();
    final barbers = await _repository.getBarbers();
    final bookings = await _repository.getCustomerBookings(customerId);

    final now = DateTime.now();
    final activeBookings = bookings.where((b) {
      final isUpcoming = b.dateTime.isAfter(now) ||
          (b.dateTime.year == now.year &&
              b.dateTime.month == now.month &&
              b.dateTime.day == now.day &&
              b.dateTime.hour >= now.hour);
      return isUpcoming &&
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.rescheduled);
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final activeBooking =
        activeBookings.isNotEmpty ? activeBookings.first : null;

    return CustomerHomeData(
      services: services,
      barbers: barbers,
      activeBooking: activeBooking,
    );
  }
}
