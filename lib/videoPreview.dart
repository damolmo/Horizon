import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class videoPreview extends StatefulWidget{
  @override
  videoPreview({
   super.key,
   required this.videoPath,
});

  final String videoPath;

  _videoPreviewState createState() => _videoPreviewState(videoPath: videoPath);
}

class _videoPreviewState extends State<videoPreview>{
  @override

  _videoPreviewState({
    required this.videoPath,
  });

  final fileVideo = File("/data/user/0/com.daviiid99.horizon/app_flutter/videos.json");
  late final String videoPath;
  late VideoPlayerController _videoPlayerController;


  void initState(){
    _initVideoPlayer();
    super.initState();
  }

  void dispose(){
    _videoPlayerController.dispose();
    super.dispose();
  }


  Future _initVideoPlayer() async {
     videoPath = "/data/user/0/com.daviiid99.horizon/app_flutter/VIDEO_2022-12-02_01_20_01.mp4";
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          VideoPlayer(_videoPlayerController)
        ],
      ),
    );
  }
}