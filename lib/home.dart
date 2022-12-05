import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'categoria.dart';
import 'imagePreview.dart';
import 'package:restart_app/restart_app.dart';
import 'sortList.dart';

class homeMenu extends StatefulWidget{
  @override

  homeMenu({
    super.key,
     required this.esReciente,
     required this.esCategorias,
     required this.categories,
    required this.currentVideos,
    required this.currentVideosName,
    required this.photos,
});

   final bool esReciente;
   final bool esCategorias;
   final List<String> categories;
   final List<String> currentVideos;
   final List<String> currentVideosName;
   Map<dynamic,dynamic> photos;

  _homeMenuState createState() => _homeMenuState(esReciente : esReciente, esCategorias : esCategorias, categories : categories, currentVideos: currentVideos, currentVideosName: currentVideosName, photos: photos);
}

class _homeMenuState extends State<homeMenu>{

  _homeMenuState({
    required this.esReciente,
    required this.esCategorias,
    required this.categories,
    required this.currentVideos,
    required this.currentVideosName,
    required this.photos,
});

  late bool esReciente;
  late bool esCategorias;
  late List<String> categories;
  List<String> currentPhotos = [];
  List<String> currentRecentsPhotos = [];
  List<String> currentRecentsPhotosName = [];
  List<String> currentPhotosName = [];
  final List<String> currentVideos;
  final List<String> currentVideosName;
   List<String> categoriesCover = [];
  Map<dynamic,dynamic> photos;
  Color recentsButton = Colors.lightBlueAccent;
  Color categoriesButton = Colors.blueAccent;
  TextEditingController categoria = TextEditingController();
  sortList orderList = sortList(lista: []);

  @override
  void initState(){
    generateRecentsPhotos();
    generateCategoriesCover();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  void generateCategoriesCover() async {
    // We'll generate a cover for each existing category in user app
    // Last element of every category will be used as cover

    List<String> tempList = []; // Used to place cover temporarily

    for (String category in photos.keys){
      for (String photo in photos[category].keys){
        int index = photos[category].keys.length;
        tempList.add(photos[category][photo]);

        if (tempList.length == index){
          // Full Current category is added on templist
          if (index > 1){
            if (!categoriesCover.contains(tempList[index - 1])){
              categoriesCover.add(tempList[index - 1]);
          }
            // empty values for next iteration
            index = 0;
            tempList = [];
          } else if (index == 1) {
            print(tempList);
            categoriesCover.add(tempList[0]);
            index = 0;
            tempList = [];

          }
        }

      }
    }

    setState(() {
      categoriesCover;
    });


  }

  void generateCategoryPhotos(String categoria) async {
    // Generate choosed category photos before attempting to open category view
    setState(() {
      // Clear lists
      currentPhotos = [];
      currentPhotosName = [];
    });

    for (String photo in photos[categoria].keys){
      if (!currentPhotosName.contains(photo) && photos[categoria].keys.length > 0){
        currentPhotosName.add(photo); // name
        currentPhotos.add(photos[categoria][photo]); // path
      }
    }

    setState(() {
      currentPhotos;
      currentPhotosName;
    });
  }

  void generateRecentsPhotos() async {
    // Recents works as independent category

    for (String photo in photos["Reciente"].keys) {
      setState(() {
        currentRecentsPhotos.add(photos["Reciente"][photo]);
        currentRecentsPhotosName.add(photo);
      });
    }

    // Sort recents photos list in descending order
    orderList = sortList(lista: currentRecentsPhotos);
    orderList.sortListDescending();
    currentRecentsPhotos = orderList.getList();

    // Sort recents photos name in descending order
    orderList = sortList(lista: currentRecentsPhotosName);
    orderList.sortListDescending();
    currentRecentsPhotosName = orderList.getList();
  }

  @override
  Widget build(BuildContext context){
    return StatefulBuilder(builder: (context, setState)
    {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          title: Text(""),
          backgroundColor: Colors.black,
        ),

        body: Column(
            children: [
              Image.asset("assets/icon/banner.png",),
                SizedBox(height: 20,),
                Row(
                  children: [

                Expanded(
                    child : ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                            child :  ColoredBox(
                        color: recentsButton,
                    child : TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: recentsButton
                        ),
                        onPressed: () {
                          // User choosed recents photos
                          setState(() {
                            esCategorias = false;
                            esReciente = true;
                            recentsButton = Colors.lightBlueAccent;
                            categoriesButton = Colors.blueAccent;
                          });
                        },
                        child: Text("Reciente", style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),))))),

                    SizedBox(width: 10,),

                    Expanded(
                      child :ClipRRect(
                      borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                      ),
                      child: ColoredBox(
                      color: categoriesButton,
                    child : TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: categoriesButton
                        ),
                        onPressed: () {
                          setState(() {
                            esReciente = false;
                            esCategorias = true;
                            recentsButton = Colors.blueAccent;
                            categoriesButton = Colors.lightBlueAccent;
                          });
                        },
                        child: Text("Categorías", style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),))))),
                  ],
                ),

              SizedBox(height: 20,),

              if (esReciente)
                Expanded(
                    child: GridView.count(
                        childAspectRatio: 2.3/3,
                        crossAxisCount: 3,
                        scrollDirection: Axis.vertical,
                      children: List.generate(currentRecentsPhotos.length, (index){
                        return StatefulBuilder(
                            builder: (context, setState) {
                              return SizedBox(
                                width: 200,
                                  height: 200,
                                  child: Column(
                                    children: [
                                      InkWell(
                                      child : Card(
                                        color: Colors.grey,
                                                child: Image.file(File(
                                                    currentRecentsPhotos[index]),)
                                      ),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> imagePreview(image : currentRecentsPhotos[index], imageName : currentRecentsPhotosName[index], currentVideos : currentVideos, currentVideosName : currentVideosName, currentCategory: "Reciente",)));
                                      },
                                  ),
                              ]
                              )
                              );
                            },
                                  );
                            }
                        )
                      )
                        ),

              if (esCategorias)
                Expanded(
                    child: GridView.count(
                        childAspectRatio: 2.7/3,
                      crossAxisCount: 2,
                        scrollDirection: Axis.vertical,
                        children: List.generate(categories.length, (index){
                          return StatefulBuilder(
                              builder: (context, setState) {
                                return FittedBox(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          child :  ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(24),
                                            topLeft: Radius.circular(24),
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(24),
                                      ),
                                        child : Card(
                                          shape: CircleBorder(),
                                          color : Colors.black,
                                          child : Column(
                                            children: [
                                              Image.file(File(categoriesCover[index]), scale: 2.0,),
                                               Text(categories[index], style: TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                               )
                                               ]
                                            )
                                          ),
                                          ),
                                          onTap: (){
                                            generateCategoryPhotos(categories[index]);
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Categoria(currentPhotos : currentPhotos, currentPhotosName : currentPhotosName, currentVideos: currentVideos, currentVideosName: currentVideosName, currentCategory: categories[index],)));
                                        },
                                    ),
                                    ]
                                  ),

                                );
                                }
                                );
                              }
                          )
                          )
                ),


              if (esReciente)
              CameraButton(context),

              if (esCategorias)
                CategoryButton(context)
            ]

        ),



      );
    }
    );
  }
}

