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
    about = AboutPhoto(photoName: imageName, photoPath: image);
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

    // Save hashmap
    jsonString = jsonEncode(photos);

    // Save file
    file.writeAsStringSync(jsonString);

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
                    Share.shareFiles([image], text: "Hey, echale un vistazo a esta foto");
                  }, label: Text(""),),
                label: ""),

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
                    Restart.restartApp();

                  }, label:  Text(""),),label: "")


          ])),
    );
  }

  late AboutPhoto about;
  late AddPhotoToCategory addPhoto;
  final List<String> currentVideos;
  final List<String> currentVideosName;
  late List<String> availableCategories;
  final currentCategory;
  final image;
  final imageName;
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  Map <dynamic, dynamic> photos = {};
  late String jsonString;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.withOpacity(0.2)
        ),
        onPressed: (){},
            child : FittedBox(
          child : Row(
            children : [
          Text(imageName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),),
          TextButton.icon(onPressed: (){
              // Generate current photo stats
              Navigator.push(context, MaterialPageRoute(builder: (context) => about));
            }, icon: Icon(Icons.info_outline_rounded, color: Colors.white, size: 30,), label: Text("")),
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
              if(imageName.contains("VIDEO")){
                // It's a video file
                int index = currentVideosName.indexOf(imageName + ".mp4");
                final videoPath = currentVideos[index];
                print(videoPath);
                Navigator.push(context, MaterialPageRoute(builder: (context) => videoPreview(videoPath : videoPath)));
              }
            },
          child : Image.file(File(image))

          )
        ]
          )
    ),
            SizedBox(height: 50,),
            bottomNavigationBar(context)
              ]
          )
    );
  }
}