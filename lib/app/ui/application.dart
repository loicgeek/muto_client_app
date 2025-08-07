// assuming this is the root widget of your App
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_client_app/app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/home/business_logic/current_delivery/current_delivery_cubit.dart';
import 'package:muto_client_app/app/features/home/repositories/deliveries_repository.dart';
import 'package:muto_client_app/app/ui/loading_overlay.dart';
import 'package:provider/provider.dart';

class Application extends StatelessWidget {
  final appRouter = getIt<AppRouter>();

  Application({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoadingController(),
      child: BlocProvider(
        create: (context) => CurrentDeliveryCubit(
          deliveriesRepository: getIt<DeliveriesRepository>(),
        ),
        child: MaterialApp.router(
          routerConfig: appRouter.config(),
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
