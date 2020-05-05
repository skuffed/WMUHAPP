import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: 'Flutter Demo',
//      theme: ThemeData.light(),
//      home: Home(),
//    );
//  }
//}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}


// create the submit song request screen
class HomeState extends State<Home> {
  List<Item> items = List();
  static Item item;
  // database reference for pushing request to database
  static DatabaseReference itemRef;
  // visibility variable for successful submission message
  static var _tsvisibility = false;
  // form key used to connect database to widget containing the text based forms of user input
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  // initial state
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

  // function for handling the song requests and pushing it to the database

  static void handleSubmit() {
    final FormState form = formKey.currentState;
    // variable for message visibility for when a song is successfully submitted
    _tsvisibility = true;
    // check if both text fields are properly filled out before submission of song is successful
    // then save the forms and reset its values to empty the text fields after successful submission
    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text('Submit Songs!'),
//      ),
      resizeToAvoidBottomPadding: false,
      // layout text forms and submit button in vertical column format
      body: Column(
        children: <Widget>[
          Text('\nWant to hear your favorite song on the air?\nEnter your request below!', style: TextStyle(fontSize: 20)),
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                // formkey needed to save each request when handling submission to database
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Text("\n\nSong Title"),
                    ListTile(
                      //leading: Icon(Icons.info),
                      title: TextFormField(
                        // validators used to ensure the value in the text isn't null (empty)
                        initialValue: "",
                        onSaved: (val) => item.title = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    Text("\nArtist"),
                    ListTile(
                      //leading: Icon(Icons.info),
                      title: TextFormField(
                        // validators used to ensure the value in the text isn't null (empty)
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
                    // visible text that relies on variable to determine visibility
                    // at initial state of app, message is invisible, upon successful
                    // song submission, message becomes visible in order
                    // to let the user know their request came through
                    Visibility(
                      visible: _tsvisibility,
                      child: Text("Song successfully submitted!"),
                    )
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

// item class for capturing snapshots of data
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