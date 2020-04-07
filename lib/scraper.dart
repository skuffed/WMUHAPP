import 'dart:convert';

import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

Future<String> getSong()async {
  var client = Client();
  Response response = await client.get(
      'https://spinitron.com/WMUH/'
  );

  // Use html parser and query selector
  var document = parse(response.body);
  var x = document.querySelectorAll('class.artist');
  List<Element> links = document.querySelectorAll('span');

  //document.querySelectorAll('a').forEach((value) {
  //print(value.outerHtml);
  //});

  String parsedString1 = parse(links[0].text).documentElement.text;
  String parsedString2 = parse(links[1].text).documentElement.text;
  print(parsedString1);
  print(parsedString2);
  String newLine = '\n';
  String artist = 'Artist: ';
  String song = 'Song: ';
  var songArtist = artist + parsedString1 + newLine + song + parsedString2;
  print(songArtist);
  return songArtist;
}