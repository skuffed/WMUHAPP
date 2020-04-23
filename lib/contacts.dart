import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Contacts',
      home: new RadioScreen(),
    );
  }
}



class RadioScreen extends StatelessWidget {
  RadioScreen({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) => new Scaffold(

    appBar: new AppBar(
      title: new Text("Contact Us!"),
    ),
    body: new Center(
      child: new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget> [


          new Text("Find us on", style: TextStyle(fontSize: 20)),
          new IconButton(
            onPressed: () => launch("https://www.facebook.com/pages/WMUH/105617379471492"),
            icon: new Icon(const IconData(0xe800, fontFamily: 'SocialMedia')),
            color: Colors.blue,
          ),
          new IconButton(
            onPressed: () => launch("https://twitter.com/wmuhfm?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor"),
            icon: new Icon(const IconData(0xe801, fontFamily: 'SocialMedia')),
            color: Colors.cyanAccent,
          ),
          new IconButton(
              onPressed: () => launch("https://www.instagram.com/wmuhfm/?hl=en"),
            icon: new Icon(const IconData(0xf32d, fontFamily: 'SocialMedia')),
            color: Colors.purpleAccent,
          ),

          new FlatButton(
            onPressed: () => launch("mailto:WMUHmusic@muhlenberg.edu"),
            child: new Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [

                Icon(Icons.email),
                Text("WMUHmusic@muhlenberg.edu", style: TextStyle(fontSize: 14)),
            ],
            ),
          ),
          new FlatButton(
            onPressed: () => launch("tel://4846643456"),
            child: new Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Icon(Icons.phone),
                Text("484-664-3456", style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ] ,
      ),
    ),
    bottomNavigationBar: BottomAppBar(
      color: Colors.green,
      child: new Text(" "),
    ),

);

}

void main() {
  runApp(
    new MyApp(),
  );
}