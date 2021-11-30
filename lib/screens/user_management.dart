import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/screens/admin_dashboard.dart';
import 'package:flutter_projects/screens/customer_new_dashboard.dart';
import 'package:flutter_projects/screens/login.dart';
import 'package:flutter_projects/screens/technician_dashboard.dart';
import 'package:toast/toast.dart';

import 'admin_dashboard.dart';
import 'admin_dashboard.dart';
import 'admin_dashboard.dart';

class UserManagement{
  Widget handleAuth(){
    return new StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if(snapshot.hasData){
          return HomeScreen();
        }
        return LoginPage();
      },
    );
  }

  authorizeAccess(BuildContext context) {
    var userID = FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance
        .collection('All Users')
        .where('UID', isEqualTo: userID)
        .get()
        .then((docs) {
      if(docs.docs[0].exists){

        if(docs.docs[0].data()['Role'] == 'Technician' || docs.docs[0].data()['Role'] == 'Driver'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => technician_Dashboard()));
          Toast.show("Login Successful", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
        else if(docs.docs[0].data()['Role'] == 'Customer'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => customer_new_dashboard()));
          Toast.show("Login Successful", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else{
        Toast.show("Not Authorized", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
    });
  }
}