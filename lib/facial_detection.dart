import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UserRegistration extends StatefulWidget {
  @override
  _UserRegistrationState createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  String userName = '';
  File? userFaceImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  userName = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter Your Name',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                userFaceImage = await captureFaceImage();
                if (userFaceImage != null) {
                  await storeUserFaceImage(userName, userFaceImage!);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => FaceDetection(userName),
                  ));
                } else {
                  // Handle face capture error
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> captureFaceImage() async {
    // Implement the logic to capture the user's face image
    // Example using image_picker package:
    // final image = await ImagePicker().getImage(source: ImageSource.camera);
    // return File(image!.path);

    // Replace this with your actual logic for capturing the image
  }

  Future<void> storeUserFaceImage(String userName, File userFaceImage) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$userName.jpg';
      await userFaceImage.copy(imagePath);
    } catch (e) {
      print('Error storing user face image: $e');
    }
  }
}

class FaceDetection extends StatefulWidget {
  final String userName;

  FaceDetection(this.userName);

  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hello, ${widget.userName}'),
            // Implement the face detection logic here
            // Example: Detect faces using google_ml_kit_face_detection
          ],
        ),
      ),
    );
  }
}
