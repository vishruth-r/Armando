import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts ftts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _selectedLanguage = 'en-US'; // Default language
  Timer? _timer;
  bool _apiRequestSent = false;
  String _apiResponse = ''; // Added to store API response

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      // Initialize speech recognition
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        // Start listening for speech
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });

            // Reset the timer when new words are recognized
            _resetTimer();
          },
          listenMode: stt.ListenMode.confirmation,
          localeId: _selectedLanguage,
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
    // Stop the timer when stopping listening
    _cancelTimer();
  }

  void _resetTimer() {
    // Cancel the previous timer if it exists
    _cancelTimer();

    // Set a new timer to send the recognized text after 5 seconds
    _timer = Timer(Duration(seconds: 5), () {
      _sendToAPI(_recognizedText);
    });
  }

  void _cancelTimer() {
    // Cancel the timer if it's active
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  Future<void> _sendToAPI(String text) async {
    if (_apiRequestSent) {
      return; // Don't send another request until the previous one is done
    }

    print(text);
    final apiUrl = Uri.parse('http://192.168.47.104:3000/api/chat/answer');

    try {
      final response = await http.post(apiUrl, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'prompt': text}));
      print(response);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        // Check if the 'data' field is not null and is a non-empty string
        if (data != null && data is String && data.isNotEmpty) {
          // Read out the 'data' field using text-to-speech
          _speakText(data);
          setState(() {
            _apiResponse = data; // Store API response
            _isListening = false; // Change back to "Start Listening"
          });
        } else {
          print('Invalid or empty "data" field in API response.');
        }
      } else {
        print('API Request Failed: ${response.statusCode}');
      }

      setState(() {
        _apiRequestSent = true;
      });
    } catch (e) {
      print('Error sending request to API: $e');
    }
  }

  Future<void> _speakText(String text) async {
    // Configure text-to-speech
    await ftts.setLanguage(_selectedLanguage);
    await ftts.setSpeechRate(0.5); // Speed of speech
    await ftts.setVolume(1.0); // Volume of speech
    await ftts.setPitch(1); // Pitch of sound

    // Play text-to-speech
    var result = await ftts.speak(text);
    if (result == 1) {
      // Speaking
    } else {
      // Not speaking
    }
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Recognition'),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Stack(
          children: [
            SvgPicture.asset(
              "assets/images/background.svg",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          if (_apiRequestSent) {
                            setState(() {
                              _apiRequestSent = false;
                              _apiResponse = ''; // Clear the API response
                            });
                          }
                          _listen();
                        },
                        child: Text(
                          _isListening ? 'Stop Listening' : 'Start Listening',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'en-US',
                            child: Text(
                              'English (US)',
                              style: TextStyle(color: Colors.grey),
                            ), // White text
                          ),
                          DropdownMenuItem(
                            value: 'hi-IN',
                            child: Text(
                              'Hindi (India)',
                              style: TextStyle(color: Colors.grey),
                            ), // White text
                          ),DropdownMenuItem(
                            value: 'ta-IN',
                            child: Text(
                              'Tamil (India)',
                              style: TextStyle(color: Colors.grey),
                            ), // White text
                          ),
                          // Add more language options as needed
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Recognized Text:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                      Text(
                        _recognizedText,
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'API Response:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                      Text(
                        _apiResponse,
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
