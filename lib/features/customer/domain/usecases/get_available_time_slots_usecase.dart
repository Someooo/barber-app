import '../repositories/customer_repository.dart';

class GetAvailableTimeSlotsUseCase {
  const GetAvailableTimeSlotsUseCase(this._repository);

  final CustomerRepository _repository;

  Future<List<DateTime>> call({
    required String barberId,
    required DateTime date,
    required int durationMinutes,
  }) {
    return _repository.getAvailableTimeSlots(
      barberId: barberId,
      date: date,
      durationMinutes: durationMinutes,
    );
  }
}
