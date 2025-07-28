import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_driver_app/app/core/service_locator.dart';
import 'package:muto_driver_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_driver_app/app/features/notifications/data/services/location_service.dart';
import 'package:muto_driver_app/app/ui/app_theme.dart';

@RoutePage()
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin {
  bool isOnline = true;
  bool hasActiveDelivery = true;
  bool hasPendingRequest = true; // For demo purposes
  int acceptanceCountdown = 45; // seconds
  late AnimationController _slideController;
  late AnimationController _countdownController;
  late Animation<Offset> _slideAnimation;

  // Mock delivery request data
  final pendingDeliveryRequest = {
    "id": 4,
    "client_id": 3,
    "courier_id": 1,
    "vehicle_id": 1,
    "pickup_address": "123 Main St, City, State",
    "pickup_latitude": "40.71280000",
    "pickup_longitude": "-74.00600000",
    "pickup_scheduled_at": "2024-12-25T14:00:00.000000Z",
    "pickup_actual_at": null,
    "dropoff_address": "456 Oak Ave, City, State",
    "dropoff_latitude": "40.75890000",
    "dropoff_longitude": "-73.98510000",
    "dropoff_scheduled_at": "2024-12-25T16:00:00.000000Z",
    "dropoff_actual_at": null,
    "weight_kg": "2.50",
    "length_cm": "30.00",
    "width_cm": "20.00",
    "height_cm": "10.00",
    "package_count": 1,
    "content_type": "Electronics",
    "handling_instructions": "Handle with care - fragile",
    "distance_km": "5.2",
    "duration_minutes": "18",
    "price": "25.00",
    "courier_fee": "15.00",
    "status": "assigned",
    "notes": "Ring doorbell twice",
    "assigned_at": "2025-07-16T01:34:03.000000Z",
    "delivered_at": null,
    "deleted_at": null,
    "created_at": "2025-07-16T01:33:06.000000Z",
    "updated_at": "2025-07-16T01:34:03.000000Z",
  };

  // Mock current delivery data
  final currentDelivery = {
    'id': 'DEL-2024-001',
    'pickupAddress': '123 Restaurant St, Downtown',
    'dropoffAddress': '456 Customer Ave, Uptown',
    'customerName': 'Sarah Johnson',
    'customerPhone': '+1 (555) 123-4567',
    'estimatedTime': '15 mins',
    'orderValue': '\$24.99',
    'status': 'pickup_ready', // pickup_ready, in_transit, delivered
  };

  late AuthenticationCubit _authenticationCubit;

  @override
  void initState() {
    super.initState();
    _authenticationCubit = getIt.get<AuthenticationCubit>();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _countdownController = AnimationController(
      duration: Duration(seconds: acceptanceCountdown),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Show notification if there's a pending request
    if (hasPendingRequest && isOnline) {
      _showDeliveryRequestNotification();
    }
  }

  void _showDeliveryRequestNotification() {
    _slideController.forward();
    _countdownController.forward();

    // Start countdown timer
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && acceptanceCountdown > 0 && hasPendingRequest) {
        setState(() {
          acceptanceCountdown--;
        });
        if (acceptanceCountdown > 0) {
          _startCountdownTimer();
        } else {
          _handleDeclineRequest(); // Auto-decline when timer expires
        }
      }
    });
  }

  void _handleAcceptRequest() {
    setState(() {
      hasPendingRequest = false;
      hasActiveDelivery = true;
    });
    _slideController.reverse();
    _countdownController.stop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery request accepted!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDeclineRequest() {
    setState(() {
      hasPendingRequest = false;
    });
    _slideController.reverse();
    _countdownController.stop();

    // Show decline message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery request declined'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add top padding when notification is visible
                if (hasPendingRequest) const SizedBox(height: 160),
                _buildDriverStatusCard(),
                const SizedBox(height: 16),
                if (hasActiveDelivery) ...[
                  _buildCurrentDeliveryCard(),
                  const SizedBox(height: 16),
                  _buildMapPlaceholder(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ] else ...[
                  _buildNoDeliveryCard(),
                ],
                const SizedBox(height: 16),
                _buildEarningsCard(),
              ],
            ),
          ),
          // Delivery request notification overlay
          if (hasPendingRequest && isOnline)
            SlideTransition(
              position: _slideAnimation,
              child: _buildDeliveryRequestNotification(),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryRequestNotification() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with countdown
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Delivery Request',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      'Order #${pendingDeliveryRequest['id']}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: acceptanceCountdown <= 10
                      ? Colors.red.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '$acceptanceCountdown',
                    style: AppTheme.headingMedium.copyWith(
                      color: acceptanceCountdown <= 10
                          ? Colors.red
                          : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delivery details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationDetailRow(
                      Icons.location_on,
                      'Distance',
                      '${pendingDeliveryRequest['distance_km']} km',
                    ),
                    const SizedBox(height: 8),
                    _buildNotificationDetailRow(
                      Icons.access_time,
                      'Duration',
                      '${pendingDeliveryRequest['duration_minutes']} mins',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationDetailRow(
                      Icons.attach_money,
                      'Your Fee',
                      '\$${pendingDeliveryRequest['courier_fee']}',
                    ),
                    const SizedBox(height: 8),
                    _buildNotificationDetailRow(
                      Icons.inventory_2,
                      'Content',
                      '${pendingDeliveryRequest['content_type']}',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pickup and dropoff addresses
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${pendingDeliveryRequest['pickup_address']!}",
                        style: AppTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${pendingDeliveryRequest['dropoff_address']!}",
                        style: AppTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleDeclineRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: AppTheme.buttonText.copyWith(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _handleAcceptRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Accept Delivery',
                    style: AppTheme.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDetailRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.darkGray,
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: AppTheme.bodySmall,
        ),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Driver Dashboard',
        style: AppTheme.headingMedium,
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu
          },
        ),
      ],
    );
  }

  Widget _buildDriverStatusCard() {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      bloc: _authenticationCubit,
      builder: (context, state) {
        var driverName =
            '${state.user?.firstName ?? ""} ${state.user?.lastName ?? ""}';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Text(
                      driverName.split(' ').map((e) => e[0]).join(''),
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $driverName',
                          style: AppTheme.headingMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${isOnline ? 'Online' : 'Offline'}',
                              style: AppTheme.bodyMedium.copyWith(
                                color: isOnline ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOnline,
                    onChanged: (value) {
                      setState(() {
                        isOnline = value;
                        if (value && !hasPendingRequest) {
                          // Simulate new request when going online
                          Future.delayed(Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                hasPendingRequest = true;
                                acceptanceCountdown = 45;
                              });
                              _showDeliveryRequestNotification();
                            }
                          });
                        }
                      });
                    },
                    activeColor: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Delivery',
                      style: AppTheme.headingMedium,
                    ),
                    Text(
                      'Order #${currentDelivery['id']}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ETA ${currentDelivery['estimatedTime']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationItem(
            icon: Icons.restaurant,
            title: 'Pickup Location',
            address: currentDelivery['pickupAddress']!,
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _buildLocationItem(
            icon: Icons.home,
            title: 'Drop-off Location',
            address: currentDelivery['dropoffAddress']!,
            isCompleted: false,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppTheme.darkGray,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDelivery['customerName']!,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Order Value: ${currentDelivery['orderValue']}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Handle call customer
                  },
                  icon: Icon(
                    Icons.phone,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String title,
    required String address,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withOpacity(0.1)
                : AppTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted ? Colors.green : AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: AppTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: AppTheme.darkGray,
            ),
            const SizedBox(height: 8),
            Text(
              'Map View',
              style: AppTheme.bodyMedium,
            ),
            Text(
              'Navigation will appear here',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              LocationService.instance.startLocationService();
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(
              currentDelivery['status'] == 'pickup_ready'
                  ? 'Start Pickup'
                  : 'Mark as Delivered',
              style: AppTheme.buttonText,
            ),
            style: AppTheme.elevatedButtonTheme.style,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle navigate
                },
                icon: const Icon(Icons.navigation),
                label: Text('Navigate'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: BorderSide(color: AppTheme.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle call customer
                },
                icon: const Icon(Icons.phone),
                label: Text('Call Customer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: BorderSide(color: AppTheme.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Deliveries',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOnline
                ? 'You\'re online and ready to receive new delivery requests'
                : 'Turn on your availability to start receiving deliveries',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (!isOnline) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isOnline = true;
                });
              },
              child: Text('Go Online'),
              style: AppTheme.elevatedButtonTheme.style,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                Icons.account_balance_wallet_outlined,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Earnings',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEarningsItem('Total Earned', '\$145.50'),
              ),
              Expanded(
                child: _buildEarningsItem('Deliveries', '8'),
              ),
              Expanded(
                child: _buildEarningsItem('Tips', '\$32.00'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }
}
