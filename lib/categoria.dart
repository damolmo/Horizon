import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'imagePreview.dart';
import 'selectGridItems.dart';
import 'selectedAppBar.dart';
import 'sortList.dart';

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
  late List<String> currentPhotosName;
  late List<String> currentVideos;
  late List<String> currentVideosName;
  List<String> selectedItems = [];
  List<int> indexOfSelectedCard = [];
  int itemCount = 0;
  selectGridItems selected = selectGridItems();
  selectedAppBar appBar = selectedAppBar(itemCount: 0, itemList: [], category: "", file: File(""), photos: {}, );
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  Map<dynamic, dynamic> photos = {};
  late AppBar bar;
  sortList orderList = sortList(lista: []);

  @override
  void initState(){
    setState((){
      sortLists();
      readUpdateJsonMap();
      bar = appBar.appBar();
    });

    super.initState();
}

  @override
  void dispose(){
    super.dispose();
  }

  void sortLists(){
    // Sort lists on desceding order to show more recent photos on top

    setState((){
      // Photos
      orderList = sortList(lista: currentPhotos);
      orderList.sortListDescending();
      currentPhotos = orderList.getList();

      // Photos name
      orderList = sortList(lista: currentPhotosName);
      orderList.sortListDescending();
      currentPhotosName = orderList.getList();

      // Videos
      orderList = sortList(lista: currentVideos);
      orderList.sortListDescending();
      currentVideos = orderList.getList();

      // Video name
      orderList = sortList(lista: currentVideosName);
      orderList.sortListDescending();
      currentVideosName = orderList.getList();
    });
  }

  void readUpdateJsonMap () {
    // Read Json file and update map
    String jsonString = file.readAsStringSync();
    photos = jsonDecode(jsonString);
  }

  void updateAppBar(int index) async {
    setState(() {
      selected.addGridItems(currentPhotosName[index]); // Add latest selected elements to list
      itemCount = selected.getGridItems(); // Get size of selected items list
      selectedItems = selected.getGridArray(); // Get elements selected atm
      appBar.incrementAppBar(itemCount); // Increase the appbar counter with current itemcount
      appBar = selectedAppBar(itemCount: itemCount, itemList: selectedItems, category: currentCategory, file: file, photos: photos, ); // Pass current list to appbar
      bar = appBar.appBar(); // Update AppBar widget
    });
  }

  void updateSelectedCards(int index){
    setState(() {
      if (!indexOfSelectedCard.contains(index)){
        indexOfSelectedCard.add(index);
      } else {
        indexOfSelectedCard.remove(index);
      }
    });
  }

@override
  Widget build(BuildContext context){
  return StatefulBuilder(builder: (context, setState)
  {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: bar,
      body: Column(
        children: [
          Text(currentCategory, style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30),),
          SizedBox(height: 20,),
          Align(
            alignment: Alignment.center,
            child: Text("Imágenes : ${currentPhotos.length}",
              style: TextStyle(color: Colors.white),),),
          SizedBox(height: 20,),
          Expanded(
              child: GridView.count(
                  childAspectRatio: 2.3 / 3,
                  crossAxisCount: 3,
                  children: List.generate(currentPhotos.length, (index) {
                    return StatefulBuilder(
                        builder: (context, setState) {
                          return SizedBox(
                              width: 200,
                              height: 200,
                              child: Column(
                                  children: [
                                    InkWell(
                                      child: Card(
                                          child: Image.file(

                                              File(currentPhotos[index]),
                                          color: indexOfSelectedCard.contains(index) ? Colors.lightBlueAccent.withOpacity(1.0) : null  ,)),

                                      onTap: () {

                                       if (indexOfSelectedCard.isNotEmpty){
                                         updateSelectedCards(index);
                                         updateAppBar(index);
                                        } else {
                                          Navigator.push(context,
                                          MaterialPageRoute(
                                          builder: (context) =>
                                          imagePreview(
                                          imageName: currentPhotosName[index],
                                          image: currentPhotos[index],
                                          currentVideos: currentVideos,
                                          currentVideosName: currentVideosName,
                                          currentCategory: currentCategory,)));
                                          }
                                       },

                                      onLongPress: () {
                                        // If user long press the card, add the item into the list
                                        setState(() async {
                                          updateSelectedCards(index);
                                          updateAppBar(index);

                                        });
                                      },

                                    ),
                                  ]
                              ));
                        });
                  }))
          ),

          if (selectedItems.length >= 1)
            appBar.shareSelection(context),
        ],
      ),
    );
  }
  );
  }
}