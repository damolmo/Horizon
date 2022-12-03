import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:restart_app/restart_app.dart';
import 'videoPreview.dart';

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
      child : BottomNavigationBar(
          backgroundColor: Colors.black,
          items: <BottomNavigationBarItem> [
            BottomNavigationBarItem(
                backgroundColor: Colors.black,
                icon: TextButton.icon(
                  icon : Icon(Icons.share_rounded, color: Colors.greenAccent, size: 40,),
                  onPressed: (){
                    Share.shareFiles([image], text: "Hey, echale un vistazo a esta foto");
                  }, label: Text(""),),
                label: ""),

            BottomNavigationBarItem(
              backgroundColor: Colors.black,
                icon: IconButton(icon: Icon(Icons.add_rounded, color: Colors.orangeAccent, size: 40, ),
                onPressed: () async {
                  await listAllCategories();
                  addImageToCategory();
                }), label: ""),

            BottomNavigationBarItem(
                backgroundColor: Colors.black,
                icon: TextButton.icon(
                  icon : Icon(Icons.delete_rounded, color: Colors.redAccent, size: 40,),
                  onPressed: (){
                    // User proceed with photo delete
                    deletePhoto();
                    Restart.restartApp();

                  }, label:  Text(""),),label: "")


          ]),
    );
  }

  final List<String> currentVideos;
  final List<String> currentVideosName;
  late List<String> availableCategories;
  final currentCategory;
  final image;
  final imageName;
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  Map <dynamic, dynamic> photos = {};
  late String jsonString;

   listAllCategories() async {
    // Fetch existing categories

     availableCategories = [];

    // Read file
    jsonString = file.readAsStringSync();
    photos = jsonDecode(jsonString);

    for (String category in photos.keys){
      setState(() {
        availableCategories.add(category);
      });
    }
  }

   addImageToCategory() async {
    // We'll display a dialog to choose a category or multiple categories to save the current photo

     addToCategory(String categoria) async {
       photos[categoria][imageName] = image;
       jsonString = jsonEncode(photos);
       file.writeAsStringSync(jsonString);
     }

     SizedBox(height: 120);

    showDialog(
        context: context, builder: (context){
          return StatefulBuilder(
              builder: (context, setState){
                return Container(
                    color: Colors.transparent ,
                    width: 300,
                    height: 200,
                    child : AlertDialog(
                  backgroundColor: Colors.transparent,
                  content: ListView.builder(
                      itemCount: availableCategories.length,
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            addToCategory(availableCategories[index]);
                            Restart.restartApp();
                          },
                            child : ListTile(
                          title:
                          Align(
                          alignment : Alignment.center,
                          child : ColoredBox(
                        color: Colors.transparent,
                        child : Text(availableCategories[index], style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),)))),
                        );
                }
                )
                )
                );
              }
          );
      }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
          child : Column(
          children : [
            Align(
              alignment : Alignment.center,
          child : Text(imageName, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),)),
          SizedBox(height: 50,),

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