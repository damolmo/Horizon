import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:restart_app/restart_app.dart';

/**
 * This is an open-source impl on flutter grid items selection by "daviiid99
 * If you want to use it on an open source product don't remove the credits header
 */


class selectedAppBar extends StatelessWidget{

  late int itemCount;
  late List<String> itemList;
  late String category;
  late File file;
  late Map<dynamic, dynamic> photos;

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

  removeCurrentSelection(){
    // Remove selected items
    for (String photo in itemList){
        photos[category].remove(photo);
      }

    String jsonString = "";
    jsonString = jsonEncode(photos);
    file.writeAsStringSync(jsonString);
    Restart.restartApp();
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
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}