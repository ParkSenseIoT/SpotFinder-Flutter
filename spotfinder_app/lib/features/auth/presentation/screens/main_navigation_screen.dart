import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../notifications/presentation/screens/notification_center_screen.dart';
import '../../../notifications/presentation/widgets/unread_badge.dart';
import '../../../parking/presentation/screens/parking_map_screen.dart';
import '../../../payments/presentation/screens/payments_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/auth_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  Widget _placeholder(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryNeon, size: 60),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Coming soon',
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    final screens = <Widget>[
      _placeholder('Dashboard', Icons.dashboard_outlined),
      const ParkingMapScreen(),
      const PaymentsScreen(showAppBar: false),
      const NotificationCenterScreen(showAppBar: false, embedded: true),
      const SettingsScreen(showAppBar: false),
    ];

    final scaffold = Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: AppColors.textGray,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), label: 'Map'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined), label: 'Payments'),
          BottomNavigationBarItem(
            icon: user == null
                ? const Icon(Icons.notifications_outlined)
                : Consumer<NotificationsController>(
                    builder: (_, c, __) => UnreadBadge(
                      count: c.unreadCount,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                  ),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );

    // Share a single NotificationsController across the bottom-nav badge and
    // the Alerts tab so they always show the same unread count.
    if (user == null) return scaffold;
    return ChangeNotifierProvider(
      create: (_) => NotificationsController(userId: user.id)..load(),
      child: scaffold,
    );
  }
}
