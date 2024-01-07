// DrawerPage.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kolay_app/screens/log_in.dart';
import 'package:kolay_app/service/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String email = '';
  late String name = '';
  late String photoURL = '';
  User? _user;
  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserData();
  }

  _loadUserData() async {
    if (_user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('USERS').doc(_user!.uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data()!;
        // Now you can use userData to populate your UI
        setState(() {
          // Update UI with user data
          // e.g., assign values to variables that are bound to your UI widgets
          email = userData['email'];
          name = userData['name'];
          photoURL = userData['photoURL'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Profile',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: photoURL.isNotEmpty
                    ? Image.file(File(photoURL))
                    : Image.asset('lib/assets/default_profile_picture.jpg'),
              ),
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            title: const Text('Log Out'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
