// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i15;
import 'package:flutter/foundation.dart' as _i16;
import 'package:latlong2/latlong.dart' as _i17;
import 'package:muto_client_app/app/core/presentation/app_initialization_screen.dart'
    as _i2;
import 'package:muto_client_app/app/features/authentication/presentation/forgot_password_screen.dart'
    as _i8;
import 'package:muto_client_app/app/features/authentication/presentation/login_screen.dart'
    as _i10;
import 'package:muto_client_app/app/features/authentication/presentation/onboarding_screen.dart'
    as _i11;
import 'package:muto_client_app/app/features/authentication/presentation/register_screen.dart'
    as _i12;
import 'package:muto_client_app/app/features/authentication/presentation/splash_screen.dart'
    as _i13;
import 'package:muto_client_app/app/features/home/presentation/add_delivery_screen.dart'
    as _i1;
import 'package:muto_client_app/app/features/home/presentation/delivery_tracking_screen.dart'
    as _i3;
import 'package:muto_client_app/app/features/home/presentation/driver_deliveries_screen.dart'
    as _i4;
import 'package:muto_client_app/app/features/home/presentation/driver_earnings_screen.dart'
    as _i5;
import 'package:muto_client_app/app/features/home/presentation/driver_home_screen.dart'
    as _i6;
import 'package:muto_client_app/app/features/home/presentation/driver_profile_screen.dart'
    as _i7;
import 'package:muto_client_app/app/features/home/presentation/home_screen.dart'
    as _i9;
import 'package:muto_client_app/app/features/home/presentation/step_by_step_navigation_screen.dart'
    as _i14;

/// generated route for
/// [_i1.AddDeliveryScreen]
class AddDeliveryRoute extends _i15.PageRouteInfo<void> {
  const AddDeliveryRoute({List<_i15.PageRouteInfo>? children})
    : super(AddDeliveryRoute.name, initialChildren: children);

  static const String name = 'AddDeliveryRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddDeliveryScreen();
    },
  );
}

/// generated route for
/// [_i2.AppInitializationScreen]
class AppInitializationRoute extends _i15.PageRouteInfo<void> {
  const AppInitializationRoute({List<_i15.PageRouteInfo>? children})
    : super(AppInitializationRoute.name, initialChildren: children);

  static const String name = 'AppInitializationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppInitializationScreen();
    },
  );
}

/// generated route for
/// [_i3.DeliveryTrackingScreen]
class DeliveryTrackingRoute
    extends _i15.PageRouteInfo<DeliveryTrackingRouteArgs> {
  DeliveryTrackingRoute({
    _i16.Key? key,
    int? id,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         DeliveryTrackingRoute.name,
         args: DeliveryTrackingRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'DeliveryTrackingRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeliveryTrackingRouteArgs>(
        orElse: () => const DeliveryTrackingRouteArgs(),
      );
      return _i3.DeliveryTrackingScreen(key: args.key, id: args.id);
    },
  );
}

class DeliveryTrackingRouteArgs {
  const DeliveryTrackingRouteArgs({this.key, this.id});

  final _i16.Key? key;

  final int? id;

  @override
  String toString() {
    return 'DeliveryTrackingRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeliveryTrackingRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i4.DriverDeliveriesScreen]
class DriverDeliveriesRoute extends _i15.PageRouteInfo<void> {
  const DriverDeliveriesRoute({List<_i15.PageRouteInfo>? children})
    : super(DriverDeliveriesRoute.name, initialChildren: children);

  static const String name = 'DriverDeliveriesRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i4.DriverDeliveriesScreen();
    },
  );
}

/// generated route for
/// [_i5.DriverEarningsScreen]
class DriverEarningsRoute extends _i15.PageRouteInfo<void> {
  const DriverEarningsRoute({List<_i15.PageRouteInfo>? children})
    : super(DriverEarningsRoute.name, initialChildren: children);

  static const String name = 'DriverEarningsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i5.DriverEarningsScreen();
    },
  );
}

/// generated route for
/// [_i6.DriverHomeScreen]
class DriverHomeRoute extends _i15.PageRouteInfo<void> {
  const DriverHomeRoute({List<_i15.PageRouteInfo>? children})
    : super(DriverHomeRoute.name, initialChildren: children);

  static const String name = 'DriverHomeRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i6.DriverHomeScreen();
    },
  );
}

/// generated route for
/// [_i7.DriverProfileScreen]
class DriverProfileRoute extends _i15.PageRouteInfo<void> {
  const DriverProfileRoute({List<_i15.PageRouteInfo>? children})
    : super(DriverProfileRoute.name, initialChildren: children);

  static const String name = 'DriverProfileRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i7.DriverProfileScreen();
    },
  );
}

/// generated route for
/// [_i8.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i15.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i15.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i8.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i9.HomeScreen]
class HomeRoute extends _i15.PageRouteInfo<void> {
  const HomeRoute({List<_i15.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i9.HomeScreen();
    },
  );
}

/// generated route for
/// [_i10.LoginScreen]
class LoginRoute extends _i15.PageRouteInfo<void> {
  const LoginRoute({List<_i15.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i10.LoginScreen();
    },
  );
}

/// generated route for
/// [_i11.OnboardingScreen]
class OnboardingRoute extends _i15.PageRouteInfo<void> {
  const OnboardingRoute({List<_i15.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i11.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i12.RegisterScreen]
class RegisterRoute extends _i15.PageRouteInfo<void> {
  const RegisterRoute({List<_i15.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i12.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i13.SplashScreen]
class SplashRoute extends _i15.PageRouteInfo<void> {
  const SplashRoute({List<_i15.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i13.SplashScreen();
    },
  );
}

/// generated route for
/// [_i14.StepByStepNavigationScreen]
class StepByStepNavigationRoute
    extends _i15.PageRouteInfo<StepByStepNavigationRouteArgs> {
  StepByStepNavigationRoute({
    _i16.Key? key,
    required _i17.LatLng startLocation,
    required _i17.LatLng endLocation,
    required String startAddress,
    required String endAddress,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         StepByStepNavigationRoute.name,
         args: StepByStepNavigationRouteArgs(
           key: key,
           startLocation: startLocation,
           endLocation: endLocation,
           startAddress: startAddress,
           endAddress: endAddress,
         ),
         initialChildren: children,
       );

  static const String name = 'StepByStepNavigationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StepByStepNavigationRouteArgs>();
      return _i14.StepByStepNavigationScreen(
        key: args.key,
        startLocation: args.startLocation,
        endLocation: args.endLocation,
        startAddress: args.startAddress,
        endAddress: args.endAddress,
      );
    },
  );
}

class StepByStepNavigationRouteArgs {
  const StepByStepNavigationRouteArgs({
    this.key,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
  });

  final _i16.Key? key;

  final _i17.LatLng startLocation;

  final _i17.LatLng endLocation;

  final String startAddress;

  final String endAddress;

  @override
  String toString() {
    return 'StepByStepNavigationRouteArgs{key: $key, startLocation: $startLocation, endLocation: $endLocation, startAddress: $startAddress, endAddress: $endAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StepByStepNavigationRouteArgs) return false;
    return key == other.key &&
        startLocation == other.startLocation &&
        endLocation == other.endLocation &&
        startAddress == other.startAddress &&
        endAddress == other.endAddress;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      startLocation.hashCode ^
      endLocation.hashCode ^
      startAddress.hashCode ^
      endAddress.hashCode;
}
