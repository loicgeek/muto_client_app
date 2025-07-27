import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muto_driver_app/app/ui/app_theme.dart';

// Assuming your AppTheme is imported
// import 'app_theme.dart';

@RoutePage()
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({Key? key}) : super(key: key);

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Today';

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

  // Mock earnings data
  final Map<String, dynamic> earningsData = {
    'today': {
      'totalEarnings': 145.50,
      'deliveries': 8,
      'tips': 32.00,
      'bonuses': 15.00,
      'totalDistance': 45.2,
      'totalTime': '6h 30m',
      'averagePerDelivery': 18.19,
    },
    'week': {
      'totalEarnings': 890.75,
      'deliveries': 42,
      'tips': 156.25,
      'bonuses': 75.00,
      'totalDistance': 268.4,
      'totalTime': '35h 15m',
      'averagePerDelivery': 21.21,
    },
    'month': {
      'totalEarnings': 3245.80,
      'deliveries': 178,
      'tips': 645.30,
      'bonuses': 285.00,
      'totalDistance': 1156.7,
      'totalTime': '145h 20m',
      'averagePerDelivery': 18.24,
    },
  };

  final List<Map<String, dynamic>> paymentHistory = [
    {
      'id': 'PAY-2024-001',
      'date': '2024-07-26',
      'amount': 245.50,
      'type': 'weekly_payout',
      'status': 'completed',
      'method': 'bank_transfer',
      'deliveries': 15,
      'period': 'July 20 - July 26, 2024',
    },
    {
      'id': 'PAY-2024-002',
      'date': '2024-07-19',
      'amount': 198.75,
      'type': 'weekly_payout',
      'status': 'completed',
      'method': 'bank_transfer',
      'deliveries': 12,
      'period': 'July 13 - July 19, 2024',
    },
    {
      'id': 'PAY-2024-003',
      'date': '2024-07-12',
      'amount': 312.20,
      'type': 'weekly_payout',
      'status': 'completed',
      'method': 'bank_transfer',
      'deliveries': 18,
      'period': 'July 6 - July 12, 2024',
    },
    {
      'id': 'BON-2024-001',
      'date': '2024-07-10',
      'amount': 50.00,
      'type': 'peak_hours_bonus',
      'status': 'completed',
      'method': 'bank_transfer',
      'deliveries': 0,
      'period': 'Peak Hours Bonus - July 10',
    },
    {
      'id': 'PAY-2024-004',
      'date': '2024-07-05',
      'amount': 275.90,
      'type': 'weekly_payout',
      'status': 'pending',
      'method': 'bank_transfer',
      'deliveries': 16,
      'period': 'June 29 - July 5, 2024',
    },
  ];

  final List<Map<String, dynamic>> dailyEarnings = [
    {'day': 'Mon', 'earnings': 125.50, 'deliveries': 7},
    {'day': 'Tue', 'earnings': 98.25, 'deliveries': 5},
    {'day': 'Wed', 'earnings': 156.75, 'deliveries': 9},
    {'day': 'Thu', 'earnings': 189.00, 'deliveries': 11},
    {'day': 'Fri', 'earnings': 145.50, 'deliveries': 8},
    {'day': 'Sat', 'earnings': 98.50, 'deliveries': 6},
    {'day': 'Sun', 'earnings': 77.25, 'deliveries': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildEarningsOverview(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildStatisticsTab(),
                _buildPaymentHistoryTab(),
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
        'Earnings',
        style: AppTheme.headingMedium,
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // Handle download earnings report
            _showDownloadOptions();
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Handle more options
            _showMoreOptions();
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
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
            selectedPeriod,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              _showPeriodSelector();
            },
            icon: const Icon(Icons.expand_more),
            label: const Text('Change'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsOverview() {
    final data =
        earningsData[selectedPeriod.toLowerCase()] ?? earningsData['today'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Earnings',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${data['totalEarnings'].toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                label: 'Deliveries',
                value: data['deliveries'].toString(),
                icon: Icons.delivery_dining,
              ),
              _buildOverviewItem(
                label: 'Tips',
                value: '\$${data['tips'].toStringAsFixed(0)}',
                icon: Icons.favorite,
              ),
              _buildOverviewItem(
                label: 'Avg/Order',
                value: '\$${data['averagePerDelivery'].toStringAsFixed(2)}',
                icon: Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
      ],
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
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Statistics'),
          Tab(text: 'Payments'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final data =
        earningsData[selectedPeriod.toLowerCase()] ?? earningsData['today'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsBreakdown(data),
          const SizedBox(height: 16),
          _buildPerformanceMetrics(data),
          const SizedBox(height: 16),
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(Map<String, dynamic> data) {
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
          Text(
            'Earnings Breakdown',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            label: 'Base Earnings',
            amount: data['totalEarnings'] - data['tips'] - data['bonuses'],
            icon: Icons.attach_money,
            color: AppTheme.primaryBlue,
          ),
          _buildBreakdownItem(
            label: 'Tips',
            amount: data['tips'],
            icon: Icons.favorite,
            color: Colors.green,
          ),
          _buildBreakdownItem(
            label: 'Bonuses',
            amount: data['bonuses'],
            icon: Icons.star,
            color: Colors.orange,
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earnings',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${data['totalEarnings'].toStringAsFixed(2)}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyMedium,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> data) {
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
          Text(
            'Performance Metrics',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Distance',
                  value: '${data['totalDistance']} km',
                  icon: Icons.route,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Online Time',
                  value: data['totalTime'],
                  icon: Icons.access_time,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Acceptance Rate',
                  value: '94%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Rating',
                  value: '4.8',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
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
          Text(
            'Weekly Overview',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyEarnings.map((day) {
                final maxEarnings = dailyEarnings
                    .map((d) => d['earnings'])
                    .reduce((a, b) => a > b ? a : b);
                final height = (day['earnings'] / maxEarnings) * 150;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '\$${day['earnings'].toStringAsFixed(0)}',
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day['day'],
                      style: AppTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonCard(),
          const SizedBox(height: 16),
          _buildGoalsCard(),
          const SizedBox(height: 16),
          _buildTrendsCard(),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
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
          Text(
            'Period Comparison',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          _buildComparisonItem(
            period: 'This Week vs Last Week',
            current: 890.75,
            previous: 756.30,
            isPositive: true,
          ),
          _buildComparisonItem(
            period: 'This Month vs Last Month',
            current: 3245.80,
            previous: 2987.45,
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem({
    required String period,
    required double current,
    required double previous,
    required bool isPositive,
  }) {
    final difference = current - previous;
    final percentage = (difference / previous * 100).abs();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${current.toStringAsFixed(2)}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTheme.bodySmall.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Goals',
                style: AppTheme.headingMedium,
              ),
              TextButton(
                onPressed: () {
                  // Handle set goals
                },
                child: const Text('Set Goals'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGoalItem(
            title: 'Earnings Goal',
            current: 3245.80,
            target: 4000.00,
            unit: '\$',
          ),
          _buildGoalItem(
            title: 'Deliveries Goal',
            current: 178,
            target: 200,
            unit: '',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem({
    required String title,
    required double current,
    required double target,
    required String unit,
  }) {
    final progress = current / target;
    final percentage = (progress * 100).clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$unit${current.toStringAsFixed(unit == '\$' ? 2 : 0)} / $unit${target.toStringAsFixed(unit == '\$' ? 2 : 0)}',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppTheme.inputBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}% completed',
            style: AppTheme.bodySmall.copyWith(
              color: progress >= 1.0 ? Colors.green : AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsCard() {
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
          Text(
            'Trends & Insights',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          _buildTrendItem(
            icon: Icons.trending_up,
            title: 'Peak Hours',
            description: 'Your best earning hours are 6-8 PM',
            color: Colors.green,
          ),
          _buildTrendItem(
            icon: Icons.location_on,
            title: 'Best Areas',
            description: 'Downtown and Business District generate most tips',
            color: Colors.blue,
          ),
          _buildTrendItem(
            icon: Icons.calendar_today,
            title: 'Best Days',
            description: 'Fridays and Saturdays are your peak days',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paymentHistory.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(paymentHistory[index]);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPaymentTypeText(payment['type']),
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    payment['period'],
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${payment['amount'].toStringAsFixed(2)}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(payment['status'])
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      payment['status'].toString().toUpperCase(),
                      style: AppTheme.bodySmall.copyWith(
                        color: _getPaymentStatusColor(payment['status']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 16,
                color: AppTheme.darkGray,
              ),
              const SizedBox(width: 6),
              Text(
                '${payment['deliveries']} deliveries',
                style: AppTheme.bodySmall,
              ),
              const Spacer(),
              Icon(
                Icons.account_balance,
                size: 16,
                color: AppTheme.darkGray,
              ),
              const SizedBox(width: 6),
              Text(
                payment['method'].toString().replaceAll('_', ' ').toUpperCase(),
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPaymentTypeText(String type) {
    switch (type) {
      case 'weekly_payout':
        return 'Weekly Payout';
      case 'peak_hours_bonus':
        return 'Peak Hours Bonus';
      default:
        return 'Other';
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return AppTheme.darkGray;
    }
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Today', 'Week', 'Month'].map((period) {
            return ListTile(
              title: Text(period),
              onTap: () {
                setState(() {
                  selectedPeriod = period;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Download PDF Report'),
              onTap: () {
                Navigator.pop(context);
// Implement download as PDF
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Download CSV Report'),
              onTap: () {
                Navigator.pop(context);
// Implement download as CSV
              },
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Earnings Settings'),
              onTap: () {
                Navigator.pop(context);
// Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
// Navigate to help
              },
            ),
          ],
        );
      },
    );
  }
}
