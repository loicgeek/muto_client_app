import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muto_driver_app/app/core/network/api_filter.dart';
import 'package:muto_driver_app/app/core/service_locator.dart';
import 'package:muto_driver_app/app/features/authentication/business_logic/cubit/authentication_cubit.dart';
import 'package:muto_driver_app/app/features/home/business_logic/deliveries/deliveries_cubit.dart';
import 'package:muto_driver_app/app/features/home/data/models/delivery_model.dart';
import 'package:muto_driver_app/app/features/home/presentation/widgets/deliveries_list_widget.dart';
import 'package:muto_driver_app/app/features/home/repositories/deliveries_repository.dart';
import 'package:muto_driver_app/app/ui/app_theme.dart';

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
  late DeliveriesCubit _activeDeliveriesCubit;
  late DeliveriesCubit _completedDeliveriesCubit;
  late DeliveriesCubit _failedDeliveriesCubit;
  final ApiFilter _activeDeliveriesFilter = ApiFilter()
    ..whereIn('status', ['assigned', 'pending']);
  final ApiFilter _completedDeliveriesFilter = ApiFilter()
    ..whereIn('status', ['completed']);
  final ApiFilter _failedDeliveriesFilter = ApiFilter()
    ..whereIn('status', ['failed']);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _activeDeliveriesCubit =
        DeliveriesCubit(deliveriesRepository: getIt<DeliveriesRepository>());
    _completedDeliveriesCubit =
        DeliveriesCubit(deliveriesRepository: getIt<DeliveriesRepository>());
    _failedDeliveriesCubit =
        DeliveriesCubit(deliveriesRepository: getIt<DeliveriesRepository>());

    var user = context.read<AuthenticationCubit>().state.user;
    _activeDeliveriesFilter.whereExact('courier_id', user?.courier?.id);
    _completedDeliveriesFilter.whereExact('courier_id', user?.courier?.id);
    _failedDeliveriesFilter.whereExact('courier_id', user?.courier?.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock delivery data using the DeliveryModel model
  List<DeliveryModel> deliveries = [];

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
            child: IndexedStack(
              index: _tabController.index,
              children: [
                DeliveriesListWidget(
                  deliveriesCubit: _activeDeliveriesCubit,
                  filter: _activeDeliveriesFilter,
                ),
                DeliveriesListWidget(
                  deliveriesCubit: _completedDeliveriesCubit,
                  filter: _completedDeliveriesFilter,
                ),
                DeliveriesListWidget(
                  deliveriesCubit: _failedDeliveriesCubit,
                  filter: _failedDeliveriesFilter,
                ),
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
        onTap: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
        unselectedLabelStyle: AppTheme.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment, size: 16),
                const SizedBox(width: 4),
                BlocBuilder<DeliveriesCubit, DeliveriesState>(
                  bloc: _activeDeliveriesCubit,
                  builder: (context, state) {
                    return Text(
                        'Active (${state.pageData?.meta.total ?? '0'})');
                  },
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 4),
                BlocBuilder<DeliveriesCubit, DeliveriesState>(
                  bloc: _completedDeliveriesCubit,
                  builder: (context, state) {
                    return Text(
                        'Completed (${state.pageData?.meta.total ?? '0'})');
                  },
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 16),
                const SizedBox(width: 4),
                BlocBuilder<DeliveriesCubit, DeliveriesState>(
                  bloc: _failedDeliveriesCubit,
                  builder: (context, state) {
                    return Text(
                        'Failed (${state.pageData?.meta.total ?? '0'})');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}
