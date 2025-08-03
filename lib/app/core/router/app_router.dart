import 'package:auto_route/auto_route.dart';
import 'package:muto_driver_app/app/core/presentation/app_initialization_screen.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType =>
      RouteType.material(); //.cupertino, .adaptive ..etc
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: AppInitializationRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: HomeRoute.page, children: [
          AutoRoute(page: DriverHomeRoute.page),
          AutoRoute(page: DriverDeliveriesRoute.page),
          AutoRoute(page: DriverEarningsRoute.page),
          AutoRoute(page: DriverProfileRoute.page),
        ]),
      ];

  @override
  List<AutoRouteGuard> get guards => [
        // optionally add root guards here
      ];
}
