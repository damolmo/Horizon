import 'package:flutter/material.dart';
import 'dart:io';

class AboutPhoto extends StatefulWidget {
  @override
  AboutPhoto({
    super.key,
    required this.photoName,
    required this.photoPath,
  });

  late String photoName;
  late String photoPath;

  _AboutPhotoState createState() => _AboutPhotoState(photoName: photoName, photoPath: photoPath);

}

class _AboutPhotoState extends State<AboutPhoto>{

  double photoSize = 0.0;
  late String photoName;
  late String photoPath;
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

});

  void initState(){
    checkPhotoSize();
    addValuesToList();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return photoDetails(context);
  }

  checkPhotoSize() async {
    // We'll do a call to image file path to get photo size
    final file = File(photoPath);
    var sizeBytes = file.readAsBytesSync().lengthInBytes;
    var sizeKbytes = sizeBytes / 1024;
    var sizeMb = sizeKbytes / 1024;
    photoSize =  sizeMb.roundToDouble();

  }

  addValuesToList(){
    // We'll add all values to a lsit before creating listview

    allEntries.add(photoName.toString());
    allEntries.add(photoPath.toString());
    allEntries.add(photoSize.toString()+"MB");
  }

  Scaffold entriesListView(){
    return Scaffold(
      backgroundColor: Colors.black,
     body: Column(
        children : [
          Text("Sobre esta imagen", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),),
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
                  leading: Icon(allEntriesIcons[index]),
                  title: Text(allEntriesString[index], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
                  subtitle: Text(allEntries[index], style: TextStyle(color: Colors.white, fontSize: 20)),
                )
                )
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