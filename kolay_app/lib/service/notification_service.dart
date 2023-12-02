import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/milestone_provider.dart';
import 'package:kolay_app/providers/routine_provider.dart';
import 'package:kolay_app/providers/todo_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initialize(BuildContext context) {
    _initializeNotifications();
    _scheduleNotifications(context);
  }

  Future<void> _initializeNotifications() async {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: null,
      //iOS: IOSInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _scheduleNotifications(BuildContext context) async {
    // Fetch dates from different providers
    final List<DateTime> datesFromShoppingList = await Provider.of<ShoppingList>(context, listen: false).getShoppingListsForHomeScreen();
    final List<DateTime> datesFromTodoList= await Provider.of<TodoList>(context, listen: false).getToDoListsForHomeScreen();
    final List<DateTime> datesFromMealPlan = await Provider.of<MealPlan>(context, listen: false).getMealPlansForHomeScreen();

    // Combine dates from all providers
    final List<DateTime> allDates = [...datesFromShoppingList, ...datesFromTodoList, ...datesFromMealPlan];

    // Get the current date and time
    final now = DateTime.now();

    // Schedule notifications for matching dates and times
    for (final DateTime date in allDates) {
      if (_isSameDateAndTime(now, date)) {
        _scheduleNotification(date);
      }
    }
  }

  bool _isSameDateAndTime(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day &&
        dateTime1.hour == dateTime2.hour &&
        dateTime1.minute == dateTime2.minute;
  }

  Future<void> _scheduleNotification(DateTime date) async {
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: null, iOS: null);

    // Replace with your notification title and body
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Your Notification Title',
      'Your Notification Body',
      tz.TZDateTime.from(date, tz.local), // Use tz.TZDateTime for time zone support
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

}
