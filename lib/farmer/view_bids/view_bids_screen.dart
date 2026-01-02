// View Bids Screen - For farmers to view and manage bids on their waste posts
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/bid_provider.dart';
import '../../models/bid_model.dart';

class ViewBidsScreen extends StatefulWidget {
  final String wastePostId;
  final String farmerId;
  final double quantity; // kg

  const ViewBidsScreen({
    Key? key,
    required this.wastePostId,
    required this.farmerId,
    required this.quantity,
  }) : super(key: key);

  @override
  State<ViewBidsScreen> createState() => _ViewBidsScreenState();
}

class _ViewBidsScreenState extends State<ViewBidsScreen> {
  late BidProvider _bidProvider;

  @override
  void initState() {
    super.initState();
    _bidProvider = Provider.of<BidProvider>(context, listen: false);
    _loadBids();
  }

  void _loadBids() {
    _bidProvider.fetchAllBidsForWastePost(widget.wastePostId);
  }

  void _showBidDetails(BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bid Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Bidder', bid.bidderName),
              _buildDetailRow('Phone', bid.bidderPhone),
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
            ],
          ),
        ),
        actions: [
          if (bid.status == 'active')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectBid(bid.id);
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          if (bid.status == 'active')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _acceptBid(bid);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Accept', style: TextStyle(color: Colors.white)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _acceptBid(BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Acceptance'),
        content: Text(
          'Accept bid from ${bid.bidderName} for ₹${bid.bidAmount.toStringAsFixed(2)}/kg?\n\nThis will reject all other bids.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bidProvider.acceptBid(
                bidId: bid.id,
                wastePostId: widget.wastePostId,
              ).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bid accepted successfully!')),
                  );
                  _loadBids();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${_bidProvider.error}')),
                  );
                }
              });
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _rejectBid(String bidId) {
    _bidProvider.rejectBid(bidId).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid rejected')),
        );
        _loadBids();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_bidProvider.error}')),
        );
      }
    });
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
              style: const TextStyle(color: Colors.grey),
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
        title: const Text('Bids for Your Waste'),
        elevation: 0,
      ),
      body: Consumer<BidProvider>(
        builder: (context, bidProvider, _) {
          if (bidProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bidProvider.bidsForWastePost.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gavel, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No bids yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Processors will place bids on your waste post',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Separate bids by status
          final activeBids = bidProvider.bidsForWastePost
              .where((b) => b.status == 'active')
              .toList();
          final acceptedBids = bidProvider.bidsForWastePost
              .where((b) => b.status == 'accepted')
              .toList();
          final rejectedBids = bidProvider.bidsForWastePost
              .where((b) => b.status == 'rejected')
              .toList();

          return RefreshIndicator(
            onRefresh: () => _bidProvider.fetchAllBidsForWastePost(widget.wastePostId),
            child: ListView(
              children: [
                if (acceptedBids.isNotEmpty) ...[
                  _buildSectionHeader('✅ Accepted (${acceptedBids.length})', Colors.green),
                  ...acceptedBids.map((bid) => _buildBidCard(bid)),
                ],
                if (activeBids.isNotEmpty) ...[
                  _buildSectionHeader('🔔 Active Bids (${activeBids.length})', Colors.blue),
                  ...activeBids.map((bid) => _buildBidCard(bid)),
                ],
                if (rejectedBids.isNotEmpty) ...[
                  _buildSectionHeader('❌ Rejected (${rejectedBids.length})', Colors.grey),
                  ...rejectedBids.map((bid) => _buildBidCard(bid)),
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
                      Text(
                        bid.bidderName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bid.bidderPhone,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                      const Text('Price per kg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '₹${bid.bidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
              if (bid.message.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bid.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Bid placed on ${bid.createdAt.day}/${bid.createdAt.month}/${bid.createdAt.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
