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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'scraper.dart' as scraper;
import 'contacts.dart' as contacts;
import 'server.dart' as server;

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
  static const String _title = '91.7 WMUH';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: AudioServiceWidget(child: Home()),
    );
  }
}

class AudioServiceWidget extends StatefulWidget {
  final Widget child;

  AudioServiceWidget({@required this.child});

  @override
  _AudioServiceWidgetState createState() => _AudioServiceWidgetState();
}

Stream<List<String>> streamCreator(Duration interval) {
  StreamController<List<String>> controller;
  Timer timer;
  List<String> songData;

  Future<void> callGetSong(_) async {
    songData = await scraper.getSong();
    controller.sink.add(songData);
  }

  void startTimer() {
    timer = Timer.periodic(interval, callGetSong);
  }

  void stopTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
      controller.close();
    }
  }

  controller = StreamController<List<String>>(
      onListen: startTimer,
      onPause: stopTimer,
      onResume: startTimer,
      onCancel: stopTimer);

  return controller.stream;
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Listen")),
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
                StreamBuilder<List<String>>(
                  stream: streamCreator(const Duration(seconds: 5)),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text('${snapshot.error}');
                    if (snapshot.hasData)
                      return Text("Artist: " +
                          snapshot.data[0] +
                          "\n" +
                          "Song: " +
                          snapshot.data[1]);
                    return const CircularProgressIndicator();
                  },
                ),
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
      AudioService.start(
          backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
          androidNotificationChannelName: '91.7 WMUH');
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
  var currentSong;
  var setItem;
  Stream<List<String>> infoStream;
  StreamSubscription<List<String>> subscription;

  @override
  Future<void> onStart() async {
    // Broadcast that we're playing, and what controls are available.
    AudioServiceBackground.setState(
        controls: [pauseControl, stopControl],
        basicState: BasicPlaybackState.playing);

    await _audioPlayer.setUrl("http://192.104.181.26:8000/stream");
    _audioPlayer.play();
    infoStream = streamCreator(const Duration(seconds: 5));
    subscription = infoStream.listen((data) {
      currentSong = MediaItem(
        id: "http://192.104.181.26:8000/stream",
        album: "The Only Station That Matters",
        title: data[1],
        artist: data[0],
//      artUri: "",
      );
      setItem = AudioServiceBackground.setMediaItem(currentSong);
    }, cancelOnError: true);
    await _completer.future;
  }

  @override
  void onStop() {
    // Broadcast that we've stopped.
    AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.stopped);

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
        basicState: BasicPlaybackState.paused);

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

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    server.Home(),
    MainScreen(),
    contacts.RadioScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('91.7 WMUH'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.schedule),
            title: new Text('Schedule'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.radio),
            title: new Text('Listen'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.message),
              title: Text('Contact Us')
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}