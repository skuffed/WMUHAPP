import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

Future<List<String>> getSong()async {
  var client = Client();
  Response response = await client.get(
      'https://spinitron.com/WMUH/'
  );
  List<String> list = List();
  // Use html parser and query selector
  var document = parse(response.body);
  List<Element> links = document.querySelectorAll('span');

  final elements = document.getElementsByClassName('spin-art-container');

  list = elements.map((element) => element.getElementsByTagName("img")[0].attributes['src']).toList();

  //document.querySelectorAll('a').forEach((value) {
  //print(value.outerHtml);
  //});

  String parsedString1 = parse(links?.elementAt(0)?.text ?? "").documentElement.text;
  String parsedString2 = parse(links[1].text).documentElement.text;
  String parsedString3 = parse(list?.elementAt(0) ?? "").documentElement.text;
  String parsedString4 = parse(links[2].text).documentElement.text;
//  String newLine = '\n';
//  String artist = 'Artist: ';
//  String song = 'Song: ';
//  var songArtist = artist + parsedString1 + newLine + song + parsedString2;
  return [parsedString1, parsedString2, parsedString3, parsedString4];
}