import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chat/shared/colorful_prints.dart';

class AuthService {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth
        .currentUser; // .currentUser is a method from firebase_auth (hover over it)
  }

  Future<UserCredential> userLogin(String email, String password) async {
    try {
      printInfo('Attempting login with email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      printSuccess('Login successful for user: ${userCredential.user?.email}');

      // save user info if it doesn't already exist
      _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email});

      return userCredential;
    } on FirebaseAuthException catch (error) {
      printError('Login failed. Error code: ${error.code}');
      throw Exception(error.code);
    }
  }

  Future<UserCredential> userRegister(String email, String password) async {
    try {
      printInfo('Attempting registration with email: $email');

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      printSuccess(
          'Registration successful for user: ${userCredential.user?.email}');

      // save user info in a serperate document
      _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email});

      return userCredential;
    } on FirebaseAuthException catch (error) {
      printError('Registration failed. Error code: ${error.code}');
      throw Exception(error.code);
    }
  }

  Future<void> userLogout() async {
    printInfo('Logging out user: ${_auth.currentUser?.email}');
    await _auth.signOut();
    printSuccess('Logout successful');
  }

  // Update user presence when the app is opened
  Future<void> updateUserPresence() async {
    if (_auth.currentUser != null) {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
        'online': true,
      });
    }
  }

  // Update user presence when the app is closed
  Future<void> updateUserOffline() async {
    if (_auth.currentUser != null) {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
        'online': false,
      });
    }
  }

  // Stream for real-time user presence updates
  Stream<DocumentSnapshot> getUserPresenceStream() {
    return _firestore
        .collection("Users")
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }
}
