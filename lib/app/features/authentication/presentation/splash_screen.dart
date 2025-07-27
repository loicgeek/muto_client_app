import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_driver_app/app/core/router/app_router.gr.dart';
import 'package:muto_driver_app/app/core/service_locator.dart';
import 'package:muto_driver_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_driver_app/app/features/authentication/presentation/login_screen.dart';
import 'package:muto_driver_app/app/features/home/presentation/home_screen.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthenticationCubit _authenticationCubit;

  @override
  void initState() {
    super.initState();
    _authenticationCubit = getIt.get<AuthenticationCubit>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      bloc: _authenticationCubit,
      listener: (context, state) {
        if (state is AuthenticationSuccess) {
          context.router
              .pushAndPopUntil(HomeRoute(), predicate: (route) => false);
        } else if (state is AuthenticationFailure) {
          context.router
              .pushAndPopUntil(LoginRoute(), predicate: (route) => false);
        }
      },
      child: const Scaffold(
        body: Center(
          child: Text('Splash Screen'),
        ),
      ),
    );
  }
}
