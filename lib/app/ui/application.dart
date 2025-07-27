// assuming this is the root widget of your App
import 'package:muto_driver_app/app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:muto_driver_app/app/core/service_locator.dart';

class Application extends StatelessWidget {
  final appRouter = getIt<AppRouter>();

  Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: child!,
        );
      },
    );
  }
}
