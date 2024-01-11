import 'package:flutter/material.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:kolay_app/screens/profile.dart';
import '../widgets/meal_plan_list.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';

class MealPlansPage extends StatefulWidget {
  @override
  State<MealPlansPage> createState() => MealPlansPageState();
}

class MealPlansPageState extends State<MealPlansPage> {
  @override
  void initState() {
    super.initState();
    loadMealPlans();
  }

  loadMealPlans() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<MealPlan>().getAllMealPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Theme(
          data: Theme.of(context).copyWith(
            dividerTheme: const DividerThemeData(
              color: Colors.transparent,
            ),
          ),
          child: Scaffold(
            backgroundColor:
                themeBody[themeProvider.themeDataName]!['screenBackground'],
            appBar: AppBar(
              title: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text("Your Meal Plans")),
              actions: <Widget>[
                IconButton(
                  padding: const EdgeInsets.only(right: 8),
                  icon: const Icon(Icons.person),
                  iconSize: 31.0,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                )
              ],
            ),
            body: Consumer<MealPlan>(builder: (context, viewModel, child) {
              return ListView(
                children: viewModel.mealPlans.values
                    .map(
                      (doc) => MealPlanWidget(
                        listName: doc['listName'],
                        datetime: doc['datetime'],
                        listItems: doc['listItems'],
                      ),
                    )
                    .toList(),
              );
            }),
            persistentFooterButtons: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      themeBody[themeProvider.themeDataName]!['floatingButton'],
                  boxShadow: [
                    BoxShadow(
                        color: themeBody[themeProvider.themeDataName]![
                            'floatingButtonOutline'] as Color,
                        spreadRadius: 3),
                  ],
                ),
                child: IconButton(
                  color: themeBody[themeProvider.themeDataName]![
                      'floatingButtonOutline'],
                  onPressed: () {
                    showCreateMealPlanDialog(context);
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                ),
              ),
            ],
            persistentFooterAlignment: AlignmentDirectional.bottomCenter,
          ));
    });
  }

  void showCreateMealPlanDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final ThemeProvider themeProvider = ThemeProvider();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              themeBody[themeProvider.themeDataName]!['dialogSurface']!,
          title: Text(
            'Create a new Meal Plan',
            style: TextStyle(
              color: themeBody[themeProvider.themeDataName]![
                  'dialogOnSurface']!, // Change this color to your desired color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!,
                ),
                decoration: InputDecoration(
                  labelText: 'The name of your Meal Plan',
                  labelStyle: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogPrimary']!,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final ThemeProvider themeProvider = ThemeProvider();
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                                surface: themeBody[themeProvider
                                    .themeDataName]!['dialogSurface']!,
                                primary: themeBody[themeProvider
                                    .themeDataName]!['dialogPrimary']!,
                                onPrimary: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!,
                                onSurface: themeBody[themeProvider
                                    .themeDataName]!['dialogOnSurface']!),
                          ),
                          child: child!);
                    },
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: Text(
                  'Pick Date',
                  style: TextStyle(
                    color: themeBody[themeProvider.themeDataName]![
                        'dialogOnWhiteSurface']!, // Change this color to your desired color
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String mealPlanName = nameController.text;
                if (mealPlanName.isNotEmpty) {
                  context
                      .read<MealPlan>()
                      .createMealPlan(mealPlanName, selectedDate);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Create',
                style: TextStyle(
                  color: themeBody[themeProvider.themeDataName]![
                      'dialogOnSurface']!, // Change this color to your desired color
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
