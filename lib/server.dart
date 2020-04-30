import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// Home Class
class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

// This class is for the screen that allows for submission of songs.
// It includes variables for database references, and the item class below, as well as the widget for laying
// out the format of the screen.
class HomeState extends State<Home> {
  // essential variables for interaction with the database, the database reference itemref refers
  // to every item that is submitted by the user (song title and artist), that is then sent to the database.
  // The tsvisibility variable is used for displaying a message to the user when a song is successfully submitted
  // The text for the message starts off as false, or invisible, and becomes visible (true) when a song is submitted
  // to the database.
  List<Item> items = List();
  static Item item;
  static DatabaseReference itemRef;
  static var _tsvisibility = false;
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "");
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.
    itemRef = database.reference().child('items');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);

  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  // function for handling submission of requests to the database.
  // when a submission is accepted, the message Song successfully submitted becomes visible,
  // indicated by the tsvisibility variable.
  static void handleSubmit() {
    final FormState form = formKey.currentState;
    _tsvisibility = true;
    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());

    }
  }

  // Widget of layout of the screen
  // List tiles are included for the user to type their song title and artist wanted. Both list tiles
  // include a Textformfield used for entering requests that includes code for validating them, making sure
  // the fields are not empty for they are submitted to the database. If the fields are empty, the forms
  // turn red, indicating to the user that the forms are insufficiently filled out.
  // Below the listtiles is the icon button for submission, which calls the handle submit function
  // to handle submission of requests when the button is clicked.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text('Submit Songs!'),
//      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Text('\nWant to hear your favorite song on the air?\nEnter your request below!', style: TextStyle(fontSize: 20)),
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Text("\n\nSong Title"),
                    ListTile(
                      //leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.title = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    Text("\nArtist"),
                    ListTile(
                      //leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => item.body = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        handleSubmit();
                      },
                    ),
                    Visibility(
                      visible: _tsvisibility,
                      child: Text("Song successfully submitted!")
                    ),
                    Text(
                        '\nIf form turns red after pressing submit button, one or more fields were not properly filled out.\nIf form empties after pressing the submit button, and message of successful submission displays, \nyour song has been successfully submitted.', style: TextStyle(fontSize: 16)
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// item class for the requests to the database
// variables for handling request keys, title (for the song title), and body (for the song artist)
class Item {
  String key;
  String title;
  String body;

  Item(this.title, this.body);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"],
        body = snapshot.value["body"];

  toJson() {
    return {
      "title": title,
      "body": body,
    };
  }
}