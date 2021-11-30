import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_projects/services/DatabaseManager.dart';
//import 'package:flutter_projects/models/user.dart';
import 'package:flutter_projects/services/databaseManager.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Create user object based on FirebaseUser
  // User _userFromFirebaseUser(User user){
  //   if (user != null) {
  //     return User(uid: user.uid);
  //   } else {
  //     return null;
  //   }
  // }
  //
  // // Auth change user stream
  // Stream<User> get user {
  //   return _auth.authStateChanges().
  //   map((User) => _userFromFirebaseUser(User));
  // }

  // Sign in anon
  Future signInAnon() async {
    try{
      User user = (await _auth.signInAnonymously()).user;
      return user.uid;
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
      return user.uid;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Registers Technician with email and password & Creates new User
  Future registerUserWithEmailAndPassword(String userID, String email, String password, String fullName, String phoneNo, String role) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      await DatabaseService(uid: user.uid).updateUserData(userID, email, fullName, phoneNo, role);
      await DatabaseService(uid: user.uid).updateAllUserData(userID, fullName, role);
      return user.uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerCustomerWithEmailAndPassword(String userID, String email, String password, String customerName, String description, String phoneNo, String address, String role) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      await DatabaseService(uid: user.uid).updateCustomerData(userID, email, customerName, description, phoneNo, address);
      await DatabaseService(uid: user.uid).updateAllUserData(userID, customerName, role);
      return user.uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


}