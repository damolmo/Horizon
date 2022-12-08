import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:restart_app/restart_app.dart';
import 'videoPreview.dart';
import 'addPhotoToCategory.dart';
import 'aboutPhoto.dart';

class imagePreview extends StatefulWidget{
  @override

  imagePreview({
    super.key,
    this.image,
    this.imageName,
    required this.currentVideos,
    required this.currentVideosName,
    required this.currentCategory,
});

  final image;
  final currentCategory;
  final imageName;
  final List<String> currentVideos;
  final List<String> currentVideosName;

  _imagePreviewState createState() => _imagePreviewState(image : image, imageName : imageName, currentVideos: currentVideos, currentVideosName: currentVideosName, currentCategory: currentCategory);
}

class _imagePreviewState extends State<imagePreview>{

  _imagePreviewState({
    this.image,
    this.imageName,
    required this.currentVideos,
    required this.currentVideosName,
    required this.currentCategory,

});
  
  void initState(){
    addPhoto = AddPhotoToCategory(categoria: currentCategory, imageName: imageName, imagePath: image, photos: photos,);
    about = AboutPhoto(photoName: imageName, photoPath: image, fileType: "photo",);
    print("videos ${currentVideos}");
    super.initState();
  }

  void deletePhoto() async {
    // Read hashmap file
    jsonString = file.readAsStringSync();

    // Write hashmap
    photos = jsonDecode(jsonString);

    // Delete photo from hashmap
    if (photos[currentCategory].containsKey(imageName)){
      photos[currentCategory].remove(imageName);
    }

    // Add photo to trash folder
    jsonString = fileTrash.readAsStringSync();
    trash = jsonDecode(jsonString);
    trash[imageName] = "";
    trash[imageName] = image;
    jsonString = jsonEncode(trash);
    fileTrash.writeAsStringSync(jsonString);

    // Save hashmap
    jsonString = jsonEncode(photos);

    // Save file
    file.writeAsStringSync(jsonString);

  }

  void navigateToAboutPage(){
    if (imageName.contains("VIDEO")){
      for (String video in currentVideos){
        if (video.contains(imageName)){
          videoPath = video;
        }
      }
      about = AboutPhoto(photoName: imageName + ".mp4", photoPath: image, fileType: "video",);
      Navigator.push(context, MaterialPageRoute(builder: (context) => about));

    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => about));

    }
  }

  Container bottomNavigationBar(BuildContext context)  {
    return Container(
      child : ClipRRect(
        borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        topLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        ),
      child : BottomNavigationBar(
          backgroundColor: Colors.blueAccent.withOpacity(0.5),
          items: <BottomNavigationBarItem> [
            BottomNavigationBarItem(
                backgroundColor: Colors.transparent,
                icon: TextButton.icon(
                  icon : Icon(Icons.share_rounded, color: Colors.white, size: 40,),
                  onPressed: (){
                    if (imageName.contains("VIDEO")){
                      print(imageName);
                      String fullName = "/data/user/0/com.daviiid99.horizon/app_flutter/" + imageName + ".mp4";
                      int index = currentVideos.indexOf(fullName);
                      Share.shareFiles([currentVideos[index]], text: "Hey, echale un vistazo a este video");
                    } else {
                    Share.shareFiles([image], text: "Hey, echale un vistazo a esta foto");
                  }
                    },
                label: Text("")
                ),
                label: ""
            ),

            BottomNavigationBarItem(
              backgroundColor: Colors.transparent,
                icon: IconButton(icon: Icon(Icons.add_rounded, color: Colors.white, size: 40, ),
                onPressed: () async {
                  await addPhoto.listAllCategories();
                  addPhoto.addImageToCategory(context);
                }), label: ""),

            BottomNavigationBarItem(
                backgroundColor: Colors.transparent,
                icon: TextButton.icon(
                  icon : Icon(Icons.delete_rounded, color: Colors.white, size: 40,),
                  onPressed: (){
                    // User proceed with photo delete
                    deletePhoto();
                    Navigator.pop(context); // return to previous screen instead of restart the whole app

                  }, label:  Text(""),),label: "")


          ])),
    );
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

  bool visibility = true;
  late AboutPhoto about;
  late AddPhotoToCategory addPhoto;
  final List<String> currentVideos;
  final List<String> currentVideosName;
  late List<String> availableCategories;
  final currentCategory;
  final image;
  final imageName;
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  final fileTrash = File("/data/user/0/com.daviiid99.horizon/app_flutter/trash.json");
  Map <dynamic, dynamic> photos = {};
  Map <dynamic, dynamic> trash = {};
  late String jsonString;
  String videoPath  = "";

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (visibility)
            ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.withOpacity(0.2)
        ),
        onPressed: (){
          navigateToAboutPage();
        },
            child : FittedBox(
          child : Row(
            children : [
          Text(imageName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
          TextButton.icon(onPressed: (){
              // Generate current photo stats
            navigateToAboutPage();
            }, icon: Icon(Icons.info_outline_rounded, color: Colors.white, size: 20,), label: Text("")),
        ]
      )
            )
            )
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 50,),
          Expanded(
          child : Column(
          children : [

            InkWell(
          onTap: (){
            videoNavBarVisibility();
    },
            child : imageName.contains("VIDEO") ? tapToVideo() : Image.file(File(image))
            )
        ]
          )
    ),
            SizedBox(height: 50,),
            if(visibility)
            bottomNavigationBar(context)
              ]
          )
    );
  }

  Container tapToVideo(){
    return Container(
    child: Stack(
        children : [
          Center(
                    child : Image.file(File(image))),
                Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Center(
                     heightFactor: 2.5,
                 child : TextButton.icon(
                   onPressed: (){
                   for (String video in currentVideos){
                     if (video.contains(imageName)){
                       videoPath = video;
                     }
                   }
                   Navigator.push(context, MaterialPageRoute(builder: (context) => videoPreview(videoPath : videoPath, videoName : imageName+".mp4")));
                   },  icon: Icon(Icons.play_arrow_rounded, size: 100, color: Colors.white,), label: Text(""),)),
          ]
          )
    ]
    )
    );
  }

}