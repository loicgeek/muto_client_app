import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:muto_driver_app/app/ui/app_theme.dart';

// Assuming your AppTheme is imported
// import 'app_theme.dart';

@RoutePage()
class DriverDeliveriesScreen extends StatefulWidget {
  const DriverDeliveriesScreen({super.key});

  @override
  State<DriverDeliveriesScreen> createState() => _DriverDeliveriesScreenState();
}

class _DriverDeliveriesScreenState extends State<DriverDeliveriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'Today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock delivery data
  final List<Map<String, dynamic>> deliveries = [
    {
      'id': 'DEL-2024-001',
      'status': 'completed',
      'pickupAddress': '123 Restaurant St, Downtown',
      'dropoffAddress': '456 Customer Ave, Uptown',
      'customerName': 'Sarah Johnson',
      'orderValue': 24.99,
      'earnings': 8.50,
      'tip': 5.00,
      'distance': '3.2 km',
      'duration': '25 mins',
      'completedAt': '2:30 PM',
      'rating': 5,
      'paymentMethod': 'Card',
    },
    {
      'id': 'DEL-2024-002',
      'status': 'in_progress',
      'pickupAddress': '789 Pizza Palace, Midtown',
      'dropoffAddress': '321 Office Building, Business District',
      'customerName': 'Mike Chen',
      'orderValue': 18.75,
      'earnings': 6.25,
      'tip': 0.00,
      'distance': '2.1 km',
      'duration': '18 mins',
      'completedAt': null,
      'rating': null,
      'paymentMethod': 'Cash',
    },
    {
      'id': 'DEL-2024-003',
      'status': 'assigned',
      'pickupAddress': '555 Burger Joint, Eastside',
      'dropoffAddress': '777 Residential Complex, Westside',
      'customerName': 'Emma Davis',
      'orderValue': 32.40,
      'earnings': 9.75,
      'tip': 0.00,
      'distance': '4.8 km',
      'duration': '35 mins',
      'completedAt': null,
      'rating': null,
      'paymentMethod': 'Card',
    },
    {
      'id': 'DEL-2024-004',
      'status': 'completed',
      'pickupAddress': '111 Cafe Corner, City Center',
      'dropoffAddress': '222 Park Avenue, Suburb',
      'customerName': 'Alex Wilson',
      'orderValue': 15.60,
      'earnings': 5.50,
      'tip': 3.00,
      'distance': '1.8 km',
      'duration': '15 mins',
      'completedAt': '1:15 PM',
      'rating': 4,
      'paymentMethod': 'Card',
    },
    {
      'id': 'DEL-2024-005',
      'status': 'failed',
      'pickupAddress': '333 Sushi Bar, Downtown',
      'dropoffAddress': '444 Apartment Complex, Northside',
      'customerName': 'Lisa Brown',
      'orderValue': 28.90,
      'earnings': 0.00,
      'tip': 0.00,
      'distance': '3.5 km',
      'duration': '0 mins',
      'completedAt': '12:45 PM',
      'rating': null,
      'paymentMethod': 'Card',
      'failureReason': 'Customer not available',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDeliveryList(
                    _getFilteredDeliveries(['assigned', 'in_progress'])),
                _buildDeliveryList(_getFilteredDeliveries(['completed'])),
                _buildDeliveryList(_getFilteredDeliveries(['failed'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'My Deliveries',
        style: AppTheme.headingMedium,
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Handle search
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            selectedFilter,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${deliveries.length} deliveries',
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.darkGray,
        indicatorColor: AppTheme.primaryBlue,
        labelStyle: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment, size: 16),
                const SizedBox(width: 4),
                Text('Active (${_getFilteredDeliveries([
                      'assigned',
                      'in_progress'
                    ]).length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 4),
                Text('Completed (${_getFilteredDeliveries([
                      'completed'
                    ]).length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 16),
                const SizedBox(width: 4),
                Text('Failed (${_getFilteredDeliveries(['failed']).length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryList(List<Map<String, dynamic>> filteredDeliveries) {
    if (filteredDeliveries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDeliveries.length,
      itemBuilder: (context, index) {
        return _buildDeliveryCard(filteredDeliveries[index]);
      },
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => _showDeliveryDetails(delivery),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeliveryHeader(delivery),
              const SizedBox(height: 12),
              _buildLocationInfo(delivery),
              const SizedBox(height: 12),
              _buildDeliveryFooter(delivery),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryHeader(Map<String, dynamic> delivery) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(delivery['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(delivery['status']),
            color: _getStatusColor(delivery['status']),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${delivery['id']}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                delivery['customerName'],
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(delivery['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(delivery['status']),
                style: AppTheme.bodySmall.copyWith(
                  color: _getStatusColor(delivery['status']),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (delivery['completedAt'] != null) ...[
              const SizedBox(height: 4),
              Text(
                delivery['completedAt'],
                style: AppTheme.bodySmall,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo(Map<String, dynamic> delivery) {
    return Column(
      children: [
        _buildLocationItem(
          icon: Icons.restaurant,
          address: delivery['pickupAddress'],
          isPickup: true,
        ),
        const SizedBox(height: 8),
        _buildLocationItem(
          icon: Icons.home,
          address: delivery['dropoffAddress'],
          isPickup: false,
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String address,
    required bool isPickup,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isPickup
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isPickup ? Colors.orange : Colors.green,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: AppTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryFooter(Map<String, dynamic> delivery) {
    return Row(
      children: [
        _buildInfoChip(
          icon: Icons.attach_money,
          label: '\$${delivery['orderValue'].toStringAsFixed(2)}',
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 8),
        _buildInfoChip(
          icon: Icons.route,
          label: delivery['distance'],
          color: AppTheme.darkGray,
        ),
        const SizedBox(width: 8),
        _buildInfoChip(
          icon: Icons.access_time,
          label: delivery['duration'],
          color: AppTheme.darkGray,
        ),
        const Spacer(),
        if (delivery['status'] == 'completed') ...[
          if (delivery['rating'] != null) ...[
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              delivery['rating'].toString(),
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '+\$${(delivery['earnings'] + delivery['tip']).toStringAsFixed(2)}',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (delivery['status'] == 'failed') ...[
          Icon(
            Icons.error,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Failed',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No deliveries found',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deliveries will appear here when they are assigned to you',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredDeliveries(List<String> statuses) {
    return deliveries
        .where((delivery) => statuses.contains(delivery['status']))
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'assigned':
        return AppTheme.primaryBlue;
      case 'failed':
        return Colors.red;
      default:
        return AppTheme.darkGray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.local_shipping;
      case 'assigned':
        return Icons.assignment;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'assigned':
        return 'Assigned';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  void _showFilterBottomSheet() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Deliveries',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 16),
              ...['Today', 'Yesterday', 'This Week', 'This Month', 'All Time']
                  .map((filter) => ListTile(
                        title: Text(filter),
                        leading: Radio<String>(
                          value: filter,
                          groupValue: selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value!;
                            });
                            Navigator.pop(context);
                          },
                          activeColor: AppTheme.primaryBlue,
                        ),
                      )),
            ],
          ),
        );
      },
    );
  }

  void _showDeliveryDetails(Map<String, dynamic> delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.mediumGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Delivery Details',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildDetailItem('Order ID', delivery['id']),
                        _buildDetailItem('Customer', delivery['customerName']),
                        _buildDetailItem(
                            'Status', _getStatusText(delivery['status'])),
                        _buildDetailItem('Order Value',
                            '\$${delivery['orderValue'].toStringAsFixed(2)}'),
                        _buildDetailItem('Distance', delivery['distance']),
                        _buildDetailItem('Duration', delivery['duration']),
                        _buildDetailItem(
                            'Payment Method', delivery['paymentMethod']),
                        if (delivery['earnings'] > 0)
                          _buildDetailItem('Earnings',
                              '\$${delivery['earnings'].toStringAsFixed(2)}'),
                        if (delivery['tip'] > 0)
                          _buildDetailItem(
                              'Tip', '\$${delivery['tip'].toStringAsFixed(2)}'),
                        if (delivery['rating'] != null)
                          _buildDetailItem(
                              'Rating', '${delivery['rating']}/5 stars'),
                        if (delivery['failureReason'] != null)
                          _buildDetailItem(
                              'Failure Reason', delivery['failureReason']),
                        const SizedBox(height: 16),
                        Text(
                          'Addresses',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailItem('Pickup', delivery['pickupAddress']),
                        _buildDetailItem(
                            'Drop-off', delivery['dropoffAddress']),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
}
