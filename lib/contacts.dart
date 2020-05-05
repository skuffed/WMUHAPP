import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


// MyApp class for building the material app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Contacts',
      home: new RadioScreen(),
    );
  }
}

// radioscreen is the main class for the file that contains the main widget containing all the contents
// of the screen. The widget contains three icon buttons that utilize the url launcher import
// to open three web links to the radio station's Facebook, Twitter, and Instagram pages. The icon buttons
// utilize custom icons from the social_media_icons.dart file and each have a unique keycode outlined in
// the icon data. Below the three icon buttons are flat buttons with the phone and email links of the radio
// station, also utilizing the url launcher import, but with extra code differentiating the phone and
// email links from web links, specifically the mailto: and tel: codes. All five of the buttons are organized
// in the code specified at the beginning of the widget, specifically in a column, with a minimum main axis size
// and a center cross center axis, for a streamlined layout for the user that maximizes convenience.

class RadioScreen extends StatelessWidget {
  RadioScreen({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) => new Scaffold(

//    appBar: new AppBar(
//      title: new Text("Contact Us!"),
//    ),
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
//    bottomNavigationBar: BottomAppBar(
//      color: Colors.green,
//      child: new Text(" "),
//    ),

);

}

// main function for running the app
void main() {
  runApp(
    new MyApp(),
  );
}