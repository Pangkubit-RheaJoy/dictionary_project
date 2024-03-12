import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

AudioPlayer _audioPlayer = AudioPlayer();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Dictionary App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const MyDictionaryApp(title: 'Simple Dictionary App'),
    );
  }
}

class MyDictionaryApp extends StatefulWidget {
  const MyDictionaryApp({Key? key, required this.title});

  final String title;

  @override
  State<MyDictionaryApp> createState() => _MyDictionaryAppState();
}

class _MyDictionaryAppState extends State<MyDictionaryApp> {
  List<dynamic>? _searchResults;
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();
  bool _showMore = false;
  AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _searchDictionary(String query) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _searchResults = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchResults = null;
        _isLoading = false;
      });
    }
  }

  void _playAudio(String audioUrl) async {
    final urlSource = UrlSource(audioUrl);
    await _audioPlayer.play(urlSource);
  }

  // Predefined words alphabetically
  final List<String> predefinedWords = [
    'apple', 'ball', 'cat', 'dog', 'elephant', 'fish', 'goat', 'hat', 'ice', 'jar',
    'kite', 'lamp', 'monkey', 'nest', 'owl', 'pear', 'quill', 'rabbit', 'snake', 'table',
    'umbrella', 'violin', 'whale', 'xylophone', 'yak', 'zebra', 'ant', 'bee', 'cow',
    'duck', 'eagle', 'frog', 'giraffe', 'horse', 'igloo', 'jellyfish', 'kangaroo', 'lion',
    'mouse', 'nut', 'orange', 'parrot', 'queen', 'rhinoceros', 'seal', 'tiger', 'unicorn',
    'vase', 'wolf', 'x-ray', 'yacht', 'zucchini', 'airplane', 'boat', 'car', 'door', 'egg',
    'fire', 'grass', 'hat', 'ink', 'jug', 'key', 'ladder', 'moon', 'nail', 'orange', 'pen',
    'quilt', 'rocket', 'sun', 'tree', 'umbrella', 'vase', 'window', 'xylophone', 'yarn',
    'zipper', 'anchor', 'bridge', 'clock', 'dragon', 'elephant', 'fence', 'glove', 'hammer',
    'igloo', 'jacket', 'kettle', 'ladder', 'map', 'nail', 'octopus', 'pillow', 'quilt',
    'robot', 'spoon', 'telescope', 'unicorn', 'volcano'
  ];

  // Function to handle the click on predefined word
  void _handlePredefinedWordClick(String word) {
    _controller.text = word;
    _searchDictionary(word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Custom AppBar with Search Bar
            AppBar(
              backgroundColor: Color(0xFF6B2A2A),
              title: Text(
                widget.title,
                style: TextStyle(color: Colors.white, fontFamily: 'SerifDisplay'),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () {
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),

              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                // color: Color(0xFFE0E0E0),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'SerifDisplay'),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.grey, fontFamily: 'SerifDisplay'),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _searchDictionary(_controller.text);
                      },
                      icon: const Icon(Icons.search, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _searchResults = null;
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_searchResults != null)
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // Adjust card width here
                    child: Card(
                      shape: const ContinuousRectangleBorder(),
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: 1, // Only one item
                          itemBuilder: (context, index) {
                            final word = _searchResults![index]['word'] as String;
                            final meanings = _searchResults![index]['meanings'] as List<dynamic>;
                            final pronunciations = _searchResults![index]['phonetics'] as List<dynamic>;
                            final audioUrl = pronunciations.isNotEmpty ? pronunciations[0]['audio'] : null;
                            final definitions = meanings[0]['definitions'] as List<dynamic>;
                            final partOfSpeech = meanings[0]['partOfSpeech'] as String;
                            List<Widget> definitionWidgets = [];

                            final wordData = _searchResults![index];
                            final phonetics = wordData['phonetics'] as List<dynamic>;
                            final phoneticText = phonetics.isNotEmpty ? (phonetics[0]['text'] as String) : '';


                            for (var i = 0; i < definitions.length; i++) {
                              final definition = definitions[i]['definition'];
                              Widget definitionWidget = Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  '${i + 1}. $definition',
                                  style: const TextStyle(color: Color(0xFF2A2A2A), fontFamily: 'SourceSerif'),
                                ),
                              );
                              definitionWidgets.add(definitionWidget);
                            }

                            // Determine how many definitions to show based on _showMore
                            final visibleDefinitions = _showMore ? definitionWidgets : definitionWidgets.take(3).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        word.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1C1C1C),
                                            fontFamily: 'SerifDisplay'
                                        ),
                                      ),
                                      Text(
                                        phoneticText.isNotEmpty ? " [$phoneticText]" : "",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (audioUrl != null)
                                        IconButton(
                                          icon: const Icon(Icons.volume_up),
                                          onPressed: () {
                                            _playAudio(audioUrl);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        partOfSpeech.toLowerCase(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF4B4B4B),
                                            fontFamily: 'SerifDisplay'
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  height: 10,
                                ),
                                ...visibleDefinitions,
                                if (definitions.length > 3 && !_showMore)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showMore = true;
                                      });
                                    },
                                    child: const Text(
                                      'Show More',
                                      style: TextStyle(color: Colors.blue, fontFamily: 'SourceSerif'),
                                    ),
                                  ),
                                if (_showMore)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showMore = false;
                                      });
                                    },
                                    child: const Text(
                                      'Show Less',
                                      style: TextStyle(color: Colors.blue, fontFamily: 'SourceSerif'),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (_controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Definition not found',
                    style: const TextStyle(color: Colors.black, fontFamily: 'SourceSerif'),
                  ),
                ),
            // Display predefined words alphabetically
            Expanded(
              child: _searchResults == null
                  ? Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Card(
                    shape: const ContinuousRectangleBorder(),
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < predefinedWords.length; i++)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _handlePredefinedWordClick(predefinedWords[i]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        predefinedWords[i],
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontFamily: 'SerifDisplay'
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (i != predefinedWords.length - 1) Divider(color: Colors.white),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : SizedBox(), // Add an empty SizedBox when _searchResults is not null
            ),

          ],
        ),
      ),
    );
  }
}
