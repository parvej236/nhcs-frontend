import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/notifications_provider.dart';

class NotificationDropdown extends StatelessWidget {
  final List<AppNotification> notifications;
  final Function(String) onMarkRead;
  final Function() onMarkAllRead;
  final Function(int) onNavigate;

  const NotificationDropdown({
    super.key,
    required this.notifications,
    required this.onMarkRead,
    required this.onMarkAllRead,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      position: PopupMenuPosition.under,
      color: t.bgCard,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.notifications_none_rounded, color: t.textSecondary, size: 20),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: t.danger, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$unreadCount',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      tooltip: 'Notifications',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.border),
      ),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: t.isDark ? 0.25 : 0.05),
      constraints: const BoxConstraints(minWidth: 340, maxWidth: 340),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: GoogleFonts.outfit(color: t.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      onMarkAllRead();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Mark all as read', style: GoogleFonts.inter(color: t.brandPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          if (notifications.isEmpty)
            PopupMenuItem<String>(
              enabled: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No new alerts.', style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
                ),
              ),
            )
          else
            ...notifications.map((n) {
              Color statusColor = t.brandPrimary;
              Color bgLight = t.brandPrimary.withValues(alpha: 0.1);
              if (n.type == 'danger') {
                statusColor = t.danger;
                bgLight = t.danger.withValues(alpha: 0.1);
              } else if (n.type == 'warning') {
                statusColor = t.warning;
                bgLight = t.warning.withValues(alpha: 0.1);
              } else if (n.type == 'success') {
                statusColor = t.success;
                bgLight = t.success.withValues(alpha: 0.1);
              }

              return PopupMenuItem<String>(
                value: n.id,
                onTap: () {
                  onMarkRead(n.id);
                  onNavigate(n.actionTab);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: n.isRead ? Colors.transparent : statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: bgLight, shape: BoxShape.circle),
                        child: Icon(
                          n.type == 'danger'
                              ? Icons.warning_amber_rounded
                              : (n.type == 'warning' ? Icons.notifications_active_rounded : Icons.info_outline_rounded),
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                                      color: t.textPrimary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!n.isRead)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: t.brandPrimary, shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.description,
                              style: GoogleFonts.inter(color: t.textSecondary, fontSize: 11, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(n.timestamp, style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.6), fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ];
      },
    );
  }
}
