import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'imagePreview.dart';

class Categoria extends StatefulWidget{
  @override
  Categoria({
    super.key,
    required this.currentPhotos,
    required this.currentPhotosName,
    required this.currentVideos,
    required this.currentVideosName,
    required this.currentCategory,
});
  final currentCategory;
  final List<String> currentPhotos;
  final List<String> currentPhotosName;
  final List<String> currentVideos;
  final List<String> currentVideosName;

    _CategoriaState createState() => _CategoriaState(currentPhotos: currentPhotos, currentPhotosName: currentPhotosName, currentVideosName : currentVideosName, currentVideos : currentVideos, currentCategory: currentCategory);
}


class _CategoriaState extends State<Categoria>{

  _CategoriaState({
    required this.currentPhotos,
    required this.currentPhotosName,
    required this.currentVideos,
    required this.currentVideosName,
    required this.currentCategory,

  });

  final currentCategory;
  late List<String> currentPhotos;
  final List<String> currentPhotosName;
  final List<String> currentVideos;
  final List<String> currentVideosName;

void initState(){
  print(currentPhotos);
  super.initState();
}

@override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Text("Categoria", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
          SizedBox(height: 20,),
          Align(
            alignment : Alignment.center,
          child : Text("Imágenes : ${currentPhotos.length}", style: TextStyle(color: Colors.white),),),
          SizedBox(height: 20,),
          Expanded(
          child : GridView.count(
              childAspectRatio: 2.3/3,
            crossAxisCount: 3,
              children: List.generate(currentPhotos.length, (index){
                return StatefulBuilder(
                    builder: (context, setState){
                      return SizedBox(
                      width: 200,
                      height: 200,
                        child: Column(
                          children : [
                            InkWell(
                            child : Card(
                            child : Image.file(File(currentPhotos[index]))),

                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => imagePreview(imageName: currentPhotosName[index], image: currentPhotos[index], currentVideos: currentVideos, currentVideosName: currentVideosName, currentCategory: currentCategory,)));
                              }
                    ),
                ]
                      ));
                });
              })))
        ],
      ),
    );
  }
}