import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference Users =
      FirebaseFirestore.instance.collection('Users');

  final CollectionReference AllUsers =
      FirebaseFirestore.instance.collection('All Users');

  final CollectionReference Customers =
      FirebaseFirestore.instance.collection('Customers');

  final CollectionReference Technician =
      FirebaseFirestore.instance.collection('Updated Callouts');

  Future updateUserData(String userID, String email, String fullName,
      String phoneNo, String role) async {
    return await Users.doc(uid).set({
      'UID': uid,
      'Email': email,
      'Full name': fullName,
      'Phone number': phoneNo,
      'Role': role,
    });
  }

  Future updateAllUserData(String userID, String fullName, String role) async {
    return await AllUsers.doc(uid).set({
      'UID': uid,
      'Full name': fullName,
      'Role': role,
    });
  }

  Future updateCustomerData(String userID, String email, String customerName,
      String description, String phoneNo, String address) async {
    return await Customers.doc(uid).set({
      'UID': uid,
      'Email': email,
      'Customer name': customerName,
      'Description': description,
      'Phone number': phoneNo,
      'Address': address,
    });
  }

  Future getUsersList() async {
    List itemsList = [];

    try {
      await Technician.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          itemsList.add(element.data);
          //print(element.data().toString());
        });
      });

      return itemsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  getTechnicianName() async {
    Map data;

    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('Initial Callout');
    collectionReference.snapshots().listen((snapshot) {
      data = snapshot.docs[4].data();
    });
    return data;
  }
}
