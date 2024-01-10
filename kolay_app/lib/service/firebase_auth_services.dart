import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kolay_app/service/encryption_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService = EncryptionService();

  late UserCredential _credential;

  Future<User?> signUpWithEmailAndPassword(String email, String password,
      String name, String phoneNumber, String photoURL) async {
    try {
      _credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _firestore.collection('USERS').doc(_credential.user!.uid).set({
        'name': _encryptionService.encryptText(name),
        'email': _encryptionService.encryptText(email),
        'phoneNumber': _encryptionService.encryptText(phoneNumber),
        'photoURL': photoURL,
      });

      return _credential.user;
    } catch (e) {
      print("error za: $e");
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
