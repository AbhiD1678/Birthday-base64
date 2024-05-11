import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: inputController,
              decoration: InputDecoration(
                labelText: 'Enter Your Birthday',
                hintText: 'YYYY-MM-DD or Base64 String',
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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
              },
              child: const Text('Convert'),
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: outputText),
              decoration: InputDecoration(
                labelText: 'Output',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: outputText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to Clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
