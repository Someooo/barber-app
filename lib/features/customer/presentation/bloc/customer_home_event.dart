import 'package:equatable/equatable.dart';

abstract class CustomerHomeEvent extends Equatable {
  const CustomerHomeEvent();

  @override
  List<Object?> get props => [];
}

class CustomerHomeLoadRequested extends CustomerHomeEvent {
  const CustomerHomeLoadRequested({required this.customerId});

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}

class CustomerHomeRefreshRequested extends CustomerHomeEvent {
  const CustomerHomeRefreshRequested({required this.customerId});

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}
