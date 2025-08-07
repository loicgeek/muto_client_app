import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_client_app/app/core/network/api_error.dart';
import 'package:muto_client_app/app/core/router/app_router.gr.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';

import 'package:muto_client_app/app/ui/app_theme.dart';
import 'package:muto_client_app/app/ui/loading_overlay.dart';
import 'package:muto_client_app/app/ui/ui_utils.dart';
import 'package:muto_client_app/app/widgets/app_button.dart';
import 'package:muto_client_app/app/widgets/app_logo.dart';
import 'package:muto_client_app/app/widgets/app_text_field.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  // Password visibility
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  // Role selection

  late AuthenticationCubit _authenticationCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _authenticationCubit = getIt.get<AuthenticationCubit>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _tabController.animateTo(_currentStep);
      }
    } else {
      _handleSignUp();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _tabController.animateTo(_currentStep);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateCredentials();

      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showError('Please fill in all personal information fields');
      return false;
    }

    if (isValidEmail(_emailController.text) != null) {
      _showError('Please enter a valid email address');
      return false;
    }

    return true;
  }

  static String? isValidEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      var regex = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

      if (!regex.hasMatch(value)) {
        return "Please enter a valid email address";
      }
    }
    return null;
  }

  bool _validateCredentials() {
    if (_passwordController.text.isEmpty ||
        _passwordConfirmationController.text.isEmpty) {
      _showError('Please fill in all credential fields');
      return false;
    }

    if (_passwordController.text != _passwordConfirmationController.text) {
      _showError('Passwords do not match');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters long');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authenticationCubit.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );
      setState(() {
        _isLoading = false;
      });

      // Navigate to login or dashboard
    } catch (e) {
      UiUtils.showSnackbarError(context, ApiError.fromResponse(e).message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      bloc: _authenticationCubit,
      listener: (context, state) {
        if (state is AuthenticationSuccess) {
          context.router.replaceAll([HomeRoute()]);
        } else if (state is AuthenticationFailure) {
          UiUtils.showSnackbarError(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.lightGray,
          appBar: AppBar(
            backgroundColor: AppTheme.lightGray,
            elevation: 0,
            title: const Text('Sign Up'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.mediumGray,
              indicatorColor: AppTheme.primaryBlue,
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Credentials'),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildCredentialsStep(),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(),
          const SizedBox(height: 32),
          Text(
            'Personal Information',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppTextField(
            labelText: 'Email',
            hintText: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (isValidEmail(value) != null) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppTextField(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Credentials',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account security',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          AppTextField(
            labelText: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppTextField(
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            controller: _passwordConfirmationController,
            obscureText: _obscurePasswordConfirmation,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePasswordConfirmation
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppTheme.mediumGray,
              ),
              onPressed: () {
                setState(() {
                  _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: _currentStep == 1 ? 'Create Account' : 'Next',
              onPressed: _nextStep,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
