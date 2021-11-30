// import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
//import 'package:flutter_projects/screens/home/home.dart';
import 'package:flutter_projects/Shared/constants.dart';
import 'package:flutter_projects/Shared/loading.dart';
import 'package:flutter_projects/screens/admin_dashboard.dart';
import 'package:flutter_projects/services/auth2.dart';
import 'package:toast/toast.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_projects/services/databaseManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

class Create_Job_Callout extends StatefulWidget {
  const Create_Job_Callout({Key key}) : super(key: key);

  @override
  _Create_Job_CalloutState createState() => _Create_Job_CalloutState();
}

class _Create_Job_CalloutState extends State<Create_Job_Callout> {

  DateTime pickedDate;
  TimeOfDay arrivalTime;
  TimeOfDay departureTime;

  final GlobalKey<SfSignaturePadState> _signaturePadStateKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  var uuid = Uuid();

  var selectedUser;
  bool loading = false;

  var userName, custName;

  // Working with Images
  io.File _image;
  io.File _image2;
  String imageUrl;

  String refNum;
  String serviceDate;
  String _customers;
  String _calloutReason;
  String _technician;
  String location = '';
  String arrival_time;
  String notes = '';
  // image before
  String actionPerformed = '';
  // image after
  String _completed;
  String departure_time;
  bool signature = false;
  String customerComment = '';

  // String assignedRole = '';
  // String completed = '';
  //String customers = '';

  TextEditingController locationController = new TextEditingController();
  TextEditingController notesController = new TextEditingController();
  TextEditingController actionPerformedController = new TextEditingController();
  TextEditingController customerCommentController = new TextEditingController();

  final List<String> roles = ['Networking', 'Cabling' , 'Support' , 'Assessment' , 'Internet/connectivity' , 'Email' , 'Printer error/config' , 'Collection' , 'Delivery' , 'Telecoms' , 'Other'];
  final List<String> options = ['Complete', 'Incomplete' , 'Still busy'];
  //final List<String> customers = ['A' , 'B' , 'C'];
  //List technicianList = [];


