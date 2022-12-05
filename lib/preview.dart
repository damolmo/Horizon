import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'home.dart';
import 'imagePreview.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:share/share.dart';

class Preview extends StatefulWidget{
  @override

  Preview( {
    super.key,
    required this.mainCamera,
    required this.selfieCamera,
  });

  final CameraDescription mainCamera; // main camera
  final CameraDescription selfieCamera; // selfie camera

  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {

  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  final fileVideo = File("/data/user/0/com.daviiid99.horizon/app_flutter/videos.json");
  Map<dynamic, dynamic> photos = {};
  Map<dynamic, dynamic> photosCategories = {};
  Map<dynamic, dynamic> videos = {};
  List<String> currentPhotos = [];
  List<String> currentVideos = [];
  List<String> currentVideosName = [];
  List<String> currentPhotosName = [];
  List<String> categories = [];
  bool esReciente = true;
  bool esCategorias = false;
  String latestPhoto = "";
  String latestPhotoName = "";
  QRViewController? controller;
  Barcode? qrOutput;



  // Types of controllers
  late CameraController _controladorMain;
  late CameraController _controladorSelfie;
  late CameraController _currentSensor;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  // Futures of controllers types
  late Future<void> _futureControllerMain;
  late Future<void> _futureControllerSelfie;
  late Future<void> _futureControllerCurrent;

  // Variables to define camera componentes state
  String currentCamera = "main";
  bool flashEnabled = false;
  int flashMode = 0; // Range from 0 to 2 (OFF, ON, AUTO)
  bool autoEnabled = false;
  IconData flashState = Icons.flash_off_rounded;
  ResolutionPreset currentResMain = ResolutionPreset.medium;
  ResolutionPreset currentResSelfie = ResolutionPreset.low;
  String imagePath = "";
  String imageName = "";
  Image imageAsset = Image.file(File("assets/icon/banner.png"));
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd_ss_mm_hh');
  String date = "";
  Color cameraButtonColor = Colors.blueAccent;
  bool isCamera = true;
  bool isQRScanner = false;
  bool isRecording = false;
  late XFile video;
  // Available resolutions
  List<String> cameraResultionsStrings =["Baja", "Media", "Alta", "Muy Alta", "Súper Alta", "Máxima"];
  List<ResolutionPreset> cameraResultions =[ResolutionPreset.low, ResolutionPreset.medium, ResolutionPreset.high, ResolutionPreset.veryHigh, ResolutionPreset.ultraHigh, ResolutionPreset.max];
  String cameraTypeString = "Cámara Principal";

  @override
  void initState() {
    super.initState();

    getCurrentDateTime();
    updateHashMap();

    // MAIN CAMERA CONTROLLER (0)
    _controladorMain = CameraController(
        widget.mainCamera,
        currentResMain,
    );
    // INITIALIZATION WILL BE MADE ON RESPECTIVE SETSTATE
    //_futureControllerMain = _controladorMain.initialize();

    // SELFIE CAMERA CONTROLLER (1)
    _controladorSelfie = CameraController(
        widget.selfieCamera,
        currentResSelfie,
    );


    // INITIALIZATION WILL BE MADE ON RESPECTIVE SETSTATE
    //_futureControllerSelfie = _controladorSelfie.initialize();

    _currentSensor = _controladorMain;
    _futureControllerCurrent = _currentSensor.initialize();

    // Load home screen instead of camera preview

    Navigator.push(context, MaterialPageRoute(builder: (context)=> homeMenu(esReciente : esReciente, esCategorias : esCategorias, categories : categories, currentVideos: currentVideos, currentVideosName : currentVideosName, photos : photos )));
  }

  @override
  void dispose(){
    // MAIN CAMERA
    //_controladorMain.dispose();

    // SELFIE CAMERA
    //_controladorSelfie.dispose();

    _currentSensor.dispose();
    controller?.dispose();

    super.dispose();
  }

  updateLists() async {
    // Update lists with current hashmap content

    // Update categories list
    for (String categoria in photos.keys){
      if (!categories.contains(categoria) && photos[categoria].keys.length > 0 ){
        setState(() {
          categories.add(categoria);
        });

      }
    }

    // Update photos
    if (photos.containsKey("Reciente")) {
      for (String img in photos["Reciente"].keys) {
        setState(() {
          currentPhotos.add(photos["Reciente"][img]); // photo path
          currentPhotosName.add(img); // photo name
        });
      }
    }

    print(currentPhotos);

    for (String video in videos.keys){
        setState(() {
          currentVideos.add(videos[video]);
          currentVideosName.add(video);
        });
    }

    print("videosss ${currentVideos}"  );

  }

  updateHashMapFile() async {
    // Add all lists content to hashmap

    if (!photos.containsKey("Reciente")){
      photos["Reciente"] = {};
    }

    for (String photoName in currentPhotosName) {
        if (!photos["Reciente"].containsKey(photoName)) {
          int index = currentPhotosName.indexOf(photoName);
          photos["Reciente"][photoName] = currentPhotos[index];
        }
    }

    // Overwrite hashmap
    String jsonString = "";
    jsonString = jsonEncode(photos);
    file.writeAsStringSync(jsonString);

  }

  updateVideoHashMapFile() async {

    // Add all videos to hashmap
    for (String video in currentVideosName){
      if (!videos.containsKey(video)){
        int index = currentVideosName.indexOf(video);
        videos[video] = currentVideos[index];
      }
    }
    String jsonString = "";
    jsonString = jsonEncode(videos);
    fileVideo.writeAsStringSync(jsonString);
  }

  updateHashMap() async {
    String jsonString = "";

    // Check if JSON file exists
    if (!file.existsSync()){
      // File doesn't exists, create it
      jsonString = jsonEncode(photos); // empty hashmap
      file.writeAsStringSync(jsonString);


    } else {
      // Decode current JSON into hashmap
      jsonString = file.readAsStringSync();
      setState((){
        photos = jsonDecode(jsonString);
      });
      print(photos);
    }

    if (!fileVideo.existsSync()){
      // File doesn't exists, create it
      print("no existe el json de video");
      jsonString = jsonEncode(videos); // empty hashmap
      fileVideo.writeAsStringSync(jsonString);

    } else {
      // Decode current JSON into hashmap
      print("existe el json de videos");
      jsonString = fileVideo.readAsStringSync();
      setState((){
        videos = jsonDecode(jsonString);
      });
      print(videos);
    }

    updateLists();


  }

  updateCurrentPhotos(String photoPath, String photoName) async {
    setState(() {
      currentPhotosName.add(photoName);
      currentPhotos.add(photoPath);
    });
  }

  updateCurrentVideos(String videoPath, String videoName) async {
    setState(() {
      currentVideos.add(videoPath);
      currentVideosName.add(videoName);
    });
  }

  getCurrentDateTime() async {
    // Catch latest datetime before formatting it into a string
    setState(() {
      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyy-MM-dd_ss_mm_hh');
      date = formatter.format(now);
    });

  }

  void cameraResolutionsChooser() async {
    // User will be able to choose a resolution for main and selfie camera from a list of values
    // Each value represents a preset

    Widget header(){
      return FittedBox(
                    child : Column(
                        children : [
                          ElevatedButton.icon(
                            style : ElevatedButton.styleFrom(
                                backgroundColor: Colors.white
                            ),
                            icon : Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, ),
                            onPressed: (){}, label: Text(cameraTypeString, style: TextStyle(color: Colors.black),),
                          ),
                        ]));
    }

    Widget ListViewDialog(){
      return Container(
        height: 400,
          child: ListView.builder(
          itemCount: cameraResultionsStrings.length,
          itemBuilder: (context, index){
            return StatefulBuilder(
                builder: (context, setState){
                  return Card(
                      color: Colors.blueAccent,
                      child:  ListTile(
                          tileColor: Colors.transparent,
                          textColor: Colors.black,
                          title: Align(child : Text(cameraResultionsStrings[index],style: TextStyle(color: Colors.white, ),), alignment: Alignment.center),
                          onTap: (){
                            // We'll change the resolution of current camera sensor
                            if (cameraTypeString.contains("Selfie")){
                              currentResSelfie = cameraResultions[index];

                              setState((){
                                _currentSensor = CameraController(
                                  widget.selfieCamera,
                                  currentResSelfie,
                                );
                                reloadSelfieCamera(); // Reload camera with new config
                                Navigator.pop(context); // return to previous context


                              });
                            } else {
                              currentResMain = cameraResultions[index];

                              setState((){
                                _currentSensor = CameraController(
                                  widget.mainCamera,
                                  currentResMain,
                                );
                                reloadMainCamera(); // Reload camera with new config
                                Navigator.pop(context); // return to previous context

                              });
                            }

                          }
                      )
                  );
                }
            );
          }
      ));
    }


    showDialog(
        context: context, builder: (context){
          return StatefulBuilder(builder: (context, setState){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              backgroundColor: Colors.white,
              title: Column( children : [header(), const Text("\nResolución", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold))]),
              content : ListViewDialog(),
           );
          });
    });
  }

  void reloadMainCamera() async {
    setState(() {
      _currentSensor.pausePreview();
      _currentSensor = _controladorMain;
      _futureControllerCurrent =
          _currentSensor.initialize();
      _currentSensor.resumePreview();
      currentCamera = "main";
      cameraTypeString = "Cámara Principal";
      print(currentResMain);
    });
  }

  void reloadSelfieCamera() async {
    setState(() {
      _currentSensor.pausePreview();
      _currentSensor = _controladorSelfie;
      _futureControllerCurrent =
          _currentSensor.initialize();
      _currentSensor.resumePreview();
      currentCamera = "selfie";
      cameraTypeString = "Cámara Selfie";
      print(currentResSelfie);
    });
  }

  Future<void> _onTap(TapUpDetails details) async {
    if(_currentSensor.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * _currentSensor.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp,yp);
      print("point : $point");

      // Manually focus
      await _currentSensor.setFocusPoint(point);

      // Manually set light exposure
      //controller.setExposurePoint(point);

      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }

   takeCamera () async {
    // This method will call current camera sensor to take a picture

    try{
      // Double-check that the controller is available
      await _currentSensor;

      // Take the picture and save current picture path
      setState(() async {
        if (flashMode == 2){
          await _currentSensor.setFlashMode(FlashMode.auto);
          autoEnabled = true;

          if (isCamera) {
            // Default mode is camera recording
            final image = await _currentSensor.takePicture(); // Take picture
            getCurrentDateTime();
            final saveImage = await File(image.path).rename(
                "/data/user/0/com.daviiid99.horizon/app_flutter/IMG_$date.jpg"); // Rename picture path
            imagePath = await saveImage.path; // Get image path
            imageAsset = Image.file(File(imagePath)); // Update widget image
            updateCurrentPhotos(imagePath, "IMG_$date");
            updateHashMapFile();
            latestPhoto = imagePath;
            latestPhotoName = "IMG_$date";
          } else if (isQRScanner) {
            // User switched to QR Scanner mode
            _currentSensor.pausePreview(); // we can't use both at the same time
            onQRViewCreated: _onQRViewCreated;

          } else {
            if(!isRecording){
              // Default mode is video recording

              // Save a preview for the video to show in Gallery
              getCurrentDateTime();
              final image = await _currentSensor.takePicture();
              final filePath = await File(image.path).rename("/data/user/0/com.daviiid99.horizon/app_flutter/VIDEO_$date.jpg");
              final imagePath = await filePath.path;
              updateCurrentPhotos(imagePath, "VIDEO_$date");
              updateHashMapFile();
              imageAsset = Image.file(File(imagePath)); // Update widget image
              latestPhoto = imagePath;
              latestPhotoName = "VIDEO_$date";
              print("Guardando captura previa del video...");

              // Start recording
              await  _currentSensor.prepareForVideoRecording();
              await _currentSensor.startVideoRecording();
              isRecording = true;

              // Debugging message
              print("Grabando video...");

            } else {
              // Stop recording

              // Save the video and add it into video hashmap
              video = await _currentSensor.stopVideoRecording();
              isRecording = false;
              String videoURI = await video.path;
              final saveFile = await File(videoURI).rename("/data/user/0/com.daviiid99.horizon/app_flutter/VIDEO_$date.mp4");
              final videoPath = await saveFile.path;
              updateCurrentVideos(videoPath, "VIDEO_$date");
              updateVideoHashMapFile();
            }
          }
        }

       else {

         if (isCamera){
           final image = await _currentSensor.takePicture(); // Take picture
           getCurrentDateTime();
           final saveImage = await File(image.path).rename(
               "/data/user/0/com.daviiid99.horizon/app_flutter/IMG_$date.jpg"); // Rename picture path
           imagePath = await saveImage.path; // Get image path
           imageAsset = Image.file(File(imagePath)); // Update widget image
           updateCurrentPhotos(imagePath, "IMG_$date");
           updateHashMapFile();
           latestPhoto = imagePath;
           latestPhotoName = "IMG_$date";
         } else if (isQRScanner) {
           // User switched to QR Scanner mode
           _currentSensor.pausePreview(); // we can't use both at the same time
           onQRViewCreated: _onQRViewCreated;

         } else {
           if(!isRecording){
             // Default mode is video recording

             // Save a preview for the video to show in Gallery
             getCurrentDateTime();
             final image = await _currentSensor.takePicture();
             final filePath = await File(image.path).rename("/data/user/0/com.daviiid99.horizon/app_flutter/VIDEO_$date.jpg");
             final imagePath = await filePath.path;
             updateCurrentPhotos(imagePath, "VIDEO_$date");
             updateHashMapFile();
             imageAsset = Image.file(File(imagePath)); // Update widget image
             latestPhoto = imagePath;
             latestPhotoName = "VIDEO_$date";
             print("Guardando captura previa del video...");

             // Start recording
              await  _currentSensor.prepareForVideoRecording();
              await _currentSensor.startVideoRecording();
             isRecording = true;

             // Debugging message
             print("Grabando video...");

           } else {
             // Stop recording
             // Save the video and add it into video hashmap
             video = await _currentSensor.stopVideoRecording();
             isRecording = false;
             String videoURI = await video.path;
             final saveFile = await File(videoURI).rename("/data/user/0/com.daviiid99.horizon/app_flutter/VIDEO_$date.mp4");

             final videoPath = await saveFile.path;
             updateCurrentVideos(videoPath, "VIDEO_$date");
             updateHashMapFile();
             print("Guardando video..");
             Share.shareFiles([saveFile.path], text: "Hey, echale un vistazo a esta foto");
             updateVideoHashMapFile();

           }
         }

        }
      });

    } catch (e){
      print(e);
    }
  }


  void _onQRViewCreated(QRViewController controller ){
    // This method will handle QR code scan
    this.controller = controller;
    this.controller?.resumeCamera();
    controller.scannedDataStream.listen((scanData){
      setState(() {
        qrOutput = scanData;
        print(qrOutput);
      });
    });

    }


  Container CameraCaptureButton(BuildContext context) {
    // This is the camera capture button inside cameraPreview() scaffold
    // Allow to take pictures from camera preview
    return Container(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
          child :  Center(
            child : SingleChildScrollView(
          child : Column(
              children: [

            Row(
              children: [
                Spacer(),

                SizedBox(
                  width: 60,
                  height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FittedBox(
                      alignment : Alignment.center,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: CircleBorder()
                          ),
                          icon: Icon(Icons.cameraswitch_rounded, size: 50, color: Colors.white,),
                          onPressed: () async {
                            setState(() {
                              if (currentCamera.contains("selfie")) {
                                reloadMainCamera();
                              } else {
                               reloadSelfieCamera();

                              }

                            });

                          },
                          label: Text(""),
                        ),
                        ),
                      ),
                     ]
                    )
                  ),

                Spacer(),

                SizedBox(
                  width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FittedBox(
                          alignment: Alignment.center,
                          child : SizedBox(
                          width: 80,
                          height: 80,
                          child : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.white
                          ),
                          child: Text(""),
                          onPressed: (){},
                        ))),

                         FittedBox(
                         child : SizedBox(
                          width : 50,
                          height : 50,
                         child : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: cameraButtonColor
                            ),
                            child: Text(""),
                            onPressed: () async{
                              setState(() async {
                                await takeCamera();
                              });

                            },

                        )))
              ]
            ),
            ),

                Spacer(),

                SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FittedBox(
                            alignment : Alignment.center,
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                    shape: CircleBorder()
                                ),
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: ClipOval(
                                        child: Image.file(File(latestPhoto)),
                                      )
                                  ),
                                ),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => imagePreview(image: latestPhoto, imageName: latestPhotoName, currentVideos: currentVideos, currentVideosName: currentVideosName, currentCategory: "Reciente",)));

                                },
                                label: Text(""),
                              ),
                            ),
                          ),
                        ]
                    )
                ),

                Spacer(),
          ]
                ),

      SizedBox(height: 20,),
                SizedBox(height: 20,),

              ]
            )

    )
          )
      )
    );
  }


  SingleChildScrollView cameraNavBar() {
    // We need a scrollable bar with all camera buttons for all screen sizes

    return SingleChildScrollView(
      child: Column(
        children : [
          CameraCaptureButton(context),
          cameraOptions(),
      ]
      ),
    );
  }

  Container cameraOptions(){
    // This is a container handling all camera options
    // Camera, video, qrcode,...

    return Container(
        child : SingleChildScrollView(
          child: Column(
        children: [
          //CameraCaptureButton(context),
      Row(
        children: [
          Spacer(),
          TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.black
              ),
              onPressed: (){
                // Switch from video to camera mode
                if (!isCamera){
                  setState((){
                    cameraButtonColor = Colors.blueAccent;
                    isCamera = true;
                  });
                }
              },
              child: Text("Cámara", style: TextStyle(color: Colors.white, fontSize: 20),)),

          /**Spacer(),

          TextButton(
            onPressed: (){
              setState(() {
                isQRScanner = true;
                isCamera = false;
                cameraButtonColor = Colors.black;
              });


            },
            child: Text("QR", style: TextStyle(color: Colors.white, fontSize: 20),),
          ),*/

          Spacer(),
          TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.black
              ),
              onPressed: (){
                if (isCamera){
                  setState((){
                    cameraButtonColor = Colors.redAccent;
                    isCamera = false;
                  });
                }
              },
              child: Text("Vídeo", style: TextStyle(color: Colors.white, fontSize: 20),)),

          Spacer(),
        ],
      ),
      ]
    )
        )
    );
  }



  Scaffold cameraPreview(BuildContext context){
    // This is the camera preview context
    // Manages the camera hw of the device
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        title: Row(
          children: [
              FittedBox(
                alignment: Alignment.center,
                child:  ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: (){
                    if (currentCamera.contains("main")){
                      if (flashMode == 0){
                        // OFF => ON
                        // Camera flash will be enabled
                        _currentSensor.setFlashMode(FlashMode.torch);
                        setState((){
                          print("1");
                          flashMode ++; // 1
                          flashState = Icons.flash_on_rounded;
                        });

                      } else if (flashMode == 1){
                        // ON => AUTO
                        _currentSensor.setFlashMode(FlashMode.auto);
                        // Camera will be set into auto mode
                        setState((){
                          print("2");
                          flashMode ++; // 2
                            flashState = Icons.flash_auto_rounded;
                            });
                      } else if (flashMode == 2){
                        // AUTO => OFF
                        // Camera flash will be shutdown
                        _currentSensor.setFlashMode(FlashMode.off);
                        setState(() {
                          print("0");
                          flashMode = 0; // 0
                          flashState = Icons.flash_off_rounded;
                      });
                      }
                    }

                  },
                  label: Text(""),
                  icon: Icon(flashState, color: Colors.white, size: 25,),


                ),
              ),

              Spacer(),

              FittedBox(
                alignment: Alignment.center,
                child:  ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black
                  ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> homeMenu(esReciente : esReciente, esCategorias : esCategorias, categories : categories, currentVideos: currentVideos, currentVideosName : currentVideosName, photos: photos, )));
                      }
                    ,
                    icon: Icon(Icons.close_rounded, size: 25,),
                    label: Text("")),
              ),

              Spacer(),
              FittedBox(
                alignment: Alignment.center,
              child : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black
              ),
                onPressed: (){
                  cameraResolutionsChooser();
                  },
                icon: Icon(Icons.settings_rounded, color: Colors.white, size: 25,),
                label: Text(""))),
          ],
        ),
        backgroundColor: Colors.black,
      ),

      body: Column(
        children : [
      FutureBuilder<void>(
        future: _futureControllerCurrent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return GestureDetector(
                onTapUp: (details) {
                  _onTap(details);
                },
                child: Stack(
                    children: [
                      Center(
                              child : ClipRRect(
                                // Rounded border for camera preview
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(24),
                                  topLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                                  child : CameraPreview(_currentSensor)),
                      ),
                          // Buttons inside preview
                      if(showFocusCircle) Positioned(
                          top: y - 20,
                          left: x - 20,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.5)
                            ),
                          )),

                    ],
                  )
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
        ),

          Column(
              children: [
              Expanded(
              child: cameraNavBar(),
              )
        ]
          )
    ]
  )
    );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cameraPreview(context),
      ],
    );
  }
}


