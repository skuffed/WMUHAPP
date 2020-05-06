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
import 'webview.dart' as webview;

void main() => runApp(MyApp());

//Get the icons for the Android notification player buttons.
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
  static const String _title = 'WMUH Radio';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      //Put AudioServiceWidget at top of widget tree to maintain connection
      //across every route in app.
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

//Create a stream that calls the getSong() function from scraper.dart every 5
//seconds.
Stream<List<String>> streamCreator(Duration interval) {
  StreamController<List<String>> controller;
  Timer timer;
  List<String> songData;

  //Call the getSong() function and add the data to the sink of the controller.
  Future<void> callGetSong(_) async {
    songData = await scraper.getSong();
    controller.sink.add(songData);
  }

  //Perform callGetSong over the interval specified.
  void startTimer() {
    timer = Timer.periodic(interval, callGetSong);
  }

  //Cancel the timer and close the controller.
  void stopTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
      controller.close();
    }
  }

  //Tell the timer what to do in each circumstance.
  controller = StreamController<List<String>>(
      onListen: startTimer,
      onPause: stopTimer,
      onResume: startTimer,
      onCancel: stopTimer);

  return controller.stream;
}

//Create the "Listen" screen.
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //Create a media player that changes the button layout depending on
        //whether the audio is playing, paused, or stopped.
        child: StreamBuilder<PlaybackState>(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            final state =
                snapshot.data?.basicState ?? BasicPlaybackState.stopped;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Display song info from the stream created by streamCreator.
                StreamBuilder<List<String>>(
                  //Get info every 5 seconds.
                  stream: streamCreator(const Duration(seconds: 5)),
                  builder: (context, snapshot) {
                    //Show error if info cannot be retrieved.
                    if (snapshot.hasError) return Text('${snapshot.error}');
                    if (snapshot.hasData)
                      return Column(children: [
                        //Display show name (big and bold), album art, song name (in bold), artist, and
                        //album. If no album art exists, use default logo.
                        Text(snapshot.data?.elementAt(4) ?? "\n",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
                        Text("\n\n"),
                        if (snapshot.data.elementAt(2) != null)
                          Image.network(snapshot.data.elementAt(2))
                        else
                          Image(image: AssetImage('assets/icon.jpg')),
                        Text("\n\n" + snapshot.data?.elementAt(1) ?? "\n",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(snapshot.data?.elementAt(0) ?? "\n"),
                        Text((snapshot.data?.elementAt(3) ?? "\n") + "\n\n\n")
                      ]);
                    //Show a circular progress indicator while information is
                    //loading.
                    return const CircularProgressIndicator();
                  },
                ),
                //Change currently displaying play/pause/stop controls depending
                //on the state of playback.
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (state == BasicPlaybackState.playing)
                        IconButton(
                            icon: Icon(Icons.pause),
                            onPressed: pause,
                            iconSize: 72.0)
                      else
                        IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: play,
                            iconSize: 72.0),
                      if (state != BasicPlaybackState.stopped)
                        IconButton(
                            icon: Icon(Icons.stop),
                            onPressed: stop,
                            iconSize: 72.0),
                    ])
              ],
            );
          },
        ),
      ),
    );
  }

  //If audio has already been started, simply resume playing audio. Else, play
  //the audio and create a background player as a notification that will
  //allow the user to hear and control the audio from outside the app.
  play() async {
    if (await AudioService.running) {
      AudioService.play();
    } else {
      AudioService.start(
          backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
          androidNotificationChannelName: 'WMUH Radio',
          notificationColor: 0xA12237,
          androidNotificationIcon: 'drawable/ic_stat_radio');
    }
  }

  //Set up pause and stop methods.
  pause() => AudioService.pause();

  stop() => AudioService.stop();
}

//Start the AudioServiceBackground widget using our AudioPlayerTask.
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

    //Set stream URL.
    await _audioPlayer.setUrl("http://192.104.181.26:8000/stream");
    //Play audio.
    _audioPlayer.play();
    //Use streamCreator to get song info.
    infoStream = streamCreator(const Duration(seconds: 5));
    //Set current media item in outside player to data from scraper.
    subscription = infoStream.listen((data) {
      currentSong = MediaItem(
        id: "http://192.104.181.26:8000/stream",
        album: data?.elementAt(3) ?? "WMUH Radio",
        title: data?.elementAt(1) ?? data?.elementAt(4) ?? "",
        artist: data?.elementAt(0) ?? "",
        artUri: data?.elementAt(2) ?? "",
      );
      setItem = AudioServiceBackground.setMediaItem(currentSong);
    }, cancelOnError: true);
    await _completer.future;
  }

  //Stop audio and destroy background player to save memory.
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

//Connect to Audio Service when app is running, disconnect when it is closed.
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
  //Launch app at "Listen" screen.
  int _currentIndex = 0;
  //Set nav bar items to be widgets of other screens.
  final List<Widget> _children = [
    MainScreen(),
    webview.Schedule(),
    server.Home(),
    contacts.RadioScreen()
  ];

  //Create a scaffold with the title header and bottom nav bar.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(107.5),
          child: AppBar(
            flexibleSpace: Image(
              image: AssetImage('assets/title.png'),
              fit: BoxFit.cover,
            ),
            backgroundColor: Colors.transparent,
          )),
      //Load all screens at once to preserve all states (prevents schedule from
      // crashing.
      body: IndexedStack(index: _currentIndex, children: _children),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex:
            _currentIndex, // this will be set when a new tab is tapped
        selectedItemColor: Colors.red[600],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.radio),
            title: new Text('Listen'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.schedule),
            title: new Text('Schedule'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.music_note),
            title: new Text('Send Request'),
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.message), title: new Text('Contact Us'))
        ],
      ),
    ));
  }

  //Change currently showing screen.
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
