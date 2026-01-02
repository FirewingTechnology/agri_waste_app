// Place Bid Screen - For processors to place bids on waste posts
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/bid_provider.dart';

class PlaceBidScreen extends StatefulWidget {
  final String wastePostId;
  final String processorId;
  final String processorName;
  final String processorPhone;
  final double availableQuantity; // kg
  final double? suggestedPrice; // Optional starting price

  const PlaceBidScreen({
    Key? key,
    required this.wastePostId,
    required this.processorId,
    required this.processorName,
    required this.processorPhone,
    required this.availableQuantity,
    this.suggestedPrice,
  }) : super(key: key);

  @override
  State<PlaceBidScreen> createState() => _PlaceBidScreenState();
}

class _PlaceBidScreenState extends State<PlaceBidScreen> {
  late TextEditingController _bidPriceController;
  late TextEditingController _messageController;
  late TextEditingController _quantityController;
  late BidProvider _bidProvider;

  @override
  void initState() {
    super.initState();
    _bidProvider = Provider.of<BidProvider>(context, listen: false);
    _bidPriceController = TextEditingController(
      text: widget.suggestedPrice?.toStringAsFixed(2) ?? '',
    );
    _messageController = TextEditingController();
    _quantityController =
        TextEditingController(text: widget.availableQuantity.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _bidPriceController.dispose();
    _messageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  double get _bidQuantity {
    return double.tryParse(_quantityController.text) ?? 0;
  }

  double get _bidPrice {
    return double.tryParse(_bidPriceController.text) ?? 0;
  }

  double get _totalBidAmount {
    return _bidQuantity * _bidPrice;
  }

  void _submitBid() {
    // Validation
    if (_bidPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter bid price')),
      );
      return;
    }

    if (_bidQuantity <= 0 || _bidQuantity > widget.availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid quantity')),
      );
      return;
    }

    if (_bidPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be greater than 0')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Quantity', '${_bidQuantity.toStringAsFixed(2)} kg'),
            _buildRow('Price per kg', '₹${_bidPrice.toStringAsFixed(2)}'),
            const Divider(),
            _buildRow(
              'Total Amount',
              '₹${_totalBidAmount.toStringAsFixed(2)}',
              isBold: true,
              color: Colors.green,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _placeBid();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Place Bid',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _placeBid() {
    _bidProvider.placeBid(
      wastePostId: widget.wastePostId,
      bidderId: widget.processorId,
      bidderName: widget.processorName,
      bidderPhone: widget.processorPhone,
      bidAmount: _bidPrice,
      totalBidAmount: _totalBidAmount,
      message: _messageController.text.isNotEmpty
          ? _messageController.text
          : 'Standard bid',
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid placed successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_bidProvider.error}')),
        );
      }
    });
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Bid'),
        elevation: 0,
      ),
      body: Consumer<BidProvider>(
        builder: (context, bidProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Quantity Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Quantity',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                          Text(
                            '${widget.availableQuantity.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Input
                  const Text(
                    'Quantity you want to bid for',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter quantity in kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: 'kg',
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),

                  // Price Input
                  const Text(
                    'Bid Price per kg',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bidPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter price in ₹',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixText: '₹ ',
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bid Summary Card
                  if (_bidQuantity > 0 && _bidPrice > 0)
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bid Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRow(
                              'Quantity',
                              '${_bidQuantity.toStringAsFixed(2)} kg',
                            ),
                            _buildRow(
                              'Rate per kg',
                              '₹${_bidPrice.toStringAsFixed(2)}',
                            ),
                            const Divider(),
                            _buildRow(
                              'Total Bid Amount',
                              '₹${_totalBidAmount.toStringAsFixed(2)}',
                              isBold: true,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Message Input
                  const Text(
                    'Message (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Add any details about your offer, pickup availability, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: bidProvider.isLoading ? null : _submitBid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: bidProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Place Bid',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
