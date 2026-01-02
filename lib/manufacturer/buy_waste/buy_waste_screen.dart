import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/waste_model.dart';
import '../../services/database_service.dart';
import '../place_bid/place_bid_screen.dart';

// Fetch waste posts from database
// Show farmer name, waste type, quantity, location
// Add interest / buy button

class BuyWasteScreen extends StatefulWidget {
  const BuyWasteScreen({super.key});

  @override
  State<BuyWasteScreen> createState() => _BuyWasteScreenState();
}

class _BuyWasteScreenState extends State<BuyWasteScreen> {
  bool _isLoading = true;
  final List<WasteModel> _wastePosts = [];

  @override
  void initState() {
    super.initState();
    _loadWastePosts();
  }

  Future<void> _loadWastePosts() async {
    setState(() => _isLoading = true);
    try {
      final dbService = DatabaseService();
      final posts = await dbService.getAvailableWastePosts();
      setState(() {
        _wastePosts.clear();
        _wastePosts.addAll(posts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showInterestDialog(WasteModel waste) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Express Interest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${waste.wasteType} - ${waste.quantity} kg'),
            const SizedBox(height: 8),
            Text('Farmer: ${waste.farmerName}'),
            const SizedBox(height: 8),
            Text('Location: ${waste.location}'),
            const SizedBox(height: 16),
            const Text('Contact the farmer to discuss details and pricing.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Call ${waste.farmerPhone} to discuss'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Waste'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wastePosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No waste posts available',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWastePosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _wastePosts.length,
                    itemBuilder: (context, index) {
                      final waste = _wastePosts[index];
                      return _WasteCard(
                        waste: waste,
                        onInterest: () => _showInterestDialog(waste),
                        onBid: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceBidScreen(
                                wastePostId: waste.id,
                                processorId: 'current_processor_id', // Replace with actual user ID
                                processorName: 'Current Processor', // Replace with actual name
                                processorPhone: '9876543210', // Replace with actual phone
                                availableQuantity: waste.quantity,
                                suggestedPrice: waste.pricePerKg,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _WasteCard extends StatelessWidget {
  final WasteModel waste;
  final VoidCallback onInterest;
  final VoidCallback? onBid;

  const _WasteCard({
    required this.waste,
    required this.onInterest,
    this.onBid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    waste.wasteType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${waste.quantity} kg',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              waste.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  waste.farmerName,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  waste.location,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (waste.pricePerKg != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expected Price',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        '₹${waste.pricePerKg}/kg',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  )
                else
                  const Text('Price: Negotiable'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onInterest,
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact Farmer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onBid?.call(),
                    icon: const Icon(Icons.gavel),
                    label: const Text('Place Bid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
