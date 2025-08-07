import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_client_app/app/core/network/api_filter.dart';
import 'package:muto_client_app/app/core/service_locator.dart';
import 'package:muto_client_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_client_app/app/features/home/business_logic/current_delivery/current_delivery_cubit.dart';
import 'package:muto_client_app/app/features/home/business_logic/deliveries/deliveries_cubit.dart';
import 'package:muto_client_app/app/features/home/data/models/delivery_model.dart';
import 'package:muto_client_app/app/features/home/repositories/deliveries_repository.dart';
import 'package:muto_client_app/app/ui/app_theme.dart';
import 'package:muto_client_app/app/ui/loading_overlay.dart';
import 'package:muto_client_app/app/widgets/app_button.dart';

class DeliveriesListWidget extends StatefulWidget {
  final DeliveriesCubit deliveriesCubit;
  final ApiFilter filter;
  const DeliveriesListWidget({
    super.key,
    required this.deliveriesCubit,
    required this.filter,
  });

  @override
  State<DeliveriesListWidget> createState() => _DeliveriesListWidgetState();
}

class _DeliveriesListWidgetState extends State<DeliveriesListWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  Widget _buildDeliveryCard(DeliveryModel delivery) {
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

  Widget _buildDeliveryHeader(DeliveryModel delivery) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(delivery.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(delivery.status),
            color: _getStatusColor(delivery.status),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${delivery.id}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _getCustomerName(delivery),
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
                color: _getStatusColor(delivery.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(delivery.status),
                style: AppTheme.bodySmall.copyWith(
                  color: _getStatusColor(delivery.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (delivery.deliveredAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTime(delivery.deliveredAt!),
                style: AppTheme.bodySmall,
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showDeliveryDetails(DeliveryModel delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          shouldCloseOnMinExtent: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        _buildDetailItem(
                            'Order ID', delivery.id?.toString() ?? 'N/A'),
                        _buildDetailItem(
                            'Customer', _getCustomerName(delivery)),
                        _buildDetailItem(
                            'Status', _getStatusText(delivery.status)),
                        _buildDetailItem(
                            'Order Value', '\$${_getPrice(delivery)}'),
                        _buildDetailItem(
                            'Package Count', '${delivery.packageCount ?? 1}'),
                        _buildDetailItem(
                            'Content Type', delivery.contentType ?? 'N/A'),
                        if (delivery.courierFee != null &&
                            delivery.courierFee != '0.00')
                          _buildDetailItem(
                              'Earnings', '\$${_getCourierFee(delivery)}'),
                        if (delivery.notes != null)
                          _buildDetailItem('Notes', delivery.notes!),
                        if (delivery.handlingInstructions != null)
                          _buildDetailItem(
                              'Instructions', delivery.handlingInstructions!),
                        const SizedBox(height: 16),
                        Text(
                          'Addresses',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailItem(
                            'Pickup', delivery.pickupAddress ?? 'N/A'),
                        _buildDetailItem(
                            'Drop-off', delivery.dropoffAddress ?? 'N/A'),
                        const SizedBox(height: 16),
                        Text(
                          'Timing',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (delivery.pickupScheduledAt != null)
                          _buildDetailItem('Pickup Scheduled',
                              _formatDateTime(delivery.pickupScheduledAt!)),
                        if (delivery.dropoffScheduledAt != null)
                          _buildDetailItem('Dropoff Scheduled',
                              _formatDateTime(delivery.dropoffScheduledAt!)),
                        if (delivery.deliveredAt != null)
                          _buildDetailItem('Delivered At',
                              _formatDateTime(delivery.deliveredAt!)),
                        if (delivery.createdAt != null)
                          _buildDetailItem('Created At',
                              _formatDateTime(delivery.createdAt!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Reject",
                          onPressed: () {
                            context.router.pop();
                          },
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: AppButton(
                        text: "Accept",
                        onPressed: () async {
                          try {
                            var courier = getIt
                                .get<AuthenticationCubit>()
                                .state
                                .user
                                ?.courier;
                            var currentDeliveryCubit =
                                context.read<CurrentDeliveryCubit>();
                            var updatedDelivery = await context
                                .read<LoadingController>()
                                .wrapWithLoading(() async {
                              return getIt
                                  .get<DeliveriesRepository>()
                                  .acceptDelivery(
                                    delivery.id!,
                                    courier?.id ?? 0,
                                  );
                            });
                            currentDeliveryCubit.activate(updatedDelivery);
                            _fetchDeliveries();
                            Navigator.pop(context);
                          } catch (e) {}
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 5),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  Widget _buildLocationInfo(DeliveryModel delivery) {
    return Column(
      children: [
        _buildLocationItem(
          icon: Icons.restaurant,
          address: delivery.pickupAddress ?? 'Unknown pickup location',
          isPickup: true,
        ),
        const SizedBox(height: 8),
        _buildLocationItem(
          icon: Icons.home,
          address: delivery.dropoffAddress ?? 'Unknown dropoff location',
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

  Widget _buildDeliveryFooter(DeliveryModel delivery) {
    return Row(
      children: [
        _buildInfoChip(
          icon: Icons.attach_money,
          label: '\$${_getPrice(delivery)}',
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 8),
        _buildInfoChip(
          icon: Icons.inventory,
          label:
              '${delivery.packageCount ?? 1} item${(delivery.packageCount ?? 1) > 1 ? 's' : ''}',
          color: AppTheme.darkGray,
        ),
        const SizedBox(width: 8),
        _buildInfoChip(
          icon: Icons.category,
          label: delivery.contentType ?? 'Items',
          color: AppTheme.darkGray,
        ),
        const Spacer(),
        if (delivery.status == 'completed') ...[
          Text(
            '+\$${_getCourierFee(delivery)}',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (delivery.status == 'failed') ...[
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
            IconButton(
              onPressed: () {
                _fetchDeliveries();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return AppTheme.primaryBlue;
      case 'failed':
        return Colors.red;
      default:
        return AppTheme.darkGray;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
      case 'pending':
        return Icons.local_shipping;
      case 'assigned':
        return Icons.assignment;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String? status) {
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
        return status ?? 'Unknown';
    }
  }

  String _getCustomerName(DeliveryModel delivery) {
    if (delivery.client != null) {
      final firstName = delivery.client!.firstName ?? '';
      final lastName = delivery.client!.lastName ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'Unknown Customer';
  }

  String _getPrice(DeliveryModel delivery) {
    if (delivery.price != null) {
      final price = double.tryParse(delivery.price!) ?? 0.0;
      return price.toStringAsFixed(2);
    }
    return '0.00';
  }

  String _getCourierFee(DeliveryModel delivery) {
    if (delivery.courierFee != null) {
      final fee = double.tryParse(delivery.courierFee!) ?? 0.0;
      return fee.toStringAsFixed(2);
    }
    return '0.00';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  Future<void> _fetchDeliveries() async {
    await widget.deliveriesCubit.fetchDeliveries(widget.filter);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<DeliveriesCubit, DeliveriesState>(
      bloc: widget.deliveriesCubit,
      builder: (context, state) {
        if (state is FetchDeliveriesLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FetchDeliveriesFailure) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: RefreshIndicator(
              onRefresh: () {
                _fetchDeliveries();
                return Future.value();
              },
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(state.error.message),
                  ),
                  IconButton(
                      onPressed: _fetchDeliveries,
                      icon: const Icon(Icons.refresh))
                ],
              ),
            ),
          );
        }
        if (state is FetchDeliveriesSuccess) {
          if (state.pageData!.data.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () {
              _fetchDeliveries();
              return Future.value();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.pageData!.data.length,
              itemBuilder: (context, index) {
                return _buildDeliveryCard(
                  state.pageData!.data[index],
                );
              },
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
