import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/price_chart_widget.dart';
import '../widgets/market_trends_widget.dart';
import '../widgets/filter_bottom_sheet.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedSortBy = 'Price: Low to High';
  bool _showMyListings = false;
  bool _isLoading = false;

  // Mock data - in real app, this would come from API
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Fresh Tomatoes',
      'category': 'Vegetables',
      'price': 2.50,
      'unit': 'kg',
      'quantity': 100,
      'location': 'Nairobi, Kenya',
      'seller': 'John Kamau',
      'rating': 4.5,
      'image': 'https://example.com/tomatoes.jpg',
      'description': 'Fresh red tomatoes from my farm',
      'isOrganic': true,
      'harvestDate': '2024-01-15',
      'expiryDate': '2024-01-22',
    },
    {
      'id': '2',
      'name': 'Maize Grain',
      'category': 'Grains',
      'price': 1.80,
      'unit': 'kg',
      'quantity': 500,
      'location': 'Kisumu, Kenya',
      'seller': 'Mary Akinyi',
      'rating': 4.8,
      'image': 'https://example.com/maize.jpg',
      'description': 'Quality maize grain, well dried',
      'isOrganic': false,
      'harvestDate': '2024-01-10',
      'expiryDate': '2024-06-10',
    },
    {
      'id': '3',
      'name': 'Avocados',
      'category': 'Fruits',
      'price': 3.20,
      'unit': 'kg',
      'quantity': 50,
      'location': 'Mombasa, Kenya',
      'seller': 'Ahmed Hassan',
      'rating': 4.2,
      'image': 'https://example.com/avocados.jpg',
      'description': 'Ripe Hass avocados',
      'isOrganic': true,
      'harvestDate': '2024-01-12',
      'expiryDate': '2024-01-19',
    },
  ];

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Livestock',
    'Dairy',
    'Seeds',
    'Fertilizers',
  ];

  final List<String> _sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Distance: Nearest',
    'Rating: Highest',
    'Newest First',
  ];

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

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = List.from(_products);

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => 
        product['category'] == _selectedCategory
      ).toList();
    }

    // Filter by my listings
    if (_showMyListings) {
      filtered = filtered.where((product) => 
        product['seller'] == 'Current User'
      ).toList();
    }

    // Sort products
    switch (_selectedSortBy) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Rating: Highest':
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'Newest First':
        filtered.sort((a, b) => b['harvestDate'].compareTo(a['harvestDate']));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add listing
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyTab(theme),
          _buildSellTab(theme),
          _buildTrendsTab(theme),
        ],
      ),
    );
  }

  Widget _buildBuyTab(ThemeData theme) {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
        ),

        // Products List
        Expanded(
          child: _isLoading
              ? const LoadingShimmer()
              : _filteredProducts.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            // Navigate to product details
                          },
                          onBuy: () {
                            // Add to cart or buy now
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSellTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Listings Toggle
          Row(
            children: [
              Text(
                'My Listings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: _showMyListings,
                onChanged: (value) {
                  setState(() {
                    _showMyListings = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Active Listings',
                  '12',
                  Icons.store,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Total Sales',
                  '\$2,450',
                  Icons.attach_money,
                  AppTheme.secondaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // My Products
          Text(
            'My Products',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Add New Product Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Add New Product',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'List your agricultural products for sale',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Sales
          Text(
            'Recent Sales',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Mock recent sales
          _buildRecentSaleItem(theme, 'Tomatoes', '5kg', '\$12.50', '2 hours ago'),
          _buildRecentSaleItem(theme, 'Maize', '20kg', '\$36.00', '1 day ago'),
          _buildRecentSaleItem(theme, 'Avocados', '3kg', '\$9.60', '2 days ago'),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Overview
          Text(
            'Market Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Price Trends Chart
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PriceChartWidget(),
          ),
          const SizedBox(height: 24),

          // Market Trends
          Text(
            'Trending Products',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          MarketTrendsWidget(),
          const SizedBox(height: 24),

          // Price Alerts
          Text(
            'Price Alerts',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildPriceAlertCard(theme, 'Tomatoes', 'Price increased by 15%'),
          _buildPriceAlertCard(theme, 'Maize', 'Price decreased by 8%'),
          _buildPriceAlertCard(theme, 'Avocados', 'Price stable'),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, 
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSaleItem(ThemeData theme, String product, String quantity, 
      String amount, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.check,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$quantity • $amount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAlertCard(ThemeData theme, String product, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: AppTheme.successGreen,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_off),
            onPressed: () {
              // Disable price alert
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedSortBy: _selectedSortBy,
        sortOptions: _sortOptions,
        onSortChanged: (value) {
          setState(() {
            _selectedSortBy = value;
          });
        },
      ),
    );
  }
} 