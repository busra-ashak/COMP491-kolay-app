// DrawerPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kolay_app/screens/log_in.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String _userEmail = FirebaseAuth.instance.currentUser!.email ?? '';
  final String _userName = FirebaseAuth.instance.currentUser!.displayName ?? '';
  // final String _userPhoto = FirebaseAuth.instance.currentUser!.photoURL ?? '';
  final String _userPhone =
      FirebaseAuth.instance.currentUser!.phoneNumber ?? '';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor:
            themeBody[themeProvider.themeDataName]!['screenBackground'],
        appBar: AppBar(
            leading: BackButton(
                color:
                    themeBody[themeProvider.themeDataName]!['tabColorSelected'],
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Your Profile",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 75,
              ),
              const SizedBox(height: 20),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeBody[themeProvider.themeDataName]!['expandable'],
                ),
              ),
              const SizedBox(height: 10),
              ProfileInfo(label: 'Email', value: _userEmail),
              ProfileInfo(label: 'Phone', value: _userPhone),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                      icon: Icon(
                        themeIcon[themeProvider.themeDataName],
                        color: themeBody[themeProvider.themeDataName]![
                            'expandable'],
                      )),
                  ElevatedButton(
                    onPressed: () {
                      // Add your logout logic here
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                      (route) => false);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: themeBody[themeProvider.themeDataName]![
                            'expandableButton'],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ProfileInfo extends StatelessWidget {
  final String? label;
  final String? value;

  const ProfileInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text('$label: ${value ?? ''}',
            style: TextStyle(
              color:
                  themeBody[themeProvider.themeDataName]!['tabColorSelected'],
            )),
      );
    });
  }
}