Container CategoryButton (BuildContext context){
  return Container(
    color: Colors.transparent,
    child :  ClipRRect(
      borderRadius: const BorderRadius.only(
      topRight: Radius.circular(24),
      topLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
  ),

  child: BottomNavigationBar(
      backgroundColor: Colors.orangeAccent ,
      items: <BottomNavigationBarItem> [
        BottomNavigationBarItem(
          backgroundColor: Colors.greenAccent,
            icon: TextButton.icon(
              icon : Icon(
              Icons.add_rounded,
              color: Colors.white,),
                onPressed: () {
                  createCategoryDialog(context);
                },
                label: Text(""),),
          label: ""
        )
      ],
    ),
    )
  );
}

createCategoryDialog(BuildContext context) async {

  TextEditingController categoria = TextEditingController();
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  Map<dynamic, dynamic> photos= {};
  String jsonString;

  addCategoryToMap(String categoria) async {
    // First, load the file
    if (await file.exists()){
      jsonString = file.readAsStringSync();
      photos = jsonDecode(jsonString);
    }

    // Add new category to map
    photos[categoria] = {};

    // Overwrite file
    jsonString = jsonEncode(photos);
    file.writeAsStringSync(jsonString);

    // Reload app to show new category
    Restart.restartApp();
  }


  showDialog(
      context: context, builder: (context){
    return StatefulBuilder(
        builder: (context, setState){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            backgroundColor: Colors.transparent,
            content: SizedBox(
                child:  Column(
                children: [
                  SizedBox(height: 100,),
                  Align(
                    alignment: Alignment.center,
                  child : Text("Crear Categoría", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),)),
                  SizedBox(height: 50,),
                  Container(
                    color: Colors.white,
                  child : TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "Escribe un nombre", hintStyle: TextStyle(color: Colors.black, fontSize: 25), alignLabelWithHint: true,
                    ),
                    controller: categoria,
                  )),
                  SizedBox(height: 50,),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orangeAccent
                    ),
                      onPressed: (){
                      addCategoryToMap(categoria.text);
                      }, child: Text("Añadir", style: TextStyle(color: Colors.white, fontSize: 20),))
                ],

              )
            ),
          );
        }

    );
  }
  );
}

Container CameraButton(BuildContext context) {

  // This is the home screen button
  // Pressing the button will open the camera preview context
  return Container(
    color: Colors.transparent,
    child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),

        child:  BottomNavigationBar(
            backgroundColor: Colors.blueAccent,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                backgroundColor: Colors.blueAccent,
                icon: TextButton.icon(icon :  Icon(Icons.photo_camera_rounded, color: Colors.white), label: Text(""),
                  onPressed: (){
                    Navigator.pop(context);
                  },),
                label: "",
              )
            ]
        )
    ),
  );
}