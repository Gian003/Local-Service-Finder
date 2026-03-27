import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/dataset/mock_service.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/navigation/home/notification/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications = MockService.getNotifications();
  }

  //Icon per Notification type
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'payment':
        return FontAwesomeIcons.wallet;
      case 'reminder':
        return FontAwesomeIcons.bell;
      case 'booking':
        return FontAwesomeIcons.bookBookmark;
      case 'review':
        return FontAwesomeIcons.star;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Map<String, List<NotificationModel>> get _groupedNotifications {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();

    for (final notification in _notifications) {
      final difference = now.difference(notification.createdAt).inDays;
      String label;

      if (difference == 0) {
        label = 'Today';
      } else if (difference == 1) {
        label = 'Yesterday';
      } else {
        label = 'Earlier';
      }

      grouped.putIfAbsent(label, () => []).add(notification);
    }

    return grouped;
  }

  void _markAllasRead() {
    setState(() {
      _notifications = _notifications
          .map(
            (notification) => NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              isRead: true,
              createdAt: notification.createdAt,
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupedNotifications;
    final hasUnread = _notifications.any(
      (notification) => !notification.isRead,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllasRead,
            child: Text(
              'Mark all as Read',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.secondaryColor,
              ),
            ),
          ),
        ],
      ),

      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                //Render each Grouped Notification
                ...['Today', 'Yesterday', 'Earlier'].map((label) {
                  final items = groupedNotifications[label];
                  if (items == null || items.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      //Notification Cards
                      ...items.map(
                        (notification) => _buildNotifcationCard(notification),
                      ),

                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildNotifcationCard(NotificationModel notificationModel) {
    return GestureDetector(
      onTap: () {
        //Mark as read
        setState(() {
          _notifications = _notifications.map((notification) {
            if (notification.id == notificationModel.id) {
              return NotificationModel(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                isRead: true,
                createdAt: notification.createdAt,
              );
            }
            return notification;
          }).toList();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(12),
            right: Radius.circular(12),
          ),
          border: Border.all(
            color: notificationModel.isRead
                ? Colors.grey[200]!
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  _getNotificationIcon((notificationModel.type)),
                  color: AppColors.primaryColor,
                  size: 18,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificationModel.title,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: notificationModel.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),

                      if (!notificationModel.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    notificationModel.message,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.bell, size: 60, color: Colors.grey[300]),

          const SizedBox(height: 16),

          Text(
            'No notifications yet',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
