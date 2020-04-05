// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}


class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static String url = 'http://192.104.181.26:8000/stream';
  static final _player = AudioPlayer();
  var duration = _player.setUrl(url);
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Item> items = List();
  static Item item;
  static DatabaseReference itemRef;

  static void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {

      form.save();
      form.reset();
      itemRef.push().set(item.toJson());

    }
  }


  static List<Widget> _widgetOptions = <Widget>[
    StreamBuilder<FullAudioPlaybackState>(
      stream: _player.fullPlaybackStateStream,
      builder: (context, snapshot) {
        final fullState = snapshot.data;
        final state = fullState?.state;
        final buffering = fullState?.buffering;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state == AudioPlaybackState.connecting ||
                buffering == true)
              Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(),
              )
            else if (state == AudioPlaybackState.playing)
              IconButton(
                icon: Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: _player.pause,
              )
            else
              IconButton(
                icon: Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: _player.play,
              ),
            IconButton(
              icon: Icon(Icons.stop),
              iconSize: 64.0,
              onPressed: state == AudioPlaybackState.stopped ||
                  state == AudioPlaybackState.none
                  ? null
                  : _player.stop,
            ),
          ],
        );
      },
    ),
    Text(
      'Index 1: Schedule',
      style: optionStyle,
    ),
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget> [
        new Text("Contact Us!", style: TextStyle(fontSize: 40)),
        new RaisedButton(
        onPressed: () => launch("tel://4846643239"),
        child: new Text("Call the Radio Station", style: TextStyle(fontSize: 25)),
        color: Colors.green,
        ),
        new RaisedButton(
        onPressed: () => launch("https://www.facebook.com/pages/WMUH/105617379471492"),
        child: new Text("Visit our Facebook Page", style: TextStyle(fontSize: 25)),
        color: Colors.blue,
        ),
        new RaisedButton(
        onPressed: () => launch("https://twitter.com/wmuhfm"),
        child: new Text("Visit our Twitter Page", style: TextStyle(fontSize: 25)),
        color: Colors.cyanAccent,
        ),
        new RaisedButton(
        onPressed: () => launch("https://www.instagram.com/wmuhfm/?hl=en"),
        child: new Text("Visit our Instagram Page", style: TextStyle(fontSize: 25)),
        color: Colors.purpleAccent,
        ),
        new Image(
          image: AssetImage('images/WMUH70thAnniversary-46.jpg')
        ),
      ],
    ),
    Column(
      children: <Widget>[

        Text('Want the Radio Station to play your requests? Enter Song Title and Artist in forms below!', style: TextStyle(fontSize: 20, color: Colors.blue)),
        Flexible(
          flex: 0,
          child: Center(
            child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.info),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val) => item.title = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
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

                  Text(
                          'If form turns red after pressing submit button, one or more fields were not properly filled out. If form empties after pressing the submit button, your song has been successfully submitted.', style: TextStyle(fontSize: 16)
                      ),

                ],
              ),
            ),
          ),
        ),

      ],
    ),
  ];

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





  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('91.7 WMUH'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            title: Text('Stream'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            title: Text('Schedule'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Contact'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Submit'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );


  }
}

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