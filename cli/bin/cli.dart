// import 'package:cli/cli.dart' as cli;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:command_runner/command_runner.dart';

const version = '0.0.1';

void main(List<String> arguments) {
  var commandRunner = CommandRunner(
      onError: (Object error) {
        if (error is Error) {
          throw error;
        }
        if (error is Exception) {
          print(error);
        }
      }
  )..addCommand(HelpCommand());
  commandRunner.run(arguments);
}

void searchWikipedia(List<String>? arguments) async {
  final String? articleTitle;

  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title :');
    final inputFromStdin = stdin.readLineSync();
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      return;
    }
    articleTitle = inputFromStdin;
  } else {
    articleTitle = arguments.join(' ');
  }

  print('Looking up articles about "$articleTitle". Please wait.');
  // Call the API and await the result
  var articleContent = await getWikipediaArticle(articleTitle);
  print(articleContent);
}

void printUsage() {
  print("The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'");
}

Future<String> getWikipediaArticle(String articleTitle) async {
  final client = http.Client();
  final url = Uri.https('en.wikipedia.org', '/api/rest_v1/page/summary/$articleTitle');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return response.body;
  }
  // Return an error message if the request failed
  return 'Error: Failed to fetch article "$articleTitle". Status code: ${response.statusCode}';
}
