import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

//Function to scrape the Spinitron website for information about the currently playing song
//The name of the show currently being played as well as album art if given
//The function is created as a future so that the app can still continue to work
//while the function is executing

Future<List<String>> getSong()async {
  var client = Client(); //create client to grab the data from the spinitron website
  Response response = await client.get(
      'https://spinitron.com/WMUH/'
  ); //store in a response variable in order to prepare it to be parsed

  // Use html parser and query selector
  var document = parse(response.body); //parse the response variable in order to make it readable

  //create various lists of html tags
  List<Element> links = document.querySelectorAll('span');
  List<Element> title = document.querySelectorAll('a');
  final elements = document.getElementsByClassName('spin-art-container');

  //fill list with image links
  List<String> list = List();
  list = elements.map((element) => element.getElementsByTagName("img")[0].attributes['src']).toList();

  //select the correct tag from the list (currently playing song information) and store
  //as a string in order to return a readable variable to be displayed

  String parsedString1 = parse(links[0].text).documentElement.text; //artist
  String parsedString2 = parse(links[1].text).documentElement.text; //song name
  String parsedString3 = parse(list[0]).documentElement.text;
  String parsedString4 = parse(links[2].text).documentElement.text;
  String parsedString5 = parse(title[5].text).documentElement.text; //on air title

  //return as a list in order to return multiple strings efficiently (avoids calling other functions for same data)
  return [parsedString1, parsedString2, parsedString3, parsedString4, parsedString5];
}