import 'package:flutter/material.dart';
import 'dart:io';

class AboutPhoto extends StatefulWidget {
  @override
  AboutPhoto({
    super.key,
    required this.photoName,
    required this.photoPath,
    required this.fileType,
  });

  late String photoName;
  late String photoPath;
  late String fileType;

  _AboutPhotoState createState() => _AboutPhotoState(photoName: photoName, photoPath: photoPath, fileType: fileType);

}

class _AboutPhotoState extends State<AboutPhoto>{

  double photoSize = 0.0;
  String finalSize = "";
  late String photoName;
  late String fileType;
  late String photoPath;
  String defaultTitle = "Sobre esta imagen";
  List<String> allEntries = [];
  List<String> allEntriesString = ["Nombre", "Ruta", "Tamaño"];
  List<IconData> allEntriesIcons = [
    Icons.photo_rounded,
    Icons.folder_rounded,
    Icons.add_box_rounded
  ];

  _AboutPhotoState({
    required this.photoName,
    required this.photoPath,
    required this.fileType,

});

  void initState(){
    checkPhotoSize();
    addValuesToList();
    setFileTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return photoDetails(context);
  }

  checkPhotoSize() async {
    // We'll do a call to image file path to get photo size+
     final file;


    if (photoName.contains("VIDEO")){
      file = File("/data/user/0/com.daviiid99.horizon/app_flutter/" + photoName);

    } else {
       file = File(photoPath);
    }

      var sizeBytes = file
          .readAsBytesSync()
          .lengthInBytes;
      var sizeKbytes = sizeBytes / 1024;
      photoSize = sizeKbytes.roundToDouble();
      finalSize = photoSize.toString() + "KB";
      if (photoSize >= 1000) {
        var sizeMbytes = sizeKbytes / 1024;
        photoSize = sizeMbytes.roundToDouble();
        finalSize = photoSize.toString() + "MB";
    }

  }

  addValuesToList(){
    // We'll add all values to a lsit before creating listview

    allEntries.add(photoName.toString());
    allEntries.add(photoPath.toString());
    allEntries.add(finalSize.toString());
  }

  setFileTitle(){
    // Check appbar title according to file type
    setState(() {
      if (fileType.contains("photo")){
        defaultTitle = "Sobre esta imagen";
      } else {
        defaultTitle = "Sobre este video";
      }
    });

  }

  Scaffold entriesListView(){
    return Scaffold(
      backgroundColor: Colors.black,
     body: Column(
        children : [
          Text(defaultTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),),
          SizedBox(height: 20,),
          Image.file(File(photoPath), height: 200),
          SizedBox(height: 20,),
          Expanded(
         child :  ListView.builder(
              itemCount: allEntries.length,
              itemBuilder: (context, index){
                return StatefulBuilder(
                    builder: (context, setState){
                return InkWell(
                  child : Card(
                color: Colors.black,
                    child : ListTile(
                  leading: Icon(allEntriesIcons[index],color: Colors.white, size: 20,),
                  title: Text(allEntriesString[index], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
                  subtitle: Text(allEntries[index], style: TextStyle(color: Colors.white, fontSize: 20)),
                )
                ),
                      onTap : (){}
                );
              }
               );
              }
                )
          ),
          SizedBox(height: 10,),
        ]
        )
     );
  }


  Scaffold photoDetails(BuildContext context){
    // This widget will show current photo details in a listview of cards
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
             body: entriesListView(),
                );
  }

}