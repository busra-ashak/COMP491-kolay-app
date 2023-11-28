import 'package:flutter/material.dart';
import 'package:kolay_app/providers/reminder_provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/milestone_provider.dart';
import 'package:kolay_app/providers/routine_provider.dart';
import 'package:kolay_app/providers/todo_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
 
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingList()),
        ChangeNotifierProvider(create: (_) => Milestone()),
        ChangeNotifierProvider(create: (_) => Routine()),
        ChangeNotifierProvider(create: (_) => TodoList()),
        ChangeNotifierProvider(create: (_) => ReminderList()),
        ChangeNotifierProvider(create: (_) => MealPlanList()),
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}