import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/fertilizer_model.dart';

// Display list of fertilizers from database
// Each card shows name, price, processor name
// Add buy button

class BuyFertilizerScreen extends StatefulWidget {
  const BuyFertilizerScreen({super.key});

  @override
  State<BuyFertilizerScreen> createState() => _BuyFertilizerScreenState();
}

class _BuyFertilizerScreenState extends State<BuyFertilizerScreen> {
  bool _isLoading = true;
  final List<FertilizerModel> _fertilizers = [];

  @override
  void initState() {
    super.initState();
    _loadFertilizers();
  }

  Future<void> _loadFertilizers() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Create fertilizer table and load from database
      // For now, keep empty list until fertilizer selling feature is implemented
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showBuyDialog(FertilizerModel fertilizer) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buy Fertilizer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${fertilizer.fertilizerName}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Process order
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order placed successfully!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Fertilizer'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fertilizers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No fertilizers available yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFertilizers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _fertilizers.length,
                    itemBuilder: (context, index) {
                      final fertilizer = _fertilizers[index];
                      return _FertilizerCard(
                        fertilizer: fertilizer,
                        onBuy: () => _showBuyDialog(fertilizer),
                      );
                    },
                  ),
                ),
    );
  }
}

class _FertilizerCard extends StatelessWidget {
  final FertilizerModel fertilizer;
  final VoidCallback onBuy;

  const _FertilizerCard({
    required this.fertilizer,
    required this.onBuy,
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
                    fertilizer.fertilizerName,
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
                    fertilizer.fertilizerType,
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
              fertilizer.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.factory, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  fertilizer.processorName,
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
                  fertilizer.location,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    Text(
                      '₹${fertilizer.pricePerKg}/kg',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onBuy,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Buy Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
