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
  ];

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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );


  }
}