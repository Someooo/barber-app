enum BookingStatus {
  confirmed,
  completed,
  cancelled,
  rescheduled;

  bool get isConfirmed => this == BookingStatus.confirmed;
  bool get isCompleted => this == BookingStatus.completed;
  bool get isCancelled => this == BookingStatus.cancelled;
  bool get isRescheduled => this == BookingStatus.rescheduled;

  bool get isActive => isConfirmed || isRescheduled;
}
