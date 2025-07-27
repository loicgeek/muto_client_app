import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:muto_driver_app/app/ui/app_theme.dart';
import 'package:muto_driver_app/app/widgets/app_button.dart';
import 'package:muto_driver_app/app/widgets/app_logo.dart';
import 'package:muto_driver_app/app/widgets/app_text_field.dart';

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
  final _idCardNumberController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();
  final _addressController = TextEditingController();

  // Password visibility
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  // Document files
  File? _driverLicenseFile;
  File? _idCardFile;

  // Role selection
  String _selectedRole = 'courier';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _idCardNumberController.dispose();
    _driverLicenseNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String documentType) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (documentType == 'driver_license') {
            _driverLicenseFile = File(image.path);
          } else if (documentType == 'id_card') {
            _idCardFile = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
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
      case 2:
        return _validateDocuments();
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

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      _showError('Please enter a valid email address');
      return false;
    }

    return true;
  }

  bool _validateCredentials() {
    if (_passwordController.text.isEmpty ||
        _passwordConfirmationController.text.isEmpty ||
        _addressController.text.isEmpty) {
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

  bool _validateDocuments() {
    if (_idCardNumberController.text.isEmpty ||
        _driverLicenseNumberController.text.isEmpty) {
      _showError('Please fill in all document numbers');
      return false;
    }

    if (_driverLicenseFile == null || _idCardFile == null) {
      _showError('Please upload both driver license and ID card documents');
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Here you would implement the actual API call
      // using the form data and file uploads

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login or dashboard
      Navigator.of(context).pop();
    } catch (e) {
      _showError('Registration failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Tab(text: 'Documents'),
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
            _buildDocumentsStep(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
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
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Role',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: 'courier', child: Text('Courier')),
                    DropdownMenuItem(value: 'driver', child: Text('Driver')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
            ],
          ),
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
          const SizedBox(height: 20),
          AppTextField(
            labelText: 'Address',
            hintText: 'Enter your full address',
            controller: _addressController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Documents',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your identification documents',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          AppTextField(
            labelText: 'ID Card Number',
            hintText: 'Enter your ID card number',
            controller: _idCardNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ID card number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildDocumentUpload(
            title: 'ID Card',
            subtitle: 'Upload a clear photo of your ID card',
            file: _idCardFile,
            onTap: () => _pickImage('id_card'),
          ),
          const SizedBox(height: 20),
          AppTextField(
            labelText: 'Driver License Number',
            hintText: 'Enter your driver license number',
            controller: _driverLicenseNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Driver license number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildDocumentUpload(
            title: 'Driver License',
            subtitle: 'Upload a clear photo of your driver license',
            file: _driverLicenseFile,
            onTap: () => _pickImage('driver_license'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    file != null ? AppTheme.primaryBlue : AppTheme.inputBorder,
                width: file != null ? 2 : 1,
              ),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
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
              text: _currentStep == 2 ? 'Create Account' : 'Next',
              onPressed: _nextStep,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
