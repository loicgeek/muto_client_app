import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:muto_driver_app/app/core/network/token_interceptor.dart';
import 'package:muto_driver_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_driver_app/app/features/authentication/data/auth_repository.dart';
import 'package:muto_driver_app/app/core/router/app_router.dart';
import 'package:muto_driver_app/app/features/home/repositories/deliveries_repository.dart';
import 'package:muto_driver_app/app/ui/app_config.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AppRouter>(() => AppRouter());
  getIt.registerSingleton<Dio>(Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {
        "accept": "application/json",
      },
    ),
  )..interceptors.add(TokenInterceptor()));
  getIt.registerSingleton<AuthRepository>(AuthRepository(dio: getIt<Dio>()));
  getIt.registerSingleton<DeliveriesRepository>(
      DeliveriesRepository(dio: getIt<Dio>()));
  getIt.registerSingleton<AuthenticationCubit>(
      AuthenticationCubit(authRepository: getIt<AuthRepository>()));
}
