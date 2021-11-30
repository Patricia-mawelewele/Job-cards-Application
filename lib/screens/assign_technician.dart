//import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/screens/create_callout.dart';
import 'package:flutter_projects/screens/create_job_callout.dart';
import 'package:flutter_projects/services/databaseManager.dart';

// ignore: camel_case_types
class getData extends StatefulWidget {
  const getData();

  @override
  _getData createState() => _getData();
}

// ignore: camel_case_types
class _getData extends State<getData> {
// initialize var
  List technicianList = [];

//
  @override
  void initState() {
    super.initState();
    //fetchUserInfo();
    //fetchDatabaseList();
  }

//
  String userID = "";

  fetchUserInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

//
  fetchDatabaseList() async {
    dynamic resultant = await DatabaseService().getUsersList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        technicianList = resultant;
      });
    }
  }

  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('Updated Callouts').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Assign Nearby Technician"),
          backgroundColor: Colors.orange,
          centerTitle: true,
          actions: [
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => create_callout()));
              },
              child: Text("Assign"),
              textColor: Colors.orange,
              color: Colors.white,
            ),
          ]
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 20.0,
          ),
          child: SizedBox(
            width: 500,
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    color: Colors.orange,
                  );
                }

                return ListView(
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: ListTile(
                          leading: Text(
                            data['Service Date'],
                            textAlign: TextAlign.left,
                          ),
                          title: Text(
                            data['Technician'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Last updated location: ' + data['Technician Location'],
                          ),
                          trailing: Text(
                            data['Status'],
                            textAlign: TextAlign.right,
                          ),
                        ),
                        decoration: new BoxDecoration(
                          border: new Border(
                            bottom:
                            BorderSide(color: Colors.orange, width: 2.0),
                            top: BorderSide(color: Colors.orange, width: 2.0),
                            right: BorderSide(color: Colors.orange, width: 2.0),
                            left: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
