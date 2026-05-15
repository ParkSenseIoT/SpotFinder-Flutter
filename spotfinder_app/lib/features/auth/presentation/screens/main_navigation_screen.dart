import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../notifications/presentation/screens/notification_center_screen.dart';
import '../../../notifications/presentation/screens/notification_preferences_screen.dart';
import '../../../notifications/presentation/widgets/unread_badge.dart';
import '../../../parking/presentation/screens/parking_map_screen.dart';
import '../../../payments/presentation/screens/payments_screen.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

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

  Widget _settingsPanel(BuildContext context) {
    final user = context.watch<AuthController>().user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _row(Icons.badge_outlined, 'Name', user?.fullName ?? '—'),
            _row(Icons.alternate_email, 'Email', user?.email ?? '—'),
            _row(Icons.shield_outlined, 'Roles', user?.roles.join(', ') ?? '—'),
            const SizedBox(height: 24),
            _menuTile(
              context,
              icon: Icons.notifications_active_outlined,
              label: 'Preferencias de notificaciones',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationPreferencesScreen(),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await context.read<AuthController>().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryNeon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryNeon.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryNeon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGray),
          ],
        ),
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
      _settingsPanel(context),
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
