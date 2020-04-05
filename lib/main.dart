// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

void main() => runApp(MyApp());

final playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
final pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
final stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: AudioServiceWidget(child: MainScreen()),
    );
  }
}

//class MyStatefulWidget extends StatefulWidget {
//  MyStatefulWidget({Key key}) : super(key: key);
//
//  @override
//  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
//}

class AudioServiceWidget extends StatefulWidget {
  final Widget child;

  AudioServiceWidget({@required this.child});

  @override
  _AudioServiceWidgetState createState() => _AudioServiceWidgetState();
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tune In!")),
      body: Center(
        child: StreamBuilder<PlaybackState>(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            final state =
                snapshot.data?.basicState ?? BasicPlaybackState.stopped;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state == BasicPlaybackState.playing)
                  RaisedButton(child: Text("Pause"), onPressed: pause)
                else
                  RaisedButton(child: Text("Play"), onPressed: play),
                if (state != BasicPlaybackState.stopped)
                  RaisedButton(child: Text("Stop"), onPressed: stop),
              ],
            );
          },
        ),
      ),
    );
  }

  play() async {
    if (await AudioService.running) {
      AudioService.play();
    } else {
      AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
    }
  }

  pause() => AudioService.pause();

  stop() => AudioService.stop();
}

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _completer = Completer();

  @override
  Future<void> onStart() async {
    // Broadcast that we're playing, and what controls are available.
    AudioServiceBackground.setState(
        controls: [pauseControl, stopControl],
        basicState: BasicPlaybackState.playing);

    await _audioPlayer.setUrl("http://192.104.181.26:8000/stream");
    _audioPlayer.play();
    await _completer.future;
    // Broadcast that we've stopped.
    AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.playing);
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _completer.complete();
  }

  @override
  void onPlay() {
    // Broadcast that we're playing, and what controls are available.
    AudioServiceBackground.setState(
        controls: [pauseControl, stopControl],
        basicState: BasicPlaybackState.playing);

    _audioPlayer.play();
  }

  @override
  void onPause() {
    // Broadcast that we're paused, and what controls are available.
    AudioServiceBackground.setState(
        controls: [playControl, stopControl],
        basicState: BasicPlaybackState.playing);

    _audioPlayer.pause();
  }
}

class _AudioServiceWidgetState extends State<AudioServiceWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService.connect();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AudioService.connect();
        break;
      case AppLifecycleState.paused:
        AudioService.disconnect();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AudioService.disconnect();
        return true;
      },
      child: widget.child,
    );
  }
}

//class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//  int _selectedIndex = 0;
//  static const TextStyle optionStyle =
//  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//
//  static List<Widget> _widgetOptions = <Widget>[
//    MainScreen(),
//    Text(
//      'Index 1: Schedule',
//      style: optionStyle,
//    ),
//    Text(
//      'Index 2: Contact',
//      style: optionStyle,
//    ),
//  ];
//
//  void _onItemTapped(int index) {
//    setState(() {
//      _selectedIndex = index;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text('91.7 WMUH'),
//      ),
//      body: Center(
//        child: _widgetOptions.elementAt(_selectedIndex),
//      ),
//      bottomNavigationBar: BottomNavigationBar(
//        items: const <BottomNavigationBarItem>[
//          BottomNavigationBarItem(
//            icon: Icon(Icons.radio),
//            title: Text('Stream'),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.schedule),
//            title: Text('Schedule'),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.message),
//            title: Text('Contact'),
//          ),
//        ],
//        currentIndex: _selectedIndex,
//        selectedItemColor: Colors.amber[800],
//        onTap: _onItemTapped,
//      ),
//    );
//  }
//}