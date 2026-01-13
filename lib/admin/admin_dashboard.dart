import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

// Enhanced Admin Dashboard with User Verification and System Monitoring
// Features: User Verification, Bidding Logs, Payment Logs, Notification Logs

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.verified_user), text: 'Verification'),
            Tab(icon: Icon(Icons.gavel), text: 'Bids'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UserVerificationTab(),
          BiddingLogsTab(),
          PaymentLogsTab(),
          NotificationLogsTab(),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Logout using AuthProvider
                try {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// ==========================
// USER VERIFICATION TAB
// ==========================
class UserVerificationTab extends StatefulWidget {
  const UserVerificationTab({super.key});

  @override
  State<UserVerificationTab> createState() => _UserVerificationTabState();
}

class _UserVerificationTabState extends State<UserVerificationTab> {
  final DatabaseService _dbService = DatabaseService();
  List<UserModel> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch unverified users from database
      final allUsers = await _dbService.getAllUsers();
      _pendingUsers = allUsers.where((user) => !user.verified).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _verifyUser(UserModel user, bool approve) async {
    try {
      // Update user verification status in database
      final updatedUser = user.copyWith(verified: approve);
      await _dbService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'User approved ✓' : 'User rejected ✗'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
        _loadPendingUsers(); // Reload the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending verifications',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingUsers.length,
        itemBuilder: (context, index) {
          final user = _pendingUsers[index];
          return _UserVerificationCard(
            user: user,
            onApprove: () => _verifyUser(user, true),
            onReject: () => _verifyUser(user, false),
          );
        },
      ),
    );
  }
}

class _UserVerificationCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _UserVerificationCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
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
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.email, text: user.email),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.phone, text: user.phone),
            if (user.address != null) ...[
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.location_on, text: user.address!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

// ==========================
// BIDDING LOGS TAB
// ==========================
class BiddingLogsTab extends StatelessWidget {
  const BiddingLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Bidding Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track all bidding activities in the system',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature implementation in progress')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('View All Bids'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// PAYMENT LOGS TAB
// ==========================
class PaymentLogsTab extends StatelessWidget {
  const PaymentLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor all payment transactions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature implementation in progress')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Payments'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// NOTIFICATION LOGS TAB
// ==========================
class NotificationLogsTab extends StatelessWidget {
  const NotificationLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Notification Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View all system notifications',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature implementation in progress')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
