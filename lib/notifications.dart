import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todoapp_live/task.dart';
import 'package:todoapp_live/util.dart';

Future<void> createReminderNotification(Task task) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'scheduled_channel',
        title: task.title,
        body: dateFormat.format(task.date),
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(key: 'MARK_DONE', label: 'Mark done'),
      ],
      schedule: NotificationCalendar(
          year: task.date.year,
          month: task.date.month,
          day: task.date.day,
          hour: task.date.hour,
          minute: task.date.minute,
          second: 0,
          millisecond: 0,
          repeats: true));
}
