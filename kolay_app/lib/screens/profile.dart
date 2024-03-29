// DrawerPage.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kolay_app/screens/log_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:kolay_app/service/encryption_service.dart';
import 'package:provider/provider.dart';
import 'package:kolay_app/service/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService = EncryptionService();
  final TextEditingController _photoURLController = TextEditingController();
  late String email = '';
  late String name = '';
  late String photoURL = '';
  late String phone = '';
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

        setState(() {
          email = _encryptionService.decryptText(userData['email']);
          name = _encryptionService.decryptText(userData['name']);
          photoURL = userData['photoURL'];
          phone = _encryptionService.decryptText(userData['phoneNumber']);
          _photoURLController.text = photoURL;
        });
      }
    }
  }

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
              GestureDetector(
                onTap: _pickProfilePicture,
                child: Padding(padding: const EdgeInsets.only(bottom: 0), child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        themeBody[themeProvider.themeDataName]!['homeTitles']
                            as Color,
                    backgroundImage: _photoURLController.text.isNotEmpty
                        ? FileImage(File(_photoURLController.text))
                        : null,
                    child: _photoURLController.text.isEmpty
                        ? const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 42,
                          )
                        : null,
                  ),),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeBody[themeProvider.themeDataName]!['expandable'],
                ),
              ),
              const SizedBox(height: 10),
              ProfileInfo(label: 'Email', value: email),
              ProfileInfo(label: 'Phone', value: phone),
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
                      final ThemeProvider themeProvider = ThemeProvider();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: themeBody[
                                themeProvider.themeDataName]!['dialogSurface']!,
                            title: Text(
                              'Log out',
                              style: TextStyle(
                                color: themeBody[themeProvider.themeDataName]![
                                    'dialogOnSurface']!, // Change this color to your desired color
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to log out?',
                              style: TextStyle(
                                color: themeBody[themeProvider.themeDataName]![
                                    'dialogOnSurface']!, // Change this color to your desired color
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: themeBody[
                                            themeProvider.themeDataName]![
                                        'dialogOnSurface']!, // Change this color to your desired color
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  FireStoreService fireStoreService =
                                      FireStoreService();
                                  fireStoreService.deleteUserToken();
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                      (route) => false);
                                },
                                child: Text(
                                  'Yes',
                                  style: TextStyle(
                                    color: themeBody[
                                            themeProvider.themeDataName]![
                                        'dialogOnSurface']!, // Change this color to your desired color
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "Log out",
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

  Future<void> _pickProfilePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoURLController.text = pickedFile.path;
      });
      final DocumentReference documentReference = _firestore.collection('USERS').doc(_user!.uid);
      await documentReference.update({
         'photoURL': _photoURLController.text,
      });
    }
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
