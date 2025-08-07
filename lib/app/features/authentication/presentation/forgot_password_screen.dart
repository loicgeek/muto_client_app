import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_client_app/app/core/network/api_error.dart';
import 'package:muto_client_app/app/core/router/app_router.gr.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_client_app/app/features/authentication/data/auth_repository.dart';
import 'package:muto_client_app/app/ui/app_theme.dart';
import 'package:muto_client_app/app/ui/loading_overlay.dart';
import 'package:muto_client_app/app/ui/ui_utils.dart';
import 'package:muto_client_app/app/ui/validators.dart';
import 'package:muto_client_app/app/widgets/app_button.dart';
import 'package:muto_client_app/app/widgets/app_logo.dart';
import 'package:muto_client_app/app/widgets/app_text_field.dart';

// Your existing AppTheme class would be imported here
// For this example, I'll include the necessary parts

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AuthenticationCubit _authenticationCubit;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _authenticationCubit = getIt.get<AuthenticationCubit>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    // Handle forgot password navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password tapped')),
    );
  }

  void _sendResetPasswordEmail() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _isLoading = true;
          _emailSent = false;
        });
        await context.read<LoadingController>().wrapWithLoading(() {
          return getIt
              .get<AuthRepository>()
              .sendResetPasswordEmail(email: _emailController.text);
        });

        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
        UiUtils.showSnackbarSuccess(context, 'Email sent successfully');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      UiUtils.showSnackbarError(context, ApiError.fromResponse(e).message);
    }
  }

  void _updatePassword() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _isLoading = true;
        });
        await context.read<LoadingController>().wrapWithLoading(() {
          return getIt.get<AuthRepository>().resetPassword(
                token: _codeController.text,
                password: _passwordController.text,
                email: _emailController.text,
              );
        });

        setState(() {
          _isLoading = false;
        });
        UiUtils.showSnackbarSuccess(context, 'Password updated successfully');
        context.router.replaceAll([LoginRoute()]);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      UiUtils.showSnackbarError(context, ApiError.fromResponse(e).message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      bloc: _authenticationCubit,
      listener: (context, state) {},
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
                      'Forgot Password',
                      style: AppTheme.headingLarge,
                    ),

                    const SizedBox(height: 8),

                    if (!_emailSent) ...[
                      // Subtitle
                      Text(
                        'Enter your email',
                        style: AppTheme.bodyMedium,
                      ),

                      const SizedBox(height: 20),
                      // Email Field
                      AppTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.validateEmail,
                      ),

                      const SizedBox(height: 20),
                    ] else ...[
                      // Subtitle
                      Text(
                        'Enter the code sent to your email',
                        style: AppTheme.bodyMedium,
                      ),

                      const SizedBox(height: 20),
                      AppTextField(
                        labelText: 'Code',
                        hintText: 'Enter the code sent to your email',
                        controller: _codeController,
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

                      TextButton(
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                          });
                        },
                        child: Text('Send again'),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Login Button
                    if (!_emailSent) ...[
                      AppButton(
                        text: 'Reset Password',
                        onPressed: _sendResetPasswordEmail,
                        isLoading: _isLoading,
                      ),
                    ] else ...[
                      AppButton(
                        text: 'Update Password',
                        onPressed: _updatePassword,
                        isLoading: _isLoading,
                      ),
                    ],
                    const SizedBox(height: 32),
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
