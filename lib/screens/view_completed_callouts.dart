import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/Shared/constants.dart';
import 'package:flutter_projects/Shared/loading.dart';
import 'package:flutter_projects/screens/customer_new_dashboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'admin_dashboard.dart';

class view_completed_callouts extends StatefulWidget {
  const view_completed_callouts({Key key}) : super(key: key);

  @override
  _view_completed_calloutsState createState() => _view_completed_calloutsState();
}

class _view_completed_calloutsState extends State<view_completed_callouts> {

  String userID;
  String name;

  fetchUserInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  @override
  void initState() {
    fetchUserInfo();
    //fetchTechnicianName();
    //getTechnicianName();
    super.initState();
    //fetchDatabaseList();
  }


  navigateToRatedPage(Map<String, dynamic> details) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => rated_page(
              details: details,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('Rated Callouts')
        .orderBy('Service Date')
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
        Text("Completed Callouts", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
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
                            data['Customer'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Reason: ' + data['Callout Reason'],
                          ),
                          trailing: Text(
                            data['Technician'],
                            textAlign: TextAlign.right,
                          ),
                          onTap: () => navigateToRatedPage(data),
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

class rated_page extends StatefulWidget {
  final Map<String, dynamic> details;

  rated_page({this.details});

  @override
  _rated_pageState createState() => _rated_pageState();
}

// ignore: camel_case_types
class _rated_pageState extends State<rated_page> {

  final GlobalKey<SfSignaturePadState> _signaturePadStateKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

  final List<String> options = ['Complete', 'Incomplete', 'Still busy'];

  TimeOfDay arrivalTime;
  TimeOfDay departureTime;

  File _image1;
  File _image2;

  String arrival_time;
  String notes;
  String location;

  String imgUrl1; // image before
  String actionPerformed = '';
  String imgUrl2; // image after
  String _completed;
  String departure_time;
  bool signature = false;
  String customerComment = '';
  String customerRating;

  double customer_rating = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    arrivalTime = TimeOfDay.now();
    departureTime = TimeOfDay.now();
  }

  Map<String,dynamic> ratedCalloutData;
  CollectionReference ratedCallout = FirebaseFirestore.instance.collection('Rated Callouts');

  Future customerUpdateCallout() async {

    // var storageImage1 = FirebaseStorage.instance.ref().child(_image1.path);
    // var storageImage2 = FirebaseStorage.instance.ref().child(_image2.path);
    //
    // var task = storageImage1.putFile(_image1);
    // var task2 = storageImage2.putFile(_image2);
    //
    // imgUrl1 = await (await task).ref.getDownloadURL();
    // imgUrl2 = await (await task2).ref.getDownloadURL();

    try{

      ratedCalloutData = {
        'Reference Number': widget.details['Reference Number'],
        'Service Date': widget.details['Service Date'],
        'Customer': widget.details['Customer'],
        'Callout Reason': widget.details['Callout Reason'],
        'Technician': widget.details['Technician'],
        'Technician Location': widget.details['Technician Location'],
        'Arrival Time': widget.details['Arrival Time'],
        'Notes': widget.details['Notes'],
        'Image Before': widget.details['Image Before'],
        'Action Performed': widget.details['Action Performed'],
        'Image After': widget.details['Image After'],
        'Status': widget.details['Status'],
        'Departure Time': widget.details['Departure Time'],
        'Signature': widget.details['Signature'],
        'Customer Comment': customerComment,
        'Customer Rating': customerRating,
      };

      return ratedCallout.add(ratedCalloutData).whenComplete(() => print('Added to Database Successfully'));

    } catch(e){
      print(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          //onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
        ),
        title:
        Text("Completed Callouts", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              child: Form(
                // TODO : implement key
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Reference Number: ' + widget.details['Reference Number'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Service Date: ' + widget.details['Service Date'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Customer: ' + widget.details['Customer'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Callout Reason: ' + widget.details['Callout Reason'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Technician: ' + widget.details['Technician'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // // TODO: Technicians Location
                    // SizedBox(
                    //   width: 500.0,
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.streetAddress,
                    //     decoration: textInputDecoration.copyWith(
                    //       labelText: 'Technicians Location',
                    //       prefixIcon: Icon(Icons.location_pin),
                    //     ),
                    //     validator: (String input) {
                    //
                    //       if (input.isEmpty) {
                    //         return 'Please enter Address';
                    //       }
                    //
                    //       return null;
                    //     },
                    //     onChanged: (input) {
                    //       setState(() => location = input);
                    //     },
                    //     onSaved: (input) => location = input,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Arrival Time
                    // SizedBox(
                    //   width: 500.0,
                    //   child: Container(
                    //     child: ListTile(
                    //       title: Text(
                    //           "Arrival Time: ${arrivalTime.hour}:${arrivalTime.minute}"),
                    //       leading: Icon(Icons.access_time_sharp),
                    //       trailing: Icon(Icons.arrow_drop_down_sharp),
                    //       onTap: () {
                    //         setState(() {
                    //           arrival_time = _pickArrivalTime().toString();
                    //         });
                    //       },
                    //     ),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.orange, width: 2.0),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Arrival Time
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Arrival Time : ' + widget.details['Arrival Time'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Notes
                    // SizedBox(
                    //   width: 500.0,
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.multiline,
                    //     decoration: textInputDecoration.copyWith(
                    //       labelText: 'Notes',
                    //       prefixIcon: Icon(Icons.description),
                    //     ),
                    //     validator: (String input) {
                    //       if (input.isEmpty) {
                    //         return 'Please specify work carried out';
                    //       }
                    //       return null;
                    //     },
                    //     onChanged: (input) {
                    //       setState(() => notes = input);
                    //     },
                    //     onSaved: (input) => notes = input,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Notes
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Notes: ' + widget.details['Notes'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Image Before
                    // SizedBox(
                    //   width: 500.0,
                    //   height: 200.0,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       _showPicker(context);
                    //     },
                    //     child: CircleAvatar(
                    //       //radius: 55,
                    //       backgroundColor: Colors.white30,
                    //       child: _image1 != null
                    //           ? ClipRRect(
                    //         //borderRadius: BorderRadius.circular(10),
                    //         child: Image.file(
                    //           _image1,
                    //           width: 500,
                    //           height: 200,
                    //           fit: BoxFit.fitHeight,
                    //         ),
                    //       )
                    //           : Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.grey[200],
                    //           //borderRadius: BorderRadius.circular(10)
                    //         ),
                    //         width: 500,
                    //         height: 200,
                    //         child: Icon(
                    //           Icons.camera_alt,
                    //           color: Colors.grey[800],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Action Performed
                    // SizedBox(
                    //   width: 500.0,
                    //   child: TextFormField(
                    //     decoration: textInputDecoration.copyWith(
                    //       labelText: 'Action Performed',
                    //       prefixIcon: Icon(Icons.pending_actions_sharp),
                    //     ),
                    //     validator: (input) =>
                    //     input.isEmpty ? 'This entry is required' : null,
                    //     onChanged: (input) {
                    //       setState(() => actionPerformed = input);
                    //     },
                    //     onSaved: (input) => actionPerformed = input,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Action Performed
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Action(s) Performed: ' + widget.details['Action Performed'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Image After
                    // SizedBox(
                    //   width: 500.0,
                    //   height: 200.0,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       _showPicker2(context);
                    //     },
                    //     child: CircleAvatar(
                    //       //radius: 55,
                    //       backgroundColor: Colors.white30,
                    //       child: _image2 != null
                    //           ? ClipRRect(
                    //         //borderRadius: BorderRadius.circular(10),
                    //         child: Image.file(
                    //           _image2,
                    //           width: 500,
                    //           height: 200,
                    //           fit: BoxFit.fitHeight,
                    //         ),
                    //       )
                    //           : Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.grey[200],
                    //           //borderRadius: BorderRadius.circular(10)
                    //         ),
                    //         width: 500,
                    //         height: 200,
                    //         child: Icon(
                    //           Icons.camera_alt,
                    //           color: Colors.grey[800],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Completed ?
                    // SizedBox(
                    //   width: 500.0,
                    //   child: DropdownButtonFormField(
                    //     value: _completed,
                    //     decoration: textInputDecoration.copyWith(
                    //         labelText: "Status",
                    //         prefixIcon: Icon(Icons.announcement_rounded)),
                    //     items: options.map((options) {
                    //       return DropdownMenuItem(
                    //         value: options,
                    //         child: Text('$options'),
                    //       );
                    //     }).toList(),
                    //     onChanged: (val) =>
                    //         setState(() => _completed = val.toString()),
                    //     onSaved: (val) => _completed = val.toString(),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Completed ?
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Status: ' + widget.details['Status'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Departure Time
                    // SizedBox(
                    //   width: 500.0,
                    //   child: Container(
                    //     child: ListTile(
                    //       title: Text(
                    //           "Departure Time: ${departureTime.hour}:${departureTime.minute}"),
                    //       leading: Icon(Icons.access_time_sharp),
                    //       trailing: Icon(Icons.arrow_drop_down_sharp),
                    //       onTap: () {
                    //         setState(() {
                    //           departure_time = _pickDepartureTime().toString();
                    //         });
                    //       },
                    //     ),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.orange, width: 2.0),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Departure Time
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Departure Time: ' + widget.details['Departure Time'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // // TODO : Signature
                    // SizedBox(
                    //   width: 500.0,
                    //   child: Container(
                    //       child: Column(
                    //         children: [
                    //           Text(
                    //             "Signature",
                    //             style: TextStyle(
                    //               fontSize: 15.0,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //             textAlign: TextAlign.left,
                    //           ),
                    //           SfSignaturePad(
                    //             key: _signaturePadStateKey,
                    //             backgroundColor: Colors.grey[100],
                    //             strokeColor: Colors.black,
                    //             minimumStrokeWidth: 4.0,
                    //             maximumStrokeWidth: 6.0,
                    //           ),
                    //           RaisedButton(
                    //             onPressed: () async {
                    //               _signaturePadStateKey.currentState.clear();
                    //             },
                    //             child: Text("Clear"),
                    //             color: Colors.orange,
                    //             textColor: Colors.white,
                    //           )
                    //         ],
                    //       )
                    //     // height: 300,
                    //     // width: 300,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    // TODO : Signature
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Signed: ' + widget.details['Signature'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Customer Comment
                    // SizedBox(
                    //   width: 500.0,
                    //   child: TextFormField(
                    //     decoration: textInputDecoration.copyWith(
                    //       labelText: 'Customer Comment',
                    //       prefixIcon: Icon(Icons.notes),
                    //     ),
                    //     validator: (input) =>
                    //     input.isEmpty ? 'This entry is required' : null,
                    //     onChanged: (input) {
                    //       setState(() => customerComment = input);
                    //     },
                    //     onSaved: (input) => customerComment = input,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Customer Comment: ' + widget.details['Customer Comment'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // SizedBox(
                    //   width: 500.0,
                    //   child: Container(
                    //     child: Column(
                    //       children: [
                    //         Text(
                    //           'Rating: $customer_rating',
                    //           style: TextStyle(fontSize: 40),
                    //         ),
                    //         RatingBar.builder(
                    //           //minRating: 0,
                    //             initialRating: 0,
                    //             maxRating: 5,
                    //             itemCount: 5,
                    //             itemBuilder: (context, index) => Icon(Icons.star, color: Colors.orange,),
                    //             updateOnDrag: true,
                    //             onRatingUpdate: (rating){
                    //               this.customer_rating = rating;
                    //               setState(() {
                    //                 customerRating = rating.toString();
                    //               });
                    //             }
                    //         ),
                    //       ],
                    //     ),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.orange, width: 2.0),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20.0,
                    // ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Customer Rating: ' + widget.details['Customer Rating'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // SizedBox(
                    //   width: 105,
                    //   height: 50,
                    //   child: new RaisedButton(
                    //     child: Row(
                    //       children: <Widget>[
                    //         Icon(Icons.save),
                    //         Text(" Save",
                    //             style: TextStyle(fontWeight: FontWeight.bold)),
                    //       ],
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.all(
                    //         Radius.circular(16),
                    //       ),
                    //     ),
                    //     color: Colors.orange,
                    //     textColor: Colors.white,
                    //     onPressed: () async {
                    //       if (_formKey.currentState.validate()) {
                    //         setState(() => loading = true);
                    //         dynamic result = await customerUpdateCallout();
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => customer_new_dashboard()));
                    //         Toast.show(
                    //             "Callout Successfully Completed", context,
                    //             duration: Toast.LENGTH_LONG,
                    //             gravity: Toast.BOTTOM);
                    //
                    //         if (result == null) {
                    //           setState(() {
                    //             loading = false;
                    //             Toast.show("Error ! Please try again", context,
                    //                 duration: Toast.LENGTH_LONG,
                    //                 gravity: Toast.BOTTOM);
                    //             //error = 'Please supply a valid email';
                    //           });
                    //         }
                    //       }
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  _pickArrivalTime() async {
    TimeOfDay a_t = await showTimePicker(
      context: context,
      initialTime: arrivalTime,
    );

    if (arrivalTime != null) {
      setState(() {
        arrivalTime = a_t;
        arrival_time = a_t.format(context);
      });
    }
  }

  _pickDepartureTime() async {
    TimeOfDay d_t = await showTimePicker(
      context: context,
      initialTime: departureTime,
    );

    if (departureTime != null) {
      setState(() {
        departureTime = d_t;
        departure_time = d_t.format(context);
      });
    }
  }

  _imgFromCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image1 = image;
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image1 = image;
    });
  }

  _imgFromCamera2() async {
    var image2 = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image2 = image2;
    });
  }

  _imgFromGallery2() async {
    var image2 = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image2 = image2;
    });
  }

  // chooseImage() async {
  //   final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     File(pickedFile.path);
  //   });
  //   if(pickedFile.path == null) retrieveLostData();
  // }
  //
  // Future<void> retrieveLostData() async {
  //   final LostDataResponse response = await ImagePicker.retrieveLostData();
  //
  //   if(response.isEmpty){
  //     return;
  //   }
  //   if(response.file != null){
  //     setState(() {
  //       File(response.file.path);
  //     });
  //   }
  //   else{
  //     print(response.file);
  //   }
  // }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showPicker2(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery2();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera2();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }


}
