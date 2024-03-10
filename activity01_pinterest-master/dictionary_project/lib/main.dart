import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const MyDictionaryApp(title: 'Dictionary Application'),
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
  final TextEditingController _controller = TextEditingController();

  Future<void> _searchDictionary(String query) async {
    final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data;
      });
    } else {
      setState(() {
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Custom AppBar with Search Bar
            Container(
              height: 100,
              color: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _searchDictionary(_controller.text);
                    },
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (_searchResults != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults!.length,
                  itemBuilder: (context, index) {
                    final definition = _searchResults![index]['meanings'][0]['definitions'][0]['definition'];
                    return Card(
                      margin: const EdgeInsets.all(8), // Adjust margin here
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meaning ${index + 1}:',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              definition,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_searchResults == null && _controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Definition not found',
                  style: TextStyle(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
