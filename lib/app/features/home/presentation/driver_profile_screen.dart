import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muto_client_app/app/core/network/api_error.dart';
import 'package:muto_client_app/app/core/router/app_router.gr.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_client_app/app/ui/app_theme.dart';
import 'package:muto_client_app/app/ui/loading_overlay.dart';
import 'package:muto_client_app/app/ui/ui_utils.dart';

// Assuming your AppTheme is imported

@RoutePage()
class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  // Mock user data based on your JSON structure
  final Map<String, dynamic> userData = {
    "first_name": "Loic",
    "last_name": "Courier",
    "email": "loic.ngou98+courier@gmail.com",
    "phone": "+1234567893",
    "role": "courier",
    "id_card_number": "ID987654321",
    "driver_license_number": "DL123456789",
    "address": "456 Oak Ave, City, State 67890",
    "vehicles": [
      {
        "make": "Toyota",
        "model": "Camry",
        "year": "2020",
        "license_plate": "ABC123",
        "type": "car"
      },
      {
        "make": "Honda",
        "model": "CBR600",
        "year": "2019",
        "license_plate": "XYZ789",
        "type": "bike"
      }
    ],
    "courier": {
      "id": 1,
      "user_id": 2,
      "id_card_number": "ID987654321",
      "driver_license_number": "DL123456789",
      "active_vehicle_id": null,
      "photo": null,
      "address": "456 Oak Ave, City, State 67890",
      "status": "pending",
      "created_at": "2025-07-27T17:33:57.000000Z",
      "updated_at": "2025-07-2727T17:33:57.000000Z"
    }
  };

  int activeVehicleIndex = 0; // Default to first vehicle

  late AuthenticationCubit _authenticationCubit;

  @override
  void initState() {
    super.initState();
    _authenticationCubit = getIt.get<AuthenticationCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildPersonalInfoCard(),
            const SizedBox(height: 16),
            _buildDriverInfoCard(),
            const SizedBox(height: 16),
            _buildVehiclesCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildSettingsCard(),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'My Profile',
        style: AppTheme.headingMedium,
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Handle edit profile
            _showEditProfileDialog();
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                backgroundImage: userData['courier']['photo'] != null
                    ? NetworkImage(userData['courier']['photo'])
                    : null,
                child: userData['courier']['photo'] == null
                    ? Text(
                        '${userData['first_name'][0]}${userData['last_name'][0]}',
                        style: AppTheme.headingLarge.copyWith(
                          color: AppTheme.primaryBlue,
                          fontSize: 32,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Handle photo update
                    _showPhotoOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppTheme.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${userData['first_name']} ${userData['last_name']}',
            style: AppTheme.headingLarge,
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'],
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(userData['courier']['status'])
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(userData['courier']['status']),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(userData['courier']['status']),
                  style: AppTheme.bodySmall.copyWith(
                    color: _getStatusColor(userData['courier']['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildInfoCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
            'Full Name', '${userData['first_name']} ${userData['last_name']}'),
        _buildInfoRow('Email', userData['email']),
        _buildInfoRow('Phone', userData['phone']),
        _buildInfoRow('Address', userData['address']),
      ],
    );
  }

  Widget _buildDriverInfoCard() {
    return _buildInfoCard(
      title: 'Driver Information',
      icon: Icons.badge_outlined,
      children: [
        _buildInfoRow('ID Card Number', userData['id_card_number']),
        _buildInfoRow('Driver License', userData['driver_license_number']),
        _buildInfoRow('Driver ID',
            '#${userData['courier']['id'].toString().padLeft(6, '0')}'),
        _buildInfoRow(
            'Member Since', _formatDate(userData['courier']['created_at'])),
      ],
    );
  }

  Widget _buildVehiclesCard() {
    final vehicles = userData['vehicles'] as List<dynamic>;

    return _buildInfoCard(
      title: 'My Vehicles',
      icon: Icons.directions_car_outlined,
      children: [
        ...vehicles.asMap().entries.map((entry) {
          final index = entry.key;
          final vehicle = entry.value;
          return _buildVehicleItem(vehicle, index);
        }).toList(),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            // Handle add vehicle
            _showAddVehicleDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Vehicle'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleItem(Map<String, dynamic> vehicle, int index) {
    final isActive = index == activeVehicleIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
        border:
            isActive ? Border.all(color: AppTheme.primaryBlue, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              vehicle['type'] == 'car'
                  ? Icons.directions_car
                  : Icons.two_wheeler,
              color: isActive ? AppTheme.primaryBlue : AppTheme.darkGray,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle['year']} ${vehicle['make']} ${vehicle['model']}',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppTheme.primaryBlue : AppTheme.black,
                  ),
                ),
                Text(
                  'License: ${vehicle['license_plate']}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  activeVehicleIndex = index;
                });
                // Update active vehicle in backend
                _updateActiveVehicle(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryBlue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Set Active',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return _buildInfoCard(
      title: 'Account Status',
      icon: Icons.verified_user_outlined,
      children: [
        _buildStatusRow('Account Status', userData['courier']['status']),
        _buildStatusRow('Profile Completion', 'completed'),
        _buildStatusRow('Document Verification', userData['courier']['status']),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            subtitle: 'Password and security settings',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and legal information',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(status),
                style: AppTheme.bodySmall.copyWith(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.darkGray,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.mediumGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      bloc: _authenticationCubit,
      listener: (context, state) {},
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              var result = await _showLogoutDialog();
              if (result == true) {
                try {
                  await context.read<LoadingController>().wrapWithLoading(() {
                    return _authenticationCubit.logout();
                  });
                  context.router.replaceAll([LoginRoute()]);
                } catch (e) {
                  UiUtils.showSnackbarError(
                      context, ApiError.fromResponse(e).message);
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
      case 'rejected':
        return Colors.red;
      default:
        return AppTheme.darkGray;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Complete';
      case 'approved':
        return 'Approved';
      case 'inactive':
        return 'Inactive';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _updateActiveVehicle(int index) {
    // TODO: Update active vehicle in backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Active vehicle updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEditProfileDialog() {
    // TODO: Show edit profile dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit profile functionality')),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Profile Photo',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle gallery
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddVehicleDialog() {
    // TODO: Show add vehicle dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add vehicle functionality')),
    );
  }

  Future<bool?> _showLogoutDialog() async {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                // Handle logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
