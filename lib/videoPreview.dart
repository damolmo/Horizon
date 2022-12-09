import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class videoPreview extends StatefulWidget{
  @override
  videoPreview({
   super.key,
   required this.videoPath,
    required this.videoName,
});

  final String videoPath;
  final String videoName;

  _videoPreviewState createState() => _videoPreviewState(videoPath: videoPath, videoName: videoName);
}

class _videoPreviewState extends State<videoPreview>{
  @override

  _videoPreviewState({
    required this.videoPath,
    required this.videoName,
  });

  final fileVideo = File("/data/user/0/com.daviiid99.horizon/app_flutter/videos.json");
  final String videoName;
  final String videoPath;
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  IconData playIcon = Icons.play_arrow_rounded;
  IconData pauseIcon = Icons.pause_rounded;
  IconData currentIcon = Icons.pause_rounded;
  bool playing = true;
  IconData currentVolume = Icons.volume_up_rounded;
  IconData currentVolumeOn = Icons.volume_up_rounded;
  IconData currentVolumeOff = Icons.volume_off_rounded;
  bool volumeOn = true;
  IconData currentLoop = Icons.loop_rounded;
  IconData loopOn = Icons.loop_rounded;
  IconData loopLock = Icons.lock_rounded;
  bool looping = true;
  bool visibility = true;
  //Duration videoDuration = Duration(hours: 0, minutes: 0);
  //Duration currentPos =  Duration(hours: 0, minutes: 0);


  void initState()  async {
    print("este es el video $videoPath");
    _videoPlayerController =  VideoPlayerController.file(File(videoPath));
    _initializeVideoPlayerFuture =  _videoPlayerController.initialize();
    _videoPlayerController.play();
    _videoPlayerController.setLooping(true);
    super.initState();
  }

  void dispose(){
    _videoPlayerController.dispose();
    super.dispose();
  }

  void checkVideoState(){
    // This method pause or resume current video
   setState((){
  if (playing){
    // Pause video
        playing = false;
        currentIcon = playIcon;
        _videoPlayerController.pause();
    } else {
    // Resume video
      playing = true;
      currentIcon = pauseIcon;
      _videoPlayerController.play();
    }
   });
  }

  void checkVideoVolume(){
    // This method manages current video output volume
    // 0.0 OFF / 1.0 ON
    setState(() {
      if (volumeOn){
        // VOLUME OFF
        currentVolume = currentVolumeOff;
        _videoPlayerController.setVolume(0.0);
        volumeOn = false;

      } else {
        // VOLUME ON
        currentVolume = currentVolumeOn;
        _videoPlayerController.setVolume(1.0);
        volumeOn = true;
      }
    });
  }

  void checkVideoLoop() {
    // Video resume playing in loop by default
    // Allow user to disable loop if needed

    setState(() {
      if (looping){
        // LOOP OFF
        _videoPlayerController.setLooping(false);
        looping = false;
        currentLoop = loopLock;

      } else {
        // LOOP ON
        _videoPlayerController.setLooping(true);
        looping = true;
        currentLoop = loopOn;
      }
    });
  }

  void videoNavBarVisibility(){
    // This manages the visibility of navbar on play
    // It's a common feature on video players
    setState(() {
      if (visibility){
        // Hide navbar
        visibility = false;
      } else {
        // Show navbar
        visibility = true;
      }
    });
  }

  Container videoNavbarController(BuildContext context){
    return Container(
      child : ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child : BottomNavigationBar(
      backgroundColor: Colors.blueAccent.withOpacity(0.5),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
    label: "",
    icon: IconButton(icon : Icon(currentVolume, color: Colors.white, size: 40), onPressed: (){
      checkVideoVolume();
    },),
    ),

    BottomNavigationBarItem(
    label: "",
      icon: IconButton(icon : Icon(currentIcon, color: Colors.white, size: 40), onPressed: (){
        checkVideoState();
      },),
    ),

    BottomNavigationBarItem(
    label: "",
      icon: IconButton(icon : Icon(currentLoop, color: Colors.white, size: 40), onPressed: (){
        checkVideoLoop();
      },),
          ),
        ]
      )
      )
    );
  }

  /**
  List<Duration> updateCurrentTimeStamp() {

    List<Duration> duraciones = [];

    // This is an attemp to retrieve current video playback position
     setState((){
       videoDuration = _videoPlayerController.value.duration;
       currentPos = _videoPlayerController.value.position;
     });

     return  duraciones = [videoDuration, currentPos ];
  }*/

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(children: [
          Spacer(),
          if (visibility)
            Text(videoName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
          Spacer(),
        ],),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: Column(
      children : [
        InkWell(
          onTap: (){
            videoNavBarVisibility();
          },
       child : Container(
           child : FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
              child:VideoPlayer(_videoPlayerController),);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      )
       ),
        ),

    //Text("${updateCurrentTimeStamp()[1]} / ${updateCurrentTimeStamp()[0]}", style: TextStyle(color: Colors.white),),


    Container(
      child:VideoProgressIndicator(
        _videoPlayerController,
        allowScrubbing: true,
        colors:VideoProgressColors(
          backgroundColor: Colors.transparent,
          playedColor: Colors.blueAccent.withOpacity(0.5),
          bufferedColor: Colors.black,
        )
    )),

    SizedBox(height: 20,),

    if(visibility)
    videoNavbarController(context),
      ]
      )
    );
  }
}