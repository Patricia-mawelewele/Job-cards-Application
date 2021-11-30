import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/Shared/constants.dart';
import 'package:flutter_projects/Shared/loading.dart';
import 'package:flutter_projects/screens/admin_dashboard.dart';
import 'package:flutter_projects/services/auth2.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class create_callout extends StatefulWidget {
  const create_callout({Key key}) : super(key: key);

  @override
  _create_calloutState createState() => _create_calloutState();
}

class _create_calloutState extends State<create_callout> {

  DateTime pickedDate;
  String formatted;

  var result1;
  var result2;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  var uuid = Uuid();
  int num = 1000;
  String name = "YSF";

  var selectedUser;
  bool loading = false;

  //var userName, custName;

  String refNum;
  String serviceDate;
  DateTime date;
  String _customers;
  String other;
  String _calloutReason;
  String _technician;
  String technicianUID;
  String customerUID;
  //String location = '';

  final List<String> roles = ['Networking', 'Cabling' , 'Support' , 'Assessment' , 'Internet/connectivity' , 'Email' , 'Printer error/config' , 'Collection' , 'Delivery' , 'Telecoms' , 'Other'];

  getRefNum(){
    String refNum = uuid.v4();
    return refNum;
  }

  // getCount() {
  //   int length = FirebaseFirestore.instance.collection('Initial Callout').snapshots().length as int;
  //   return length;
  // }
  //
  // Future<int> countDocuments() async {
  //   QuerySnapshot _myDoc = await FirebaseFirestore.instance.collection('Initial Callout').get();
  //   List<DocumentSnapshot> _myDocCount = _myDoc.docs;
  //   print(_myDocCount.length);  // Count of Documents in Collection
  //   num = num + _myDocCount.length;
  //   print(num);
  //   return num;
  // }

  String testRefNum = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickedDate = DateTime.now();
    testRefNum = getRefNum();
    //technicianUID = getTechnicianUID(_technician);
    //countDocuments();
  }

  getTechnicianUID(String technicianName){
    FirebaseFirestore.instance.collection('Users').get().then((snapshot) {
      snapshot.docs.forEach((result) {
        if(result.get('Full name') == technicianName){
          technicianUID = result.get('UID');
          print(technicianUID.toString());
          print(technicianUID);
          return technicianUID.toString();
        }else{
          return null;
        }
      });
    });
  }

  getCustomerUID(String customerName){
    FirebaseFirestore.instance.collection('Customers').get().then((snapshot) {
      snapshot.docs.forEach((result) {
        if(result.get('Customer name') == customerName){
          customerUID = result.get('UID');
          print(customerUID.toString());
          print(customerUID);
          return customerUID.toString();
        }else{
          return null;
        }
      });
    });
  }

  Map<String,dynamic> initialCalloutData;
  CollectionReference initialCallout = FirebaseFirestore.instance.collection('Initial Callout');

  Future createInitialCallout() async {

    try{

      initialCalloutData = {
        'Reference Number': 'YSF-' + testRefNum,
        'Service Date': formatted,
        'Customer': _customers,
        'Callout Reason': _calloutReason,
        'Other': other,
        'Technician': _technician,
        'TechnicianUID': technicianUID,
        'CustomerUID': customerUID,
      };

      return initialCallout.add(initialCalloutData).whenComplete(() => print('Added to Database Successfully'));

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
                          subtitle: Text("YSF-" + testRefNum),
                          leading: Icon(Icons.article_sharp),
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
                              date = _pickDate();
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
                            validator: (value) => value == null ? 'Field required' : null,
                            onChanged: (value) => setState(() {
                              _customers = value.toString();
                              customerUID = getCustomerUID(_customers);
                            }),
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
                        validator: (value) => value == null ? 'Field required' : null,
                        onChanged: (val) => setState(() => _calloutReason = val.toString() ),
                        onSaved: (val) => _calloutReason = val.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    //TODO: Other
                    SizedBox(
                      width: 500.0,
                      child: TextFormField(
                        keyboardType: TextInputType.streetAddress,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Other',
                          hintText: 'If Other please specify, else type N/A',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (String input) {

                          if (input.isEmpty) {
                            return 'Field Required';
                          }

                          return null;
                        },
                        onChanged: (input) {
                          setState(() => other = input);
                        },
                        onSaved: (input) => other = input,
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
                            validator: (value) => value == null ? 'Field required' : null,
                            onChanged: (value) => setState(() {
                              _technician = value.toString();
                              technicianUID = getTechnicianUID(_technician);
                            }),
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

                    // TODO : Save
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

                            setState(() => loading = true,);
                            //technicianUID = getTechnicianUID(_technician);
                            dynamic result = await createInitialCallout();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                            Toast.show("Callout Successfully Created", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

                            if(result == null){
                              setState(() {
                                loading = false;
                                Toast.show("Error ! Please try again", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                //error = 'Please supply a valid email';
                              });
                            }
                            num++;
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
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        formatted = formatter.format(date);
      });
    }

    if(date == null){
      setState(() {
        date = DateTime.now();
        //pickedDate = date;
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        formatted = formatter.format(DateTime.now());
      });
    }

  }

}

