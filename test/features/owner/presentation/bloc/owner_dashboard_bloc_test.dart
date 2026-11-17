import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/features/customer/data/datasources/in_memory_firestore_customer_data_source.dart';
import 'package:barber_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:barber_app/features/customer/domain/entities/service_entity.dart';
import 'package:barber_app/features/owner/domain/usecases/add_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/add_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_barber_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/delete_service_usecase.dart';
import 'package:barber_app/features/owner/domain/usecases/get_owner_overview_usecase.dart';
import 'package:barber_app/features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:barber_app/features/owner/presentation/bloc/owner_dashboard_event.dart';
import 'package:barber_app/features/owner/presentation/bloc/owner_dashboard_state.dart';

void main() {
  group('OwnerDashboardBloc', () {
    late CustomerRepositoryImpl repository;
    late OwnerDashboardBloc bloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = CustomerRepositoryImpl(
        remoteDataSource: InMemoryFirestoreCustomerDataSource(prefs: prefs),
      );
      bloc = OwnerDashboardBloc(
        getOwnerOverviewUseCase: GetOwnerOverviewUseCase(repository),
        addServiceUseCase: AddServiceUseCase(repository),
        deleteServiceUseCase: DeleteServiceUseCase(repository),
        addBarberUseCase: AddBarberUseCase(repository),
        deleteBarberUseCase: DeleteBarberUseCase(repository),
      );
    });

    tearDown(() => bloc.close());

    test('loads KPIs, adds & deletes services and barbers', () async {
      const service = ServiceEntity(
        id: 'srv_1',
        nameEn: 'Cut',
        nameAr: 'قص',
        descriptionEn: 'Cut',
        descriptionAr: 'قص',
        price: 50,
        durationMinutes: 30,
        iconName: 'content_cut',
      );
      await repository.createInstantBooking(
        customerId: 'c1',
        customerName: 'Sami',
        barberId: 'barber_1',
        barberName: 'Tariq',
        services: const [service],
        dateTime: DateTime(2026, 11, 20, 14),
        totalPrice: 50,
        totalDurationMinutes: 30,
      );

      bloc.add(const OwnerDashboardLoadRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(isA<OwnerDashboardLoaded>()),
      );

      final loaded = bloc.state as OwnerDashboardLoaded;
      expect(loaded.totalShopRevenue, 50.0);
      expect(loaded.activeBookingsCount, 1);
      final initialServicesCount = loaded.services.length;
      final initialBarbersCount = loaded.barbers.length;

      bloc.add(const OwnerServiceAdded(
        nameEn: 'Luxury Facial',
        nameAr: 'عناية بالبشرة',
        descriptionEn: 'Deep cleanse',
        descriptionAr: 'تنظيف عميق',
        price: 45,
        durationMinutes: 35,
        iconName: 'spa',
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<OwnerDashboardLoaded>().having(
            (s) => s.services.length,
            'services.length',
            initialServicesCount + 1,
          ),
        ),
      );

      final addedServiceId = (bloc.state as OwnerDashboardLoaded)
          .services
          .firstWhere((s) => s.nameEn == 'Luxury Facial')
          .id;

      bloc.add(OwnerServiceDeleted(addedServiceId));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<OwnerDashboardLoaded>().having(
            (s) => s.services.length,
            'services.length',
            initialServicesCount,
          ),
        ),
      );

      bloc.add(const OwnerBarberAdded(
        name: 'Yousef',
        specialtyEn: 'Classic',
        specialtyAr: 'كلاسيك',
        experienceYears: 6,
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<OwnerDashboardLoaded>().having(
            (s) => s.barbers.length,
            'barbers.length',
            initialBarbersCount + 1,
          ),
        ),
      );

      final addedBarberId = (bloc.state as OwnerDashboardLoaded)
          .barbers
          .firstWhere((b) => b.name == 'Yousef')
          .id;

      bloc.add(OwnerBarberDeleted(addedBarberId));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<OwnerDashboardLoaded>().having(
            (s) => s.barbers.length,
            'barbers.length',
            initialBarbersCount,
          ),
        ),
      );
    });
  });
}
