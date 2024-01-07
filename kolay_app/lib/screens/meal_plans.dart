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
                  icon: const Icon(Icons.person, color: Colors.white),
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new Meal Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'The name of your Meal Plan'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: const Text('Pick Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
