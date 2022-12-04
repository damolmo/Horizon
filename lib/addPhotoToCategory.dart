import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:restart_app/restart_app.dart';

class AddPhotoToCategory extends StatelessWidget{

  AddPhotoToCategory({
    super.key,
    required this.categoria,
    required this.imageName,
    required this.imagePath,
    required this.photos,

});

  late List<String> availableCategories;
  late String jsonString;
  late Map<dynamic, dynamic> photos;
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  late String categoria;
  late String imageName;
  late String imagePath;

listAllCategories() async {
  // Fetch existing categories
  availableCategories = [];

  // Read file
  jsonString = file.readAsStringSync();
  photos = jsonDecode(jsonString);

  for (String category in photos.keys){
      availableCategories.add(category);
  }
}

addImageToCategory(BuildContext context) async {
  // We'll display a dialog to choose a category or multiple categories to save the current photo

  addToCategory(String categoria) async {
    photos[categoria][imageName] = imagePath;
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
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}



