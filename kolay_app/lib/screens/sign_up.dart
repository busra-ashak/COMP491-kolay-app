import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kolay_app/providers/theme_provider.dart';
import 'package:kolay_app/screens/log_in.dart';
import 'package:kolay_app/widgets/bottom_navigation_bar.dart';
import 'package:kolay_app/service/firebase_auth_services.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _photoURLController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _photoURLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor:
            themeBody[themeProvider.themeDataName]!['screenBackground'],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickProfilePicture,
                  child: Padding(padding: EdgeInsets.only(bottom: 20), child: CircleAvatar(
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
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: themeBody[themeProvider.themeDataName]![
                              'homeTitles'] as Color),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10))
                      ]),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color:
                                        themeBody[themeProvider.themeDataName]![
                                            'homeTitles'] as Color))),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Name",
                              hintStyle: TextStyle(color: Colors.grey[700])),
                        ),
                      ),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color:
                                        themeBody[themeProvider.themeDataName]![
                                            'homeTitles'] as Color))),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.grey[700])),
                        ),
                      ),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color:
                                        themeBody[themeProvider.themeDataName]![
                                            'homeTitles'] as Color))),
                        child: TextField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Phone Number",
                              hintStyle: TextStyle(color: Colors.grey[700])),
                        ),
                      ),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                obscureText: true,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info),
                              color: themeBody[themeProvider.themeDataName]![
                                  'homeTitles'] as Color,
                              onPressed: _showPasswordRequirements,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [
                          themeBody[themeProvider.themeDataName]![
                              'expandableButton'] as Color,
                          themeBody[themeProvider.themeDataName]!['homeTitles']
                              as Color,
                        ])),
                    child: const Center(
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                          color: themeBody[themeProvider.themeDataName]!['tick']
                              as Color),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false);
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(
                              color: themeBody[themeProvider.themeDataName]![
                                  'homeTitles'] as Color,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  void _signUp() async {
    String name = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phoneNumber = _phoneNumberController.text;
    String photoURL = _photoURLController.text;
    if (isEmailValid(email)) {
      if (password.length >= 8 &&
          password.contains(RegExp(r'[0-9]')) &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'))) {
        // Password meets the criteria
        User? user = await _auth.signUpWithEmailAndPassword(
            email, password, name, phoneNumber, photoURL);

        if (user != null) {
          print("User is successfully created");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigationBarController()),
              (route) => false);
        } else {
          print("Some error happened");
        }
      } else {
        // Password does not meet the criteria
        _showPasswordRequirements();
      }
    } else {
      _showInvalidEmail();
    }
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoURLController.text = pickedFile.path;
      });
    }
  }

  void _showPasswordRequirements() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
          contentPadding: EdgeInsets.zero,
          content: Container(
            constraints: const BoxConstraints(
                maxWidth: 400), // Adjust the max width as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(143, 148, 251, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Password Requirements',
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      requirementRow(const Color.fromARGB(255, 0, 0, 0),
                          Icons.check, 'Minimum length: 8 characters'),
                      requirementRow(const Color.fromARGB(255, 0, 0, 0),
                          Icons.check, 'Must contain at least one uppercase'),
                      requirementRow(const Color.fromARGB(255, 0, 0, 0),
                          Icons.check, 'Must contain at least one lowercase'),
                      requirementRow(const Color.fromARGB(255, 0, 0, 0),
                          Icons.check, 'Must contain at least one digit'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget requirementRow(Color textColor, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Color.fromRGBO(143, 148, 251, 1))),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  void _showInvalidEmail() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
          contentPadding: EdgeInsets.zero,
          content: Container(
            constraints: const BoxConstraints(
                maxWidth: 400), // Adjust the max width as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [
                        Color.fromRGBO(143, 148, 251, 1),
                        Color.fromRGBO(143, 148, 251, .6),
                      ])),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Invalid email format.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
