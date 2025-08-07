import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_client_app/app/core/router/app_router.gr.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_client_app/app/features/home/business_logic/current_delivery/current_delivery_cubit.dart';

@RoutePage()
class AppInitializationScreen extends StatefulWidget {
  const AppInitializationScreen({super.key});

  @override
  State<AppInitializationScreen> createState() => _AppInitializationState();
}

class _AppInitializationState extends State<AppInitializationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        bloc: getIt.get<AuthenticationCubit>(),
        listener: (context, state) {
          if (state is AuthenticationSuccess) {
            if (state.user?.courier != null) {
              context.read<CurrentDeliveryCubit>().checkCurrentDelivery(
                  courierId: state.user?.courier?.id ?? 0);
            }
            context.router
                .pushAndPopUntil(HomeRoute(), predicate: (route) => false);
          } else if (state is AuthenticationFailure) {
            context.router
                .pushAndPopUntil(LoginRoute(), predicate: (route) => false);
          }
        },
        builder: (context, state) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
