import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/authenticate_user_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_session_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies({FirebaseAuth? firebaseAuth}) async {
  registerAuthDependencies(
    serviceLocator: sl,
    firebaseAuth: firebaseAuth,
  );
}

void registerAuthDependencies({
  GetIt? serviceLocator,
  FirebaseAuth? firebaseAuth,
}) {
  final locator = serviceLocator ?? sl;

  if (!locator.isRegistered<FirebaseAuth>()) {
    locator.registerLazySingleton<FirebaseAuth>(
      () => firebaseAuth ?? FirebaseAuth.instance,
    );
  }

  if (!locator.isRegistered<AuthRemoteDataSource>()) {
    locator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: firebaseAuth ??
            (Firebase.apps.isNotEmpty ? locator<FirebaseAuth>() : null),
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
