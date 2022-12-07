import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:restart_app/restart_app.dart';
import 'package:share/share.dart';
import 'addPhotoToCategory.dart';
import 'addListToCategory.dart';
import 'categoria.dart';
/**
 * This is an open-source impl on flutter grid items selection by "daviiid99
 * If you want to use it on an open source product don't remove the credits header
 */


class selectedAppBar extends StatelessWidget{

  late AddListToCategory addToList;
  late int itemCount;
  late List<String> itemList;
  List<String> itemsPath = [];
  late String category;
  late File file;
  late Map<dynamic, dynamic> photos;
  late Map<dynamic, dynamic> trash;
  final fileTrash = File("/data/user/0/com.daviiid99.horizon/app_flutter/trash.json");
  String jsonString = "";

  selectedAppBar({
    super.key,
    required this.itemCount,
    required this.itemList,
    required this.category,
    required this.file,
    required this.photos

});

  incrementAppBar(int count){
     this.itemCount = count;
  }

  getIncrementedAppBar(){
    return this.itemCount;
  }

  userAbortSelection(){
    // User cancelled selection
    this.itemCount = 0;
  }

  listImagesPath(){
    for (String photo in photos[category].keys){
      if (itemList.contains(photo)){
        itemsPath.add(photos[category][photo]);
      }
    }
  }

  addPhotosToCategory(){
    // User can choose photos inside a category and move all of them into another category
    listImagesPath();
     addToList = AddListToCategory(categoria: category, imagesNameList: itemList, imagesNamePath: itemsPath, photos: photos);

  }

  Map <dynamic, dynamic> readTrashMap(){
    // Read map to delete files later
    jsonString = fileTrash.readAsStringSync();
    trash = jsonDecode(jsonString);

    return trash;

  }

  removeCurrentSelection(){

    // Fetch trash map
    trash = readTrashMap();

    // Get items path
    for (String photo in itemList){
      itemsPath.add(photos[category][photo]);
    }

    // Remove selected items
    for (String photo in itemList){
      int index = itemList.indexOf(photo);
      print(itemList);
      print(itemsPath);
      print(index);
      trash[photo] = [];
      trash[photo] = itemsPath[index];
      photos[category].remove(photo);
      }

    String jsonString = "";

    // Update photos map
    jsonString = jsonEncode(photos);
    file.writeAsStringSync(jsonString);

    // Update trash map
    jsonString = jsonEncode(trash);
    fileTrash.writeAsStringSync(jsonString);

    Restart.restartApp();
  }

  shareItemSelection(){

    for (String photo in photos[category].keys){
      if (itemList.contains(photo)){
        itemsPath.add(photos[category][photo]);
      }
    }

    // Allow to share selected items
    Share.shareFiles(itemsPath, text: "Hey, echale un vistazo a esta(s) foto(s) #Horizon #App");
  }
  
  AppBar appBar() {
    if (itemCount == 0) {
      return AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      );
    } else {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
        title: Row(
          children: [
            TextButton.icon(
                onPressed: () {
                 userAbortSelection();
                 appBar();
                },
                icon: Icon(Icons.close_rounded, color: Colors.white,),
                label: Text("")),
            Spacer(),
            Text(("${itemCount} Seleccionado(s)"),
              style: TextStyle(color: Colors.white),),
            Spacer(),
            TextButton.icon(
                onPressed: (){
                  // User choosed delete current photos
                  removeCurrentSelection();

                }, icon: Icon(Icons.delete_rounded, color: Colors.white,), label: Text("")),
          ],

        ),
      );
    }
  }

  Container shareSelection (BuildContext context){
    return Container(
        child :  ClipRRect(
        borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
    ),

    child: BottomNavigationBar(
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
        items: <BottomNavigationBarItem>[

          BottomNavigationBarItem(
            backgroundColor: Colors.orangeAccent,
            icon: IconButton(icon: Icon(Icons.add_rounded, color: Colors.white, size: 40,),
            onPressed: (){
              addPhotosToCategory();
              addToList.listAllCategories();
              addToList.addListToCategory(context);
            },), label: ""
          ),

          BottomNavigationBarItem(
            backgroundColor: Colors.green,
              icon: IconButton(icon :  Icon(Icons.share_rounded, color: Colors.white, size: 40,),
                onPressed: (){
                shareItemSelection();
              }, ), label: ""),
        ],
      ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}