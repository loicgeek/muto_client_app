import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:muto_client_app/app/core/router/app_router.gr.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_client_app/app/features/home/business_logic/current_delivery/current_delivery_cubit.dart';
import 'package:muto_client_app/app/features/home/data/models/delivery_model.dart';
import 'package:muto_client_app/app/features/notifications/data/services/location_service.dart';
import 'package:muto_client_app/app/ui/app_theme.dart';
import 'package:muto_client_app/app/ui/ui_utils.dart';
import 'package:latlong2/latlong.dart';

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

  late AnimationController _slideController;

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
            child: BlocBuilder<CurrentDeliveryCubit, CurrentDeliveryState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add top padding when notification is visible

                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      bloc: _authenticationCubit,
                      builder: (context, state) {
                        var driverName =
                            '${state.user?.firstName ?? ""} ${state.user?.lastName ?? ""}';
                        var isOnline = state.user?.courier?.online ?? false;
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
                                    backgroundColor: AppTheme.primaryBlue
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      driverName
                                          .split(' ')
                                          .map((e) => e.isNotEmpty ? e[0] : '')
                                          .join(''),
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                color: isOnline
                                                    ? Colors.green
                                                    : Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Status: ${isOnline ? 'Online' : 'Offline'}',
                                              style:
                                                  AppTheme.bodyMedium.copyWith(
                                                color: isOnline
                                                    ? Colors.green
                                                    : Colors.red,
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
                                    onChanged: (value) async {
                                      await getIt
                                          .get<AuthenticationCubit>()
                                          .updateCourierOnlineStatus(
                                              isOnline: value);
                                      UiUtils.showSnackbarSuccess(
                                          context, "Status updated");
                                    },
                                    activeColor: AppTheme.primaryBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    if (state is ActivateDeliveryLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ] else if (state.delivery != null) ...[
                      _buildCurrentDeliveryCard(state.delivery!),
                      const SizedBox(height: 16),
                      _buildMapPlaceholder(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ] else ...[
                      _buildNoDeliveryCard(),
                    ],
                    const SizedBox(height: 16),
                    //  _buildEarningsCard(),
                  ],
                );
              },
            ),
          ),
          // Delivery request notification overlay
          // if (hasPendingRequest && isOnline)
          //   SlideTransition(
          //     position: _slideAnimation,
          //     child: _buildDeliveryRequestNotification(),
          //   ),
        ],
      ),
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

  Widget _buildCurrentDeliveryCard(DeliveryModel delivery) {
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
                      'Order #${delivery.id}',
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
                  'ETA ${delivery.durationMinutes} minutes',
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
            address: delivery.pickupAddress ?? "",
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _buildLocationItem(
            icon: Icons.home,
            title: 'Drop-off Location',
            address: delivery.dropoffAddress ?? "",
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
                        "${delivery.client?.firstName ?? ''} ${delivery.client?.lastName ?? ''}",
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Order Value: ${delivery.courierFee ?? 0}',
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
                  // context.router.push(DeliveryTrackingRoute());
                  var delivery =
                      context.read<CurrentDeliveryCubit>().state.delivery!;
                  context.router.push(
                    DeliveryTrackingRoute(),
                  );
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
