import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../models/waste_model.dart';
import '../../services/database_service.dart';
import '../../services/local_auth_service.dart';

// Display farmer's transaction history
// Show waste posts and fertilizer purchases

class FarmerHistoryScreen extends StatefulWidget {
  const FarmerHistoryScreen({super.key});

  @override
  State<FarmerHistoryScreen> createState() => _FarmerHistoryScreenState();
}

class _FarmerHistoryScreenState extends State<FarmerHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<WasteModel> _wastePosts = [];
  final List<OrderModel> _purchases = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = LocalAuthService();
      final currentUser = await authService.getCurrentUser();
      
      if (currentUser != null) {
        final dbService = DatabaseService();
        final posts = await dbService.getWastePostsByFarmerId(currentUser.id);
        
        setState(() {
          _wastePosts = posts;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My History'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Waste Posts'),
            Tab(text: 'Purchases'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWastePostsTab(),
                _buildPurchasesTab(),
              ],
            ),
    );
  }

  Widget _buildWastePostsTab() {
    if (_wastePosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No waste posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start by posting your agricultural waste',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _wastePosts.length,
        itemBuilder: (context, index) {
          final post = _wastePosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          post.wasteType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusBadge(post.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.scale, '${post.quantity} kg'),
                  const SizedBox(height: 8),
                  if (post.pricePerKg != null)
                    _buildInfoRow(Icons.currency_rupee, '₹${post.pricePerKg}/kg'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on_outlined, post.location),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    _formatDate(post.createdAt),
                  ),
                  if (post.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      post.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'sold':
        color = Colors.green;
        text = 'Sold';
        break;
      case 'processing':
        color = Colors.orange;
        text = 'Processing';
        break;
      case 'available':
      default:
        color = Colors.blue;
        text = 'Available';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildPurchasesTab() {
    if (_purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No purchases yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse fertilizers to make your first purchase',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchases.length,
      itemBuilder: (context, index) {
        return const Card(
          child: ListTile(
            title: Text('Purchase'),
          ),
        );
      },
    );
  }
}
