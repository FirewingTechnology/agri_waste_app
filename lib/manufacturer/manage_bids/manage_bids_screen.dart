// Manage Bids Screen - For processors to manage their bids
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/bid_provider.dart';
import '../../models/bid_model.dart';

class ManageBidsScreen extends StatefulWidget {
  final String processorId;

  const ManageBidsScreen({
    Key? key,
    required this.processorId,
  }) : super(key: key);

  @override
  State<ManageBidsScreen> createState() => _ManageBidsScreenState();
}

class _ManageBidsScreenState extends State<ManageBidsScreen> {
  late BidProvider _bidProvider;

  @override
  void initState() {
    super.initState();
    _bidProvider = Provider.of<BidProvider>(context, listen: false);
    _loadMyBids();
  }

  void _loadMyBids() {
    _bidProvider.fetchMyBids(widget.processorId);
  }

  void _showBidDetails(BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bid Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Waste Post ID', bid.wastePostId.substring(0, 8) + '...'),
              _buildDetailRow('Bid Amount', '₹${bid.bidAmount.toStringAsFixed(2)}/kg'),
              _buildDetailRow('Total Bid', '₹${bid.totalBidAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Status', bid.status.toUpperCase()),
              const SizedBox(height: 12),
              const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(bid.message),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Bid Date',
                '${bid.createdAt.day}/${bid.createdAt.month}/${bid.createdAt.year}',
              ),
              if (bid.respondedAt != null)
                _buildDetailRow(
                  'Response Date',
                  '${bid.respondedAt!.day}/${bid.respondedAt!.month}/${bid.respondedAt!.year}',
                ),
            ],
          ),
        ),
        actions: [
          if (bid.status == 'active')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelBid(bid.id);
              },
              child: const Text('Cancel Bid', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _cancelBid(String bidId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Bid'),
        content: const Text('Are you sure you want to cancel this bid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bidProvider.cancelBid(bidId).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bid cancelled')),
                  );
                  _loadMyBids();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${_bidProvider.error}')),
                  );
                }
              });
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
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
        title: const Text('My Bids'),
        elevation: 0,
      ),
      body: Consumer<BidProvider>(
        builder: (context, bidProvider, _) {
          if (bidProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bidProvider.myBids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gavel, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No bids placed yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Browse waste posts and place bids',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Separate bids by status
          final activeBids =
              bidProvider.myBids.where((b) => b.status == 'active').toList();
          final acceptedBids = bidProvider.myBids
              .where((b) => b.status == 'accepted')
              .toList();
          final rejectedBids = bidProvider.myBids
              .where((b) => b.status == 'rejected')
              .toList();
          final cancelledBids = bidProvider.myBids
              .where((b) => b.status == 'cancelled')
              .toList();

          return RefreshIndicator(
            onRefresh: () => _bidProvider.fetchMyBids(widget.processorId),
            child: ListView(
              children: [
                if (acceptedBids.isNotEmpty) ...[
                  _buildSectionHeader('✅ Accepted (${acceptedBids.length})', Colors.green),
                  ...acceptedBids.map((bid) => _buildBidCard(bid)),
                ],
                if (activeBids.isNotEmpty) ...[
                  _buildSectionHeader('🔔 Active (${activeBids.length})', Colors.blue),
                  ...activeBids.map((bid) => _buildBidCard(bid)),
                ],
                if (rejectedBids.isNotEmpty) ...[
                  _buildSectionHeader('❌ Rejected (${rejectedBids.length})', Colors.red),
                  ...rejectedBids.map((bid) => _buildBidCard(bid)),
                ],
                if (cancelledBids.isNotEmpty) ...[
                  _buildSectionHeader('⊘ Cancelled (${cancelledBids.length})', Colors.grey),
                  ...cancelledBids.map((bid) => _buildBidCard(bid)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBidCard(BidModel bid) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showBidDetails(bid),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Waste Post',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        bid.wastePostId.substring(0, 8) + '...',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bid.status == 'active'
                          ? Colors.blue[100]
                          : bid.status == 'accepted'
                              ? Colors.green[100]
                              : bid.status == 'rejected'
                                  ? Colors.red[100]
                                  : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bid.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: bid.status == 'active'
                            ? Colors.blue
                            : bid.status == 'accepted'
                                ? Colors.green
                                : bid.status == 'rejected'
                                    ? Colors.red
                                    : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price per kg',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '₹${bid.bidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '₹${bid.totalBidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Placed on ${bid.createdAt.day}/${bid.createdAt.month}/${bid.createdAt.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
