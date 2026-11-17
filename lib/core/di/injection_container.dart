import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/authenticate_user_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_session_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/barber/domain/usecases/barber_cancel_booking_usecase.dart';
import '../../features/barber/domain/usecases/complete_booking_usecase.dart';
import '../../features/barber/domain/usecases/ensure_barber_profile_usecase.dart';
import '../../features/barber/domain/usecases/get_barber_bookings_usecase.dart';
import '../../features/barber/domain/usecases/reschedule_booking_usecase.dart';
import '../../features/barber/domain/usecases/update_barber_availability_usecase.dart';
import '../../features/barber/presentation/bloc/barber_dashboard_bloc.dart';
import '../../features/customer/data/datasources/customer_remote_data_source.dart';
import '../../features/customer/data/datasources/firebase_firestore_customer_data_source.dart';
import '../../features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/domain/usecases/cancel_booking_usecase.dart';
import '../../features/customer/domain/usecases/create_instant_booking_usecase.dart';
import '../../features/customer/domain/usecases/get_available_time_slots_usecase.dart';
import '../../features/customer/domain/usecases/get_customer_bookings_usecase.dart';
import '../../features/customer/domain/usecases/get_customer_home_data_usecase.dart';
import '../../features/customer/presentation/bloc/booking_flow_bloc.dart';
import '../../features/customer/presentation/bloc/customer_bookings_bloc.dart';
import '../../features/customer/presentation/bloc/customer_home_bloc.dart';
import '../../features/owner/domain/usecases/add_barber_usecase.dart';
import '../../features/owner/domain/usecases/add_service_usecase.dart';
import '../../features/owner/domain/usecases/delete_barber_usecase.dart';
import '../../features/owner/domain/usecases/delete_service_usecase.dart';
import '../../features/owner/domain/usecases/get_owner_overview_usecase.dart';
import '../../features/owner/presentation/bloc/owner_dashboard_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies({
  FirebaseAuth? firebaseAuth,
  FirebaseFirestore? firestore,
  SharedPreferences? sharedPreferences,
}) async {
  if (sharedPreferences != null && !sl.isRegistered<SharedPreferences>()) {
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }
  if (firestore != null && !sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(() => firestore);
  } else if (Firebase.apps.isNotEmpty &&
      !sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }
  registerAuthDependencies(
    serviceLocator: sl,
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
  registerCustomerDependencies(
    serviceLocator: sl,
    firestore: firestore,
    sharedPreferences: sharedPreferences,
  );
  registerBarberDependencies(serviceLocator: sl);
  registerOwnerDependencies(serviceLocator: sl);
}

void registerCustomerDependencies({
  GetIt? serviceLocator,
  CustomerRemoteDataSource? remoteDataSource,
  FirebaseFirestore? firestore,
  SharedPreferences? sharedPreferences,
}) {
  final locator = serviceLocator ?? sl;

  if (sharedPreferences != null && !locator.isRegistered<SharedPreferences>()) {
    locator.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  if (!locator.isRegistered<CustomerRemoteDataSource>()) {
    final resolvedFirestore = firestore ??
        (locator.isRegistered<FirebaseFirestore>()
            ? locator<FirebaseFirestore>()
            : (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null));

    locator.registerLazySingleton<CustomerRemoteDataSource>(
      () =>
          remoteDataSource ??
          (resolvedFirestore != null
              ? FirebaseFirestoreCustomerDataSource(
                  firestore: resolvedFirestore,
                )
              : InMemoryFirestoreCustomerDataSource(
                  prefs: sharedPreferences ??
                      (locator.isRegistered<SharedPreferences>()
                          ? locator<SharedPreferences>()
                          : null),
                )),
    );
  }

  if (!locator.isRegistered<CustomerRepository>()) {
    locator.registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImpl(
        remoteDataSource: locator<CustomerRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<GetCustomerHomeDataUseCase>()) {
    locator.registerLazySingleton<GetCustomerHomeDataUseCase>(
      () => GetCustomerHomeDataUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<GetAvailableTimeSlotsUseCase>()) {
    locator.registerLazySingleton<GetAvailableTimeSlotsUseCase>(
      () => GetAvailableTimeSlotsUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<CreateInstantBookingUseCase>()) {
    locator.registerLazySingleton<CreateInstantBookingUseCase>(
      () => CreateInstantBookingUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<GetCustomerBookingsUseCase>()) {
    locator.registerLazySingleton<GetCustomerBookingsUseCase>(
      () => GetCustomerBookingsUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<CancelBookingUseCase>()) {
    locator.registerLazySingleton<CancelBookingUseCase>(
      () => CancelBookingUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<CustomerHomeBloc>()) {
    locator.registerFactory<CustomerHomeBloc>(
      () => CustomerHomeBloc(
        getCustomerHomeDataUseCase: locator<GetCustomerHomeDataUseCase>(),
      ),
    );
  }

  if (!locator.isRegistered<BookingFlowBloc>()) {
    locator.registerFactory<BookingFlowBloc>(
      () => BookingFlowBloc(
        getAvailableTimeSlotsUseCase: locator<GetAvailableTimeSlotsUseCase>(),
        createInstantBookingUseCase: locator<CreateInstantBookingUseCase>(),
        getCustomerHomeDataUseCase: locator<GetCustomerHomeDataUseCase>(),
      ),
    );
  }

  if (!locator.isRegistered<CustomerBookingsBloc>()) {
    locator.registerFactory<CustomerBookingsBloc>(
      () => CustomerBookingsBloc(
        getCustomerBookingsUseCase: locator<GetCustomerBookingsUseCase>(),
        cancelBookingUseCase: locator<CancelBookingUseCase>(),
      ),
    );
  }
}

void registerAuthDependencies({
  GetIt? serviceLocator,
  FirebaseAuth? firebaseAuth,
  FirebaseFirestore? firestore,
}) {
  final locator = serviceLocator ?? sl;

  if (!locator.isRegistered<FirebaseAuth>()) {
    locator.registerLazySingleton<FirebaseAuth>(
      () => firebaseAuth ?? FirebaseAuth.instance,
    );
  }

  if (!locator.isRegistered<AuthRemoteDataSource>()) {
    final resolvedFirestore = firestore ??
        (locator.isRegistered<FirebaseFirestore>()
            ? locator<FirebaseFirestore>()
            : (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null));

    locator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: firebaseAuth ??
            (Firebase.apps.isNotEmpty ? locator<FirebaseAuth>() : null),
        firestore: resolvedFirestore,
        prefs: locator.isRegistered<SharedPreferences>()
            ? locator<SharedPreferences>()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<AuthRepository>()) {
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: locator<AuthRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<AuthenticateUserUseCase>()) {
    locator.registerLazySingleton<AuthenticateUserUseCase>(
      () => AuthenticateUserUseCase(locator<AuthRepository>()),
    );
  }

  if (!locator.isRegistered<CheckAuthSessionUseCase>()) {
    locator.registerLazySingleton<CheckAuthSessionUseCase>(
      () => CheckAuthSessionUseCase(locator<AuthRepository>()),
    );
  }

  if (!locator.isRegistered<SignOutUseCase>()) {
    locator.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(locator<AuthRepository>()),
    );
  }

  if (!locator.isRegistered<AuthBloc>()) {
    locator.registerFactory<AuthBloc>(
      () => AuthBloc(
        authenticateUserUseCase: locator<AuthenticateUserUseCase>(),
        checkAuthSessionUseCase: locator<CheckAuthSessionUseCase>(),
        signOutUseCase: locator<SignOutUseCase>(),
      ),
    );
  }
}

void registerBarberDependencies({GetIt? serviceLocator}) {
  final locator = serviceLocator ?? sl;

  if (!locator.isRegistered<CustomerRepository>()) {
    registerCustomerDependencies(serviceLocator: locator);
  }

  if (!locator.isRegistered<EnsureBarberProfileUseCase>()) {
    locator.registerLazySingleton<EnsureBarberProfileUseCase>(
      () => EnsureBarberProfileUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<GetBarberBookingsUseCase>()) {
    locator.registerLazySingleton<GetBarberBookingsUseCase>(
      () => GetBarberBookingsUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<UpdateBarberAvailabilityUseCase>()) {
    locator.registerLazySingleton<UpdateBarberAvailabilityUseCase>(
      () => UpdateBarberAvailabilityUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<CompleteBookingUseCase>()) {
    locator.registerLazySingleton<CompleteBookingUseCase>(
      () => CompleteBookingUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<RescheduleBookingUseCase>()) {
    locator.registerLazySingleton<RescheduleBookingUseCase>(
      () => RescheduleBookingUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<BarberCancelBookingUseCase>()) {
    locator.registerLazySingleton<BarberCancelBookingUseCase>(
      () => BarberCancelBookingUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<BarberDashboardBloc>()) {
    locator.registerFactory<BarberDashboardBloc>(
      () => BarberDashboardBloc(
        ensureBarberProfileUseCase: locator<EnsureBarberProfileUseCase>(),
        getBarberBookingsUseCase: locator<GetBarberBookingsUseCase>(),
        updateBarberAvailabilityUseCase:
            locator<UpdateBarberAvailabilityUseCase>(),
        completeBookingUseCase: locator<CompleteBookingUseCase>(),
        rescheduleBookingUseCase: locator<RescheduleBookingUseCase>(),
        barberCancelBookingUseCase: locator<BarberCancelBookingUseCase>(),
      ),
    );
  }
}

void registerOwnerDependencies({GetIt? serviceLocator}) {
  final locator = serviceLocator ?? sl;

  if (!locator.isRegistered<CustomerRepository>()) {
    registerCustomerDependencies(serviceLocator: locator);
  }

  if (!locator.isRegistered<GetOwnerOverviewUseCase>()) {
    locator.registerLazySingleton<GetOwnerOverviewUseCase>(
      () => GetOwnerOverviewUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<AddServiceUseCase>()) {
    locator.registerLazySingleton<AddServiceUseCase>(
      () => AddServiceUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<DeleteServiceUseCase>()) {
    locator.registerLazySingleton<DeleteServiceUseCase>(
      () => DeleteServiceUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<AddBarberUseCase>()) {
    locator.registerLazySingleton<AddBarberUseCase>(
      () => AddBarberUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<DeleteBarberUseCase>()) {
    locator.registerLazySingleton<DeleteBarberUseCase>(
      () => DeleteBarberUseCase(locator<CustomerRepository>()),
    );
  }

  if (!locator.isRegistered<OwnerDashboardBloc>()) {
    locator.registerFactory<OwnerDashboardBloc>(
      () => OwnerDashboardBloc(
        getOwnerOverviewUseCase: locator<GetOwnerOverviewUseCase>(),
        addServiceUseCase: locator<AddServiceUseCase>(),
        deleteServiceUseCase: locator<DeleteServiceUseCase>(),
        addBarberUseCase: locator<AddBarberUseCase>(),
        deleteBarberUseCase: locator<DeleteBarberUseCase>(),
      ),
    );
  }
}
