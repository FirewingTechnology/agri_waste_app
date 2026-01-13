import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/auth_provider.dart';

import 'view_waste_posts/view_waste_posts_screen.dart';
import 'sell_fertilizer/sell_fertilizer_screen.dart';
import 'chatbot/processor_chatbot_screen.dart';
import 'history/processor_history_screen.dart';
import 'manage_bids/manage_bids_screen.dart';

// Manufacturer Dashboard UI (formerly Processor)
// Cards: Buy Waste, Sell Fertilizer, Chatbot, History

class ManufacturerDashboard extends StatefulWidget {
  const ManufacturerDashboard({super.key});

  @override
  State<ManufacturerDashboard> createState() => _ManufacturerDashboardState();
}

class _ManufacturerDashboardState extends State<ManufacturerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ManufacturerHomeScreen(),
    const ViewWastePostsScreen(),
    const SellFertilizerScreen(),
    const ProcessorChatbotScreen(),
    const ProcessorHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco),
              label: 'Waste',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist_outlined),
              activeIcon: Icon(Icons.local_florist),
              label: 'Fertilizer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'AI Mentor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

class ManufacturerHomeScreen extends StatelessWidget {
  const ManufacturerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manufacturer Dashboard'),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🏭',
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome, Manufacturer!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Transform waste into valuable fertilizers',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Scale your production today',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _ActionCard(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Browse Waste',
                  subtitle: 'Source raw materials',
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewWastePostsScreen(),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.local_florist,
                  title: 'Add Fertilizer',
                  subtitle: 'List your products',
                  gradient: const LinearGradient(
                    colors: [AppTheme.lightGreen, AppTheme.accentLime],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellFertilizerScreen(),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.gavel,
                  title: 'My Bids',
                  subtitle: 'Manage your bids',
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentOrange, Colors.deepOrangeAccent],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageBidsScreen(
                          processorId: 'temp_user_id', // TODO: Get from auth
                        ),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.smart_toy,
                  title: 'AI Mentor',
                  subtitle: 'Production guidance',
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentLime, AppTheme.lightGreen],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProcessorChatbotScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business Statistics
            const Text(
              '📊 Business Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Waste Purchased',
                    value: '0',
                    unit: 'kg',
                    icon: Icons.eco,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Fertilizer Sold',
                    value: '0',
                    unit: 'kg',
                    icon: Icons.local_florist,
                    color: AppTheme.lightGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Active Bids',
                    value: '0',
                    unit: 'bids',
                    icon: Icons.gavel,
                    color: AppTheme.accentOrange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Revenue',
                    value: '₹0',
                    unit: '',
                    icon: Icons.currency_rupee,
                    color: AppTheme.accentLime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Action Card Widget
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Logout dialog helper function
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
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
