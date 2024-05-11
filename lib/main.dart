import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Birthday App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BirthdayApp(),
    );
  }
}

class BirthdayApp extends StatefulWidget {
  @override
  _BirthdayAppState createState() => _BirthdayAppState();
}

class _BirthdayAppState extends State<BirthdayApp> {
  TextEditingController inputController = TextEditingController();
  String outputText = '';
  final audioPlayer = AudioPlayer();

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  String convertToBase64(DateTime dob) {
    return base64.encode(utf8.encode(dob.toIso8601String()));
  }

  DateTime? convertFromBase64(String base64String) {
    try {
      String decodedString = utf8.decode(base64.decode(base64String));
      return DateTime.parse(decodedString);
    } catch (e) {
      print('Error decoding base64 string: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Birthday App'),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/happy_birthday.gif', // Path to your GIF file
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.7), // Semi-transparent white background
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your Birthday',
                      hintText: 'YYYY-MM-DD or Base64 String',
                      border: InputBorder.none, // Remove border
                    ),
                    keyboardType: TextInputType.text,
                    autofocus: true, // Set autofocus to true
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String inputText = inputController.text;
                    if (inputText.isNotEmpty) {
                      // Check if input is base64 or normal date
                      if (RegExp(r'^[0-9a-zA-Z\+/=]+$').hasMatch(inputText)) {
                        // Input is base64 string
                        DateTime? decodedDate = convertFromBase64(inputText);
                        if (decodedDate != null) {
                          setState(() {
                            outputText =
                                'Decoded Birthday: ${decodedDate.toIso8601String()}';
                          });
                        } else {
                          _showSnackBar('Invalid Base64 String!');
                        }
                      } else {
                        // Input is normal date string
                        DateTime? dob = DateTime.tryParse(inputText);
                        if (dob != null) {
                          String base64Birthday = convertToBase64(dob);
                          setState(() {
                            outputText = 'Base64 Birthday: $base64Birthday';
                          });
                        } else {
                          _showSnackBar('Invalid Date Format!');
                        }
                      }
                    } else {
                      _showSnackBar('Please enter your birthday!');
                    }

                    // Play birthday music from local asset
                    try {
                      await audioPlayer.setAsset('assets/birthday_music.mp3');
                      await audioPlayer.play();
                    } catch (e) {
                      print('Error playing audio: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Convert'),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.7), // Semi-transparent white background
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: outputText),
                    decoration: InputDecoration(
                      labelText: 'Output',
                      border: InputBorder.none, // Remove border
                      suffixIcon: IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: outputText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Copied to Clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
