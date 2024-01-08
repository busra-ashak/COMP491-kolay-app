import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late UserCredential _credential; // Private variable

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      _credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('USERS').doc(_credential.user!.uid).set({
      });
      
      return _credential.user;
    } catch (e) {
      print("Some error occured");
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occured");
    }
    return null;

  }




}