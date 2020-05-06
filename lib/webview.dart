import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Schedule extends StatelessWidget {
  // Shows Schedule page for WMUH (https://spinitron.com/WMUH/calendar)
  //Has button for returning to previous page

  //created in order to control actions in the webview
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {

    //create display scaffold for the webview to sit in
    //this will display the webpage requested in initialUrl
    return Scaffold(
      body: WebView(
        initialUrl: 'https://spinitron.com/WMUH/calendar',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
      floatingActionButton: NavigationControls(_controller.future),
    );
  }
}

//separate class for navigation controls (floatingactionbutton)
//which will house the code for the back button
class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  //builds the functionality for the back button widget
  //it will save the previous site if a new url is called
  //and use that as the initialurl if the button is pressed
  Widget build(BuildContext context) {
    //create a future for the back button (webviewcontroller)
    //so that the program continues to work while it runs
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return FloatingActionButton.extended(
          //check that requirements are met for the button to be pressed
          onPressed: !webViewReady
              ? null
              : () => navigate(context, controller, goBack: true),
          icon: Icon(Icons.arrow_back),
          backgroundColor: Colors.black,
          label: Text("Back"),
        );
      },
    );
  }

  //checks if the webview controller can go back to the previous page successfully
  //and if
  navigate(BuildContext context, WebViewController controller,
      {bool goBack: false}) async {
    //checks that the webview has a previous or forward history item and that it exists
    bool canNavigate =
    goBack ? await controller.canGoBack() : await controller.canGoForward();
    //if these are true go to the previous webpage stored in webview
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text("Last Page")),
      );
    }
  }
}