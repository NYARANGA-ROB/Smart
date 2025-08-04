import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/helpers.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/weather_widget.dart';
import '../widgets/market_summary_widget.dart';
import '../widgets/recent_activities_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh dashboard data
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'SmartAgriNet',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () {
                      // Navigate to profile
                    },
                  ),
                ],
              ),

              // Dashboard Content
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          _buildWelcomeSection(theme),
                          const SizedBox(height: 24),

                          // Weather Widget
                          const WeatherWidget(),
                          const SizedBox(height: 24),

                          // Quick Actions
                          _buildQuickActions(theme),
                          const SizedBox(height: 24),

                          // Dashboard Cards
                          _buildDashboardCards(theme),
                          const SizedBox(height: 24),

                          // Market Summary
                          const MarketSummaryWidget(),
                          const SizedBox(height: 24),

                          // Recent Activities
                          const RecentActivitiesWidget(),
                          const SizedBox(height: 100), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to optimize your farming today?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today is ${AppHelpers.getCurrentDate()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Lottie.asset(
            'assets/animations/farmer_welcome.json',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            QuickActionButton(
              icon: Icons.agriculture,
              title: 'Crop Planning',
              subtitle: 'Plan your crops',
              color: AppTheme.primaryGreen,
              onTap: () {
                // Navigate to crop planning
              },
            ),
            QuickActionButton(
              icon: Icons.camera_alt,
              title: 'Pest Detection',
              subtitle: 'Scan for pests',
              color: AppTheme.accentBlue,
              onTap: () {
                // Navigate to pest detection
              },
            ),
            QuickActionButton(
              icon: Icons.water_drop,
              title: 'Irrigation',
              subtitle: 'Smart watering',
              color: AppTheme.accentBlue,
              onTap: () {
                // Navigate to irrigation
              },
            ),
            QuickActionButton(
              icon: Icons.store,
              title: 'Marketplace',
              subtitle: 'Buy & sell',
              color: AppTheme.secondaryOrange,
              onTap: () {
                // Navigate to marketplace
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCards(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            DashboardCard(
              title: 'Active Crops',
              value: '12',
              subtitle: 'Growing well',
              icon: Icons.eco,
              color: AppTheme.successGreen,
              trend: '+2 this week',
              onTap: () {
                // Navigate to crops
              },
            ),
            DashboardCard(
              title: 'Total Area',
              value: '45.2',
              subtitle: 'Hectares',
              icon: Icons.area_chart,
              color: AppTheme.primaryGreen,
              trend: '+5.2 ha',
              onTap: () {
                // Navigate to farm management
              },
            ),
            DashboardCard(
              title: 'This Month',
              value: '\$2,450',
              subtitle: 'Revenue',
              icon: Icons.attach_money,
              color: AppTheme.secondaryOrange,
              trend: '+12% vs last month',
              onTap: () {
                // Navigate to financials
              },
            ),
            DashboardCard(
              title: 'Livestock',
              value: '156',
              subtitle: 'Animals',
              icon: Icons.pets,
              color: AppTheme.accentBlue,
              trend: 'All healthy',
              onTap: () {
                // Navigate to livestock
              },
            ),
          ],
        ),
      ],
    );
  }
} 