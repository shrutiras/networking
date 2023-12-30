import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> fetchAlbum() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> data = jsonDecode(response.body);
    print(data);
    List<Album> albums = data.map((json) => Album.fromJson(json)).toList();
    print(albums.length);
    return albums;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<Album> createAlbum(String title) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    print('Album Created');
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

Future<Album> deleteAlbum(String id) async {
  final http.Response response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON. After deleting,
    // you'll get an empty JSON `{}` response.
    // Don't return `null`, otherwise `snapshot.hasData`
    // will always return false on `FutureBuilder`.
    print("album deleted");
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a "200 OK response",
    // then throw an exception.
    throw Exception('Failed to delete album.');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'userId': int userId,
        'id': int id,
        'title': String title,
      } =>
        Album(
          userId: userId,
          id: id,
          title: title,
        ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;
  final TextEditingController title = TextEditingController();
  final TextEditingController ID = TextEditingController();
  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
    print(futureAlbum.then((value) => value[0].title));
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
        floatingActionButton: SizedBox(
          width: 1000,
          child: FloatingActionButton(
            onPressed: () => {},
            child: SizedBox(
              height: 100,
              width: 50,
              child: Row(
                children: [
                  SizedBox(
                      width: 350,
                      child: TextField(
                        controller: title,
                        textAlign: TextAlign.left,
                      )),
                  IconButton(
                      onPressed: () => {createAlbum(title.text.toString())},
                      icon: Icon(Icons.add)),
                      
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text('Album Data'),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              // ignore: dead_code
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Album album = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          contentPadding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(120)),
                          title: Text(album.title),
                          leading: Icon(Icons.delete),
                          onTap: () => {deleteAlbum(ID.text.toString())},
                          subtitle: Text('ID: $album.id'),
                          tileColor: Color.fromRGBO(21, 183, 16, 0.145),
                          splashColor: Color.fromRGBO(0, 13, 137, 21),
                          textColor: Colors.cyan),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              //By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      );
    return MaterialApp(
      title: 'Album Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: scaffold,
    );
  }
}
