import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tile.dart';
import 'notification_preferences_screen.dart';

/// Driver-facing inbox. Lists every notification, lets the user tap to mark
/// as read, and gives quick access to the preferences screen + "mark all as
/// read" action.
///
/// Designed to live both inside the bottom navigation bar (as the "Alerts"
/// tab) and as a stand-alone route opened from the bell icon.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({
    super.key,
    this.showAppBar = true,
    this.embedded = false,
  });

  /// When mounted inside the bottom nav we hide the AppBar (the parent
  /// already provides chrome). When pushed as its own route, we render one.
  final bool showAppBar;

  /// When true, the screen assumes a `NotificationsController` is already
  /// provided upstream (e.g. from `MainNavigationScreen`) so the bottom-nav
  /// badge and the screen stay in sync. When false, the screen creates its
  /// own controller.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return const _NotificationCenterView(showAppBar: false);
    }

    final user = context.watch<AuthController>().user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Inicia sesión para ver tus notificaciones.',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => NotificationsController(userId: user.id)..load(),
      child: _NotificationCenterView(showAppBar: showAppBar),
    );
  }
}

class _NotificationCenterView extends StatelessWidget {
  const _NotificationCenterView({required this.showAppBar});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();

    final body = SafeArea(
      top: !showAppBar,
      child: RefreshIndicator(
        color: AppColors.primaryNeon,
        onRefresh: controller.refresh,
        child: _buildList(context, controller),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Notificaciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: _actions(context, controller),
            )
          : null,
      body: showAppBar
          ? body
          : Column(
              children: [
                _InlineHeader(controller: controller),
                Expanded(child: body),
              ],
            ),
    );
  }

  List<Widget> _actions(BuildContext context, NotificationsController controller) {
    return [
      if (controller.unreadCount > 0)
        IconButton(
          tooltip: 'Marcar todas como leídas',
          icon: const Icon(Icons.done_all),
          onPressed: controller.markAllAsRead,
        ),
      IconButton(
        tooltip: 'Preferencias',
        icon: const Icon(Icons.tune),
        onPressed: () => _openPreferences(context),
      ),
    ];
  }

  void _openPreferences(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
    );
  }

  Widget _buildList(BuildContext context, NotificationsController controller) {
    if (controller.isLoading && controller.notifications.isEmpty) {
      return const _LoadingState();
    }
    if (controller.errorMessage != null && controller.notifications.isEmpty) {
      return _ErrorState(message: controller.errorMessage!);
    }
    if (controller.notifications.isEmpty) {
      return const _EmptyState();
    }

    final items = controller.notifications;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final n = items[i];
        return NotificationTile(
          notification: n,
          onTap: () => controller.markAsRead(n),
        );
      },
    );
  }
}

/// Header shown when the screen runs inside the bottom navigation (no AppBar).
class _InlineHeader extends StatelessWidget {
  const _InlineHeader({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.primaryNeon, size: 26),
          const SizedBox(width: 10),
          const Text(
            'Notificaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          if (controller.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryNeon),
              ),
              child: Text(
                '${controller.unreadCount} nuevas',
                style: const TextStyle(
                  color: AppColors.primaryNeon,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          if (controller.unreadCount > 0)
            IconButton(
              tooltip: 'Marcar todas como leídas',
              icon: const Icon(Icons.done_all, color: AppColors.primaryNeon),
              onPressed: controller.markAllAsRead,
            ),
          IconButton(
            tooltip: 'Preferencias',
            icon: const Icon(Icons.tune, color: AppColors.primaryNeon),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationPreferencesScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Icon(Icons.notifications_none,
                  color: AppColors.textGray, size: 64),
              SizedBox(height: 14),
              Text(
                'Sin notificaciones por ahora',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              SizedBox(height: 6),
              Text(
                'Te avisaremos cuando ingreses, debas pagar o tu sesión termine.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Icon(Icons.cloud_off,
                  color: AppColors.textGray, size: 60),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Desliza hacia abajo para reintentar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
