import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:muto_client_app/app/core/router/app_router.gr.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_client_app/app/features/authentication/data/auth_repository.dart';
import 'package:muto_client_app/app/features/authentication/presentation/register_screen.dart';
import 'package:muto_client_app/app/features/home/presentation/home_screen.dart';
import 'package:muto_client_app/app/features/notifications/data/notification_repository.dart';
import 'package:muto_client_app/app/ui/app_theme.dart';
import 'package:muto_client_app/app/ui/ui_utils.dart';
import 'package:muto_client_app/app/ui/validators.dart';
import 'package:muto_client_app/app/widgets/app_button.dart';
import 'package:muto_client_app/app/widgets/app_logo.dart';
import 'package:muto_client_app/app/widgets/app_text_field.dart';

// Your existing AppTheme class would be imported here
// For this example, I'll include the necessary parts

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AuthenticationCubit _authenticationCubit;

  @override
  void initState() {
    super.initState();
    _authenticationCubit = getIt.get<AuthenticationCubit>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        _authenticationCubit.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleForgotPassword() {
    context.router.push(ForgotPasswordRoute());
  }

  void _handleSignUp() {
    context.router.push(RegisterRoute());
  }

  void _saveNotificationToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      String? deviceName;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final mobileDeviceIdentifier =
          await MobileDeviceIdentifier().getDeviceId();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine;
      }

      getIt.get<NotificationRepository>().saveNotificationToken(
            token: token,
            deviceId: mobileDeviceIdentifier ?? "",
            deviceName: deviceName ?? '',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      bloc: _authenticationCubit,
      listener: (context, state) {
        if (state is AuthenticationSuccess) {
          _saveNotificationToken();
          context.router.pushAndPopUntil(
            HomeRoute(),
            predicate: (route) => false,
          );
        } else if (state is AuthenticationFailure) {
          UiUtils.showSnackbarError(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.lightGray,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    const AppLogo(),

                    // Login Title
                    Text(
                      'Login',
                      style: AppTheme.headingLarge,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Enter Login Credentials',
                      style: AppTheme.bodyMedium,
                    ),

                    const SizedBox(height: 40),

                    // Email Field
                    AppTextField(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.validateEmail,
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    AppTextField(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.mediumGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: AppTheme.linkText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    AppButton(
                      text: 'LOGIN',
                      onPressed: _handleLogin,
                      isLoading: state is AuthenticationLoading,
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account ? ",
                          style: AppTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _handleSignUp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up Here',
                            style: AppTheme.linkText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Logo Widget
class ParcelaLogo extends StatelessWidget {
  const ParcelaLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Speed lines
              Positioned(
                left: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 2,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: 2,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 12,
                      height: 2,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              // Package/Box
              Positioned(
                right: 16,
                child: Container(
                  width: 20,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Orange dot
              Positioned(
                right: 12,
                bottom: 20,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // App Name
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Muto',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              TextSpan(
                text: '\nDriver',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
