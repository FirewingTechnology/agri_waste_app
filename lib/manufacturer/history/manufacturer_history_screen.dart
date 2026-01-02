import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Display processor's transaction history
// Show waste purchases and fertilizer sales

class ProcessorHistoryScreen extends StatefulWidget {
  const ProcessorHistoryScreen({super.key});

  @override
  State<ProcessorHistoryScreen> createState() => _ProcessorHistoryScreenState();
}

class _ProcessorHistoryScreenState extends State<ProcessorHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
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
            Tab(text: 'Purchases'),
            Tab(text: 'Sales'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEmptyState(
                  icon: Icons.shopping_basket_outlined,
                  title: 'No purchases yet',
                  subtitle: 'Start buying agricultural waste',
                ),
                _buildEmptyState(
                  icon: Icons.sell_outlined,
                  title: 'No sales yet',
                  subtitle: 'List your fertilizers to start selling',
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
