import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/waste_model.dart';
import '../../services/database_service.dart';

// Screen to view available waste posts from farmers
// Processors can browse and select waste to buy

class ViewWastePostsScreen extends StatefulWidget {
  const ViewWastePostsScreen({super.key});

  @override
  State<ViewWastePostsScreen> createState() => _ViewWastePostsScreenState();
}

class _ViewWastePostsScreenState extends State<ViewWastePostsScreen> {
  List<WasteModel> wastePostsList = [];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Available', 'Processing', 'Sold'];

  @override
  void initState() {
    super.initState();
    _loadWastePosts();
  }

  Future<void> _loadWastePosts() async {
    setState(() => _isLoading = true);
    try {
      final dbService = DatabaseService();
      final posts = await dbService.getAllWastePosts();
      setState(() {
        wastePostsList = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedFilter == 'All'
        ? wastePostsList
        : wastePostsList
            .where((waste) => waste.status == _selectedFilter.toLowerCase())
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Waste Posts'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppTheme.backgroundColor,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryGreen,
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          // Waste posts list
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No waste posts found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final waste = filteredList[index];
                      return _buildWasteCard(context, waste);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteCard(BuildContext context, WasteModel waste) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with farmer info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        waste.wasteType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posted by ${waste.farmerName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(waste.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    waste.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Quantity', '${waste.quantity} kg'),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Price',
                  waste.pricePerKg != null
                      ? '₹${waste.pricePerKg}/kg'
                      : 'Negotiable',
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Location', waste.location),
                const SizedBox(height: 12),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  waste.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showContactDialog(context, waste),
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact Farmer'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: waste.status == 'available'
                        ? () => _showInterestDialog(context, waste)
                        : null,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Show Interest'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppTheme.primaryGreen;
      case 'processing':
        return Colors.orange;
      case 'sold':
        return Colors.grey;
      default:
        return AppTheme.primaryGreen;
    }
  }

  void _showContactDialog(BuildContext context, WasteModel waste) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Farmer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${waste.farmerName}'),
            const SizedBox(height: 12),
            Text('Phone: ${waste.farmerPhone}'),
            const SizedBox(height: 12),
            Text('Waste Type: ${waste.wasteType}'),
            const SizedBox(height: 12),
            Text('Quantity: ${waste.quantity} kg'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement actual call functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showInterestDialog(BuildContext context, WasteModel waste) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Express Interest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waste Type: ${waste.wasteType}'),
            const SizedBox(height: 12),
            Text('Quantity: ${waste.quantity} kg'),
            const SizedBox(height: 12),
            const Text('Your interest has been noted. The farmer will contact you soon.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save interest to Firebase
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Interest expressed successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
