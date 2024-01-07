import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late UserCredential _credential;

  Future<User?> signUpWithEmailAndPassword(String email, String password,
      String name, String phoneNumber, String photoURL) async {
    try {
      _credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _credential.user!.updateDisplayName(name);
      await _credential.user!.updatePhotoURL(photoURL);

      _firestore.collection('USERS').doc(_credential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoURL': photoURL,
      });

      return _credential.user;
    } catch (e) {
      print("Some error occured");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occured");
    }
    return null;
  }
}
