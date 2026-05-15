import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/domain/entities/notification_status.dart';

/// Compact list of the 3 latest notifications.
/// "See all" jumps to the Alerts tab.
class RecentNotificationsCard extends StatelessWidget {
  const RecentNotificationsCard({
    super.key,
    required this.notifications,
    required this.onSeeAll,
  });

  final List<NotificationEntity> notifications;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryNeon.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.primaryNeon, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recent activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primaryNeon,
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(color: AppColors.textGray, fontSize: 13),
                  ),
                ),
              )
            else
              ...notifications.map(_buildRow),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(NotificationEntity n) {
    final unread = n.status != NotificationStatus.read;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: unread ? AppColors.primaryNeon : Colors.transparent,
              border: Border.all(color: AppColors.primaryNeon),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title.isEmpty ? n.type.name : n.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  n.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