  // form values

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickedDate = DateTime.now();
    arrivalTime = TimeOfDay.now();
    departureTime = TimeOfDay.now();
  }

  _imgFromCamera() async {
    io.File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    io.File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = image;
    });
  }

  _imgFromCamera2() async {
    io.File image2 = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image2 = image2;
    });
  }

  _imgFromGallery2() async {
    io.File image2 = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image2 = image2;
    });
  }

  sendData() async {
    if(_formKey.currentState.validate()){
      var beforeImage = FirebaseStorage.instance.ref().child(_image.path);
      var afterImage = FirebaseStorage.instance.ref().child(_image2.path);

      var task1 = beforeImage.putFile(_image);
      var task2 = afterImage.putFile(_image2);

      task1.then((res) {
        res.ref.getDownloadURL();
      });

      task2.then((res) {
        res.ref.getDownloadURL();
      });

    }

    // FirebaseStorage storage = FirebaseStorage.instance;
    // Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    // UploadTask uploadTask = ref.putFile(_image1);
    // uploadTask.then((res) {
    //   res.ref.getDownloadURL();
    // });
  }

  // Future getImage() async {
  //   var img = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     image = img;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
        ),
        title: Text("Job Callout",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

                    // TODO : Generate Ref number
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text("Reference Number"),
                          subtitle: Text("YSF-" + uuid.v1()),
                          leading: Icon(Icons.article_sharp),
                        ),
                        decoration: new BoxDecoration(
                          border: new Border(
                            bottom: BorderSide(color: Colors.orange, width: 2.0),
                            top: BorderSide(color: Colors.orange, width: 2.0),
                            right: BorderSide(color: Colors.orange, width: 2.0),
                            left: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Service Date (Date)
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text("Date: ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}"),
                          leading: Icon(Icons.date_range),
                          trailing: Icon(Icons.arrow_drop_down_sharp),
                          onTap: () {
                            setState(() {
                              serviceDate = _pickDate().toString();
                            });
                          },
                          //onTap: _pickDate,
                        ),
                        decoration:
                        new BoxDecoration(
                          border: new Border(
                            bottom: BorderSide(color: Colors.orange, width: 2.0),
                            top: BorderSide(color: Colors.orange, width: 2.0),
                            right: BorderSide(color: Colors.orange, width: 2.0),
                            left: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Customer (Drop Down)
                    SizedBox(
                      width: 500.0,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Customers')
                            .orderBy('Customer name')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          // Safety check to ensure that snapshot contains data
                          // without this safety check, StreamBuilder dirty state warnings will be thrown
                          if (!snapshot.hasData) return Container();
                          // Set this value for default,
                          // setDefault will change if an item was selected
                          // First item from the List will be displayed
                          // if (setDefaultMake) {
                          //   carMake = snapshot.data.docs[0].get('name');
                          //   debugPrint('setDefault make: $carMake');
                          // }
                          return DropdownButtonFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: "Customer",
                                prefixIcon: Icon(Icons.person_add_alt_1_sharp)
                            ),
                            isExpanded: false,
                            value: _customers,
                            items: snapshot.data.docs.map((value) {
                              return DropdownMenuItem(
                                value: value.get('Customer name'),
                                child: Text('${value.get('Customer name')}'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _customers = value.toString() ),
                            onSaved: (value) => _customers = value.toString(),
                            // onChanged: (value) {
                            //   debugPrint('selected onchange: $value');
                            //   setState(
                            //         () {
                            //       debugPrint('Customer selected: $value');
                            //       // Selected value will be stored
                            //       _customers = value.toString();
                            //       // Default dropdown value won't be displayed anymore
                            //       //setDefaultMake = false;
                            //       // Set makeModel to true to display first car from list
                            //       //setDefaultMakeModel = true;
                            //     },
                            //   );
                            // },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Call out Reason (Drop Down)
                    SizedBox(
                      width: 500.0,
                      child: DropdownButtonFormField(
                        value: _calloutReason,
                        decoration: textInputDecoration.copyWith(
                            labelText: "Call out Reason",
                            prefixIcon: Icon(Icons.info)
                        ),
                        items: roles.map((roles) {
                          return DropdownMenuItem(
                            value: roles,
                            child: Text('$roles'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _calloutReason = val.toString() ),
                        onSaved: (val) => _calloutReason = val.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Assign Technician (Drop Down)
                    SizedBox(
                      width: 500.0,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .orderBy('Full name')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          // Safety check to ensure that snapshot contains data
                          // without this safety check, StreamBuilder dirty state warnings will be thrown
                          if (!snapshot.hasData) return Container();
                          // Set this value for default,
                          // setDefault will change if an item was selected
                          // First item from the List will be displayed
                          // if (setDefaultMake) {
                          //   carMake = snapshot.data.docs[0].get('name');
                          //   debugPrint('setDefault make: $carMake');
                          // }
                          return DropdownButtonFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: "Technician",
                                prefixIcon: Icon(Icons.person_add_alt_1_sharp)
                            ),
                            isExpanded: false,
                            value: _technician,
                            items: snapshot.data.docs.map((value) {
                              return DropdownMenuItem(
                                value: value.get('Full name'),
                                child: Text('${value.get('Full name')}'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _technician = value.toString() ),
                            onSaved: (value) => _technician = value.toString(),
                            // onChanged: (value) {
                            //   debugPrint('selected onchange: $value');
                            //   setState(
                            //         () {
                            //       debugPrint('make selected: $value');
                            //       // Selected value will be stored
                            //       userName = value;
                            //       // Default dropdown value won't be displayed anymore
                            //       //setDefaultMake = false;
                            //       // Set makeModel to true to display first car from list
                            //       //setDefaultMakeModel = true;
                            //     },
                            //   );
                            // },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Location
                    SizedBox(
                      width: 500.0,
                      child: TextFormField(
                        controller: locationController,
                        keyboardType: TextInputType.streetAddress,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_pin),
                        ),
                        validator: (String input) {

                          if (input.isEmpty) {
                            return 'Please enter Address';
                          }

                          return null;
                        },
                        onChanged: (input) {
                          setState(() => location = input);
                        },
                        onSaved: (input) => location = input,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Arrival Time
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text("Arrival Time: ${arrivalTime.hour}:${arrivalTime.minute}"),
                          leading: Icon(Icons.access_time_sharp),
                          trailing: Icon(Icons.arrow_drop_down_sharp),
                          onTap: () {
                            setState(() {
                              arrival_time = _pickArrivalTime().toString();
                            });
                          },
                        ),
                        decoration:
                        new BoxDecoration(
                          border: new Border(
                            bottom: BorderSide(color: Colors.orange, width: 2.0),
                            top: BorderSide(color: Colors.orange, width: 2.0),
                            right: BorderSide(color: Colors.orange, width: 2.0),
                            left: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Notes
                    SizedBox(
                      width: 500.0,
                      child: TextFormField(
                        controller: notesController,
                        keyboardType: TextInputType.multiline,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (String input) {
                          if (input.isEmpty) {
                            return 'Please specify work carried out';
                          }
                          return null;
                        },

                        onChanged: (input) {
                          setState(() => notes = input);
                        },
                        onSaved: (input) => notes = input,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Image Before
                    SizedBox(
                      width: 500.0,
                      height: 200.0,
                      child: GestureDetector(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: CircleAvatar(
                          //radius: 55,
                          backgroundColor: Colors.white30,
                          child: _image != null
                              ? ClipRRect(
                            //borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image,
                              width: 500,
                              height: 200,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              //borderRadius: BorderRadius.circular(10)
                            ),
                            width: 500,
                            height: 200,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Action Performed
                    SizedBox(
                      width: 500.0,
                      child: TextFormField(
                        controller: actionPerformedController,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Action Performed',
                          prefixIcon: Icon(Icons.pending_actions_sharp),
                        ),
                        validator: (input) => input.isEmpty ? 'This entry is required' : null,
                        onChanged: (input) {
                          setState(() => actionPerformed = input);
                        },
                        onSaved: (input) => actionPerformed = input,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Image After
                    SizedBox(
                      width: 500.0,
                      height: 200.0,
                      child: GestureDetector(
                        onTap: () {
                          _showPicker2(context);
                        },
                        child: CircleAvatar(
                          //radius: 55,
                          backgroundColor: Colors.white30,
                          child: _image2 != null
                              ? ClipRRect(
                            //borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image2,
                              width: 500,
                              height: 200,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              //borderRadius: BorderRadius.circular(10)
                            ),
                            width: 500,
                            height: 200,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Completed ?
                    SizedBox(
                      width: 500.0,
                      child: DropdownButtonFormField(
                        value: _completed,
                        decoration: textInputDecoration.copyWith(
                            labelText: "Status",
                            prefixIcon: Icon(Icons.announcement_rounded)),
                        items: options.map((options) {
                          return DropdownMenuItem(
                            value: options,
                            child: Text('$options'),
                          );
                        }).toList(),
                        validator: (value) => value == null ? '*Field Required' : null,
                        onChanged: (val) => setState(() => _completed = val.toString() ),
                        onSaved: (val) => _completed = val.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Departure Time
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text("Departure Time: ${departureTime.hour}:${departureTime.minute}"),
                          leading: Icon(Icons.access_time_sharp),
                          trailing: Icon(Icons.arrow_drop_down_sharp),
                          onTap: () {
                            setState(() {
                              departure_time = _pickDepartureTime().toString();
                            });
                          },
                        ),
                        decoration:
                        new BoxDecoration(
                          border: new Border(
                            bottom: BorderSide(color: Colors.orange, width: 2.0),
                            top: BorderSide(color: Colors.orange, width: 2.0),
                            right: BorderSide(color: Colors.orange, width: 2.0),
                            left: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Signature
                    SizedBox(
                      width: 500.0,
                      child: Container(
                          child: Column(children: [
                            Text("Signature",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SfSignaturePad(
                              key: _signaturePadStateKey,
                              backgroundColor: Colors.grey[100],
                              strokeColor: Colors.black,
                              minimumStrokeWidth: 4.0,
                              maximumStrokeWidth: 6.0,
                            ),
                            RaisedButton(
                              onPressed: () async {
                                _signaturePadStateKey.currentState.clear();
                              },
                              child: Text("Clear"),
                              color: Colors.orange,
                              textColor: Colors.white,
                            )
                          ],)
                        // height: 300,
                        // width: 300,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Customer Comment
                    SizedBox(
                      width: 500.0,
                      child: TextFormField(
                        readOnly: true,
                        controller: customerCommentController,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Customer Comment',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        validator: (input) => input.isEmpty ? 'This entry is required' : null,
                        onChanged: (input) {
                          setState(() => customerComment = input);
                        },
                        onSaved: (input) => customerComment = input,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                      width: 105,
                      height: 50,
                      child: new RaisedButton(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.save),
                            Text(" Save", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        color: Colors.orange,
                        textColor: Colors.white,
                        onPressed: () async {

                          if(_formKey.currentState.validate()){

                            setState(() => loading = true);
                            dynamic result;
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                            Toast.show("New customer successfully created", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

                            if(result == null){
                              setState(() {
                                loading = false;
                                Toast.show("Error ! Please try again", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                //error = 'Please supply a valid email';
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 30 ),
    );

    if(date != null){
      setState(() {
        pickedDate = date;
      });
    }

    if(date == null){
      setState(() {
        pickedDate = DateTime.now();
      });
    }

  }

  _pickArrivalTime() async {
    TimeOfDay a_t = await showTimePicker(
      context: context,
      initialTime: arrivalTime,
    );

    if(arrivalTime != null){
      setState(() {
        arrivalTime = a_t;
      });
    }
  }

  _pickDepartureTime() async {
    TimeOfDay d_t = await showTimePicker(
      context: context,
      initialTime: departureTime,
    );

    if(departureTime != null){
      setState(() {
        departureTime = d_t;
      });
    }
  }

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
        }
    );
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
        }
    );
  }

}
