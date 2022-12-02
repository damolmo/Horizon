import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:islander_gallery/preview.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //  Fetch cameras before runApp
  final cameras = await availableCameras(); // Get available cameras
  final mainCamera = cameras.getRange(0, 1).single; // Get main camera
  final selfieCamera = cameras.getRange(1, 2).single; // Get selfie camera
  final camera = cameras.first; // Get selfie camera

  print(mainCamera);
  print(selfieCamera);
  print(camera);

  runApp(
      MaterialApp(
      title: "Islander Gallery",
      home: Preview(mainCamera : mainCamera, selfieCamera : selfieCamera),
    ),
  );
  }
