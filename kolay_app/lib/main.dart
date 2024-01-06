import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kolay_app/providers/reminder_provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/routine_provider.dart';
import 'package:kolay_app/providers/tab_index_provider.dart';
import 'package:kolay_app/providers/todo_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:kolay_app/screens/log_in.dart';
import 'package:kolay_app/widgets/bottom_navigation_bar.dart';
import 'package:kolay_app/service/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationApi().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingList()),
        ChangeNotifierProvider(create: (_) => Routine()),
        ChangeNotifierProvider(create: (_) => TodoList()),
        ChangeNotifierProvider(create: (_) => ReminderList()),
        ChangeNotifierProvider(create: (_) => MealPlan()),
        ChangeNotifierProvider(create: (_) => TabIndexProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red, brightness: Brightness.light),
          useMaterial3: true,
          fontFamily: 'PlaypenSans',
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF7B9CB),
              titleTextStyle: TextStyle(
                  color: Color(0xC14767AD), fontFamily: 'PlaypenSans'))),
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a loading indicator if the Future is still running
            return const CircularProgressIndicator();
          } else {
            // Check if the user is logged in
            if (snapshot.hasData) {
              // User is logged in, show home page
              return BottomNavigationBarController();
            } else {
              // User is not logged in, show login page
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}
