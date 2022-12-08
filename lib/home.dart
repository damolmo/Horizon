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
     required this.esPapelera,
     required this.categories,
    required this.currentVideos,
    required this.currentVideosName,
    required this.photos,
    required this.trashPhotos,
    required this.trashPhotosName,
});

   final bool esReciente;
   final bool esCategorias;
   final bool esPapelera;
   final List<String> categories;
   final List<String> currentVideos;
   final List<String> currentVideosName;
   late List<String> trashPhotos;
   late List<String> trashPhotosName;
   Map<dynamic,dynamic> photos;

  _homeMenuState createState() => _homeMenuState(esReciente : esReciente, esCategorias : esCategorias, categories : categories, currentVideos: currentVideos, currentVideosName: currentVideosName, photos: photos, trashPhotos : trashPhotos, trashPhotosName : trashPhotosName, esPapelera: esPapelera);
}

class _homeMenuState extends State<homeMenu>{

  _homeMenuState({
    required this.esReciente,
    required this.esCategorias,
    required this.esPapelera,
    required this.categories,
    required this.currentVideos,
    required this.currentVideosName,
    required this.photos,
    required this.trashPhotos,
    required this.trashPhotosName,
});

  late bool esReciente;
  late bool esCategorias;
  late bool esPapelera;
  late List<String> categories;
  List<String> currentPhotos = [];
  List<String> currentRecentsPhotos = [];
  List<String> currentRecentsPhotosName = [];
  List<String> currentPhotosName = [];
  List<String> selectedCategories = [];
  List<int> selectedCategoriesIndex = [];
  final List<String> currentVideos;
  final List<String> currentVideosName;
  late List<String> trashPhotos = [];
  late List<String> trashPhotosName = [];
  List<String> selectedTrashPhotos = [];
  List<String> selectedTrashPhotosName = [];
  List<int> selectedTrashPhotosIndex = [];
  List<int> selectedRecentsPhotosIndex = [];
  List<String> selectedRecentsPhotosName = [];
  List<String> selectedRecentsPhotos = [];
  List<String> categoriesCover = [];
  Map<dynamic,dynamic> photos;
  Map<dynamic,dynamic> trash = {};
  Color recentsButton = Colors.lightBlueAccent;
  Color categoriesButton = Colors.blueAccent;
  Color trashButton = Colors.blueAccent;
  TextEditingController categoria = TextEditingController();
  sortList orderList = sortList(lista: []);
  final file = File("/data/user/0/com.daviiid99.horizon/app_flutter/photos.json");
  final fileTrash = File("/data/user/0/com.daviiid99.horizon/app_flutter/trash.json");

  late AppBar appBar;

  @override
  void initState(){
    generateRecentsPhotos();
    generateCategoriesCover();
    setState(() {
      appBar = currentAppBar(context);
    });
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

    // Read JSON before reloading anything
    String jsonString = file.readAsStringSync();
    photos = jsonDecode(jsonString);

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

  void addCategoryToList(String category){
    // Add category to selected category list
    setState(() {
      if (!selectedCategories.contains(category)){
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });
  }

  void generateTrashPhotos(){
    // This will refresh current trash without hacks

    setState(() {
      trashPhotos = [];
      trashPhotosName = [];
    });

    // Read trash hasmap with latest results
    String jsonString = fileTrash.readAsStringSync();
    trash = jsonDecode(jsonString);

    // Update lists with latest photos
    for (String photo in trash.keys){
      if (!trashPhotosName.contains(photo)){
        setState(() {
          trashPhotosName.add(photo);
          trashPhotos.add(trash[photo]);
        });
      }
    }
  }

  void refreshLists(){
    // Since user wants to delete photos without reboots
    // A proper way to refresh UI is needed

    // Clear ALL UI elements
    // To prevent future errors

    setState(() {
      currentRecentsPhotosName = [];
      currentRecentsPhotos = [];
      currentPhotos = [];
      categoriesCover =  [];
    });

    generateRecentsPhotos(); // Generate recents photos
    generateCategoriesCover(); // Generate categories covers
    generateTrashPhotos(); // Refresh trash photos on need
  }

  void selectedIndex(int indexCategory){
    // Add index of selected categories
    setState(() {
      if (!selectedCategoriesIndex.contains(indexCategory)){
        selectedCategoriesIndex.add(indexCategory);
      } else {
        selectedCategoriesIndex.remove(indexCategory);
      }
    });
  }

  void removeSelectedCategories(){
    // User choosed to remove selected categories

    for (String categoria in selectedCategories){
        photos.remove(categoria);
        categories.remove(categoria);
      }

    String jsonString = jsonEncode(photos);
    file.writeAsStringSync(jsonString);


    setState(() {
      // Needed to notify other widgets about changes
      photos;
      selectedCategories = [];
      selectedCategoriesIndex = [];
      categories;
    });
  }

  setSelectedRecentsIndex(int index){
    // User will choose multiple photos, we need an index of them
    setState(() {
      if (!selectedRecentsPhotosIndex.contains(index)){
        selectedRecentsPhotosIndex.add(index);
    } else {
      selectedRecentsPhotosIndex.remove(index);
    }
    });
  }

  setSelectedRecentsPhotos(String photoPath, String photoName){
    // User will choose multiple photos, we'll add them to lists
    setState(() {
      if (!selectedRecentsPhotosName.contains(photoName) && !selectedRecentsPhotos.contains(photoPath)){
        selectedRecentsPhotosName.add(photoName);
        selectedRecentsPhotos.add(photoPath);
      } else {
        selectedRecentsPhotosName.remove(photoName);
        selectedRecentsPhotos.remove(photoPath);
      }
    });

    print(selectedRecentsPhotos);
    print(selectedRecentsPhotosName);
  }

  void removeSelectedRecents(){
    // User choosed to remove selected recents

    // Read trash HashMap
    String jsonString = fileTrash.readAsStringSync();
    trash = jsonDecode(jsonString);

    // Read photos HashMap
    jsonString = file.readAsStringSync();
    photos = jsonDecode(jsonString);

    print(selectedRecentsPhotos);
    print(selectedRecentsPhotosName);

    for (String photoPath in selectedRecentsPhotos){
      for (String photoName in selectedRecentsPhotosName){
        if (selectedRecentsPhotos.indexOf(photoPath) == selectedRecentsPhotosName.indexOf(photoName)){
          trash[photoName] = ""; // initialize
          trash[photoName] = photoPath; // Add new entry
          if (photos["Reciente"].containsKey(photoName)) photos["Reciente"].remove(photoName);
        }
      }
    }

    // Encode maps
    jsonString = jsonEncode(trash);
    fileTrash.writeAsStringSync(jsonString);

    jsonString = jsonEncode(photos);
    file.writeAsStringSync(jsonString);

    setState(() {
      selectedRecentsPhotosName = [];
      selectedRecentsPhotos = [];
      selectedRecentsPhotosIndex = [];
      refreshLists();
      appBar = setRecentsAppBar(context);
    });
  }

  chooseAppBar(int index, String photoPath, String photoName){
      setSelectedRecentsIndex(index);
      setSelectedRecentsPhotos(photoPath, photoName);

      setState((){
        appBar = setRecentsAppBar(context);
      });
  }

  AppBar setRecentsAppBar(BuildContext context){
    // User will be able to choosed multiple photos from home screen and remove or share them if needed
    if (selectedRecentsPhotosIndex.length == 0){
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
                onPressed: (){
                  // User cleaned all photos from selection
                  setState(() {
                    selectedRecentsPhotosIndex = [];
                    selectedRecentsPhotosName = [];
                    selectedRecentsPhotos = [];
                    appBar = setRecentsAppBar(context);
                  });
                },
                icon: Icon(Icons.close_rounded, color: Colors.white,), label: Text("")),
            Spacer(),
            Text("${selectedRecentsPhotosIndex.length} seleccionado(s)", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
            Spacer(),
            TextButton.icon(
                onPressed: (){
                  // Remove selected photos
                  removeSelectedRecents();
                },
                icon: Icon(Icons.delete_rounded, color: Colors.white,),
                label: Text(""))
          ],
        ),
      );
    }
  }

  setCategoryAppBar(int index){
    // Check appbar type and set
    setState(() {
      addCategoryToList(categories[index]); // Add element
      selectedIndex(index); // Add index
      appBar = currentAppBar(context);
    });
  }


  AppBar currentAppBar(BuildContext context){
    // Set AppBar depending if there's a selected item or not
      if (selectedCategoriesIndex.length == 0){
        // Default navbar
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          title: Text(""),
          backgroundColor: Colors.black,
        );
      } else {
        return AppBar(
          backgroundColor : Colors.blueAccent.withOpacity(0.5),
          automaticallyImplyLeading: false,
          elevation: 0.0,
          title: Row(
            children: [
              TextButton.icon(
                  onPressed: (){
                    setState(() {
                      selectedCategoriesIndex = [];
                      selectedCategories = [];
                      appBar = currentAppBar(context);
                    });
                  },
                  icon: Icon(Icons.close_rounded, color: Colors.white,), label: Text("")),
                  Spacer(),
                  Text("${selectedCategoriesIndex.length} seleccionado(s)", style: TextStyle(color: Colors.white),),
                  Spacer(),
                  TextButton.icon(
                      onPressed: (){
                        setState(() {
                          removeSelectedCategories();
                          appBar = currentAppBar(context);
                          refreshLists();
                        });
                      },
                      icon: Icon(Icons.delete_rounded, color: Colors.white,), label: Text(""))
            ],
          ),
        );
      }
  }

  void swapColors(){
    // Check current color and swap it

    setState(() {

    if (esReciente){
      // Current choosed button is Recents
      recentsButton = Colors.lightBlueAccent;
      categoriesButton = Colors.blueAccent;
      trashButton = Colors.blueAccent;
    } else if (esCategorias){
      // Current choosed buttons is Categories
      recentsButton = Colors.blueAccent;
      categoriesButton = Colors.lightBlueAccent;
      trashButton = Colors.blueAccent;
    } else {
      // Current choosed button is Trash
      recentsButton = Colors.blueAccent;
      categoriesButton = Colors.blueAccent;
      trashButton = Colors.lightBlueAccent;
    }

    });

  }

  void addToRestoreListIndex(int index){
    setState(() {
      if (!selectedTrashPhotosIndex.contains(index)){
      selectedTrashPhotosIndex.add(index);
    } else {
      selectedTrashPhotosIndex.remove(index);
    }
    });
  }

  void addToRestoreList(String photo, String photoName){
    // Add choosed photo to restore list

    setState(() {
    if (!selectedTrashPhotos.contains(photo)){
      selectedTrashPhotos.add(photo); // Photo path
      selectedTrashPhotosName.add(photoName);
    } else {
      selectedTrashPhotos.remove(photo);
      selectedTrashPhotosName.add(photoName);
    }
    });

  }

  void removePhotos(){
      // User remove photos from trash folder

      // Get current trash map state
      String jsonString = "";
      jsonString = fileTrash.readAsStringSync();
      trash = jsonDecode(jsonString);

      // Remove choosed photos
    for (String photo in selectedTrashPhotos){
      int index = trashPhotos.indexOf(photo);
      String name = trashPhotosName[index];
      trash.remove(name);
      trashPhotosName.remove(name);
      trashPhotos.remove(photo);
    }

    // Overwrite file
    jsonString = jsonEncode(trash);
    fileTrash.writeAsStringSync(jsonString);

    // Clean objects
    setState(() {
      selectedTrashPhotos = [];
      selectedTrashPhotosIndex = [];
      selectedTrashPhotosName = [];
      trashPhotos;
      trashPhotosName;
    });
  }

  void restorePhotos(){
    // This method will restore choosed photos into recents category
    // We're not restoring them to previous category yet due to some limitations

    // Read JSON map
    String jsonString = fileTrash.readAsStringSync();
    trash = jsonDecode(jsonString);

    // Add photoname along photopath into hash map
    for (String photoName in selectedTrashPhotosName){
      for (String photo in selectedTrashPhotos){
        if (selectedTrashPhotosName.indexOf(photoName) == selectedTrashPhotos.indexOf(photo))
          if (!photos["Reciente"].keys.contains(photoName)){
            photos["Reciente"][photoName] = "";
            photos["Reciente"][photoName] = photo;
            trashPhotos.remove(photo);
            trashPhotosName.remove(photoName);
            trash.remove(photoName);
          }
      }
    }

    // Save changes permanently
    jsonString = "";
    jsonString= jsonEncode(photos);
    file.writeAsStringSync(jsonString);

    jsonString = "";
    jsonString = jsonEncode(trash);
    fileTrash.writeAsStringSync(jsonString);

    // Reload changes
    setState(() {
      trashPhotos;
      trashPhotosName;
      selectedTrashPhotos = [];
      selectedTrashPhotosName = [];
      refreshLists();
    });
  }

  Container trasButtonContainer(BuildContext context) {
    return Container(
        child : ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft : Radius.circular(24),
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.blueAccent.withOpacity(0.5),
              items: <BottomNavigationBarItem> [
                BottomNavigationBarItem(
                    backgroundColor: Colors.greenAccent,
                    icon: IconButton(
                      icon :  Icon(Icons.restore_rounded, color: Colors.white, size: 40, ),
                      onPressed: (){
                        restorePhotos();
                      },), label: ""
                ),

                BottomNavigationBarItem(
                    backgroundColor: Colors.redAccent,
                    icon: IconButton(icon:  Icon(Icons.delete_rounded, color: Colors.white, size: 40,),
                      onPressed: (){
                        removePhotos();
                      },), label: "")
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context){
    return StatefulBuilder(builder: (context, setState)
    {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: appBar,

        body: Column(
            children: [
              Image.asset("assets/icon/banner.png",),
                SizedBox(height: 20,),
                SingleChildScrollView(
               child : Row(
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
                            esReciente = true;
                            esCategorias = false;
                            esPapelera = false;
                            swapColors();
                            refreshLists();
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
                            esPapelera = false;
                            swapColors();
                            refreshLists();
                          });
                        },
                        child: Text("Categorías", style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),))))),

                    SizedBox(width: 10,),

                    Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            topLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                          child:  ColoredBox(
                            color: trashButton,
                            child: TextButton(
                              child:  Text("Papelera", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                              onPressed: (){
                                setState((){
                                  // Swap colors
                                  esReciente = false;
                                  esCategorias = false;
                                  esPapelera = true;
                                  swapColors();
                                  refreshLists();
                                });
                              }),
                          ),
                        )

                    ),
                  ],
                ),
                ),

              SizedBox(height: 20,),

              if (esReciente && currentRecentsPhotos.length >= 1)
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
                                                    currentRecentsPhotos[index]),
                                                    color: selectedRecentsPhotosIndex.contains(index) ? Colors.blueAccent : null,)
                                      ),
                                      onTap: () {
                                        if (selectedRecentsPhotosIndex.length == 0){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> imagePreview(image : currentRecentsPhotos[index], imageName : currentRecentsPhotosName[index], currentVideos : currentVideos, currentVideosName : currentVideosName, currentCategory: "Reciente",)));
                                        refreshLists();
                                        } else {
                                          chooseAppBar(index, currentRecentsPhotos[index], currentRecentsPhotosName[index]);
                                        }
                                      },
                                        onLongPress: (){
                                          chooseAppBar(index, currentRecentsPhotos[index], currentRecentsPhotosName[index]);
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

              if (esCategorias && categories.length >= 1)
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
                                              Image.file(
                                                File(categoriesCover[index],), scale: 2.0,
                                                  color : selectedCategoriesIndex.contains(index) ? Colors.blueAccent : null,

                                              ),
                                               Text(categories[index], style: TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                               )
                                               ]
                                            )
                                          ),
                                          ),
                                          onTap: (){
                                            if (selectedCategoriesIndex.length == 0){
                                              generateCategoryPhotos(categories[index]);
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => Categoria(currentPhotos : currentPhotos, currentPhotosName : currentPhotosName, currentVideos: currentVideos, currentVideosName: currentVideosName, currentCategory: categories[index],)));
                                            } else {
                                              // We'll add options to remove selected categories
                                             setState((){
                                               setCategoryAppBar(index);
                                             });
                                            }

                                        },

                                          onLongPress: (){
                                            // We'll add options to remove selected categories
                                            setState((){
                                              setCategoryAppBar(index);
                                            });
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

              if (esPapelera && trashPhotos.length >= 1)
                Expanded(
                  child:  GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 2.3/3,
                    scrollDirection: Axis.vertical,
                  children: List.generate(trashPhotos.length, (index){
                    return StatefulBuilder(
                        builder: (context, setState){
                          return FittedBox(
                            child:  Column(
                              children: [
                                InkWell(
                                  child : ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft : Radius.circular(24),
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                            ),
                                  child:  Card(
                                    child: Column(
                                      children: [
                                        Image.file(
                                            File(trashPhotos[index]),
                                            color: selectedTrashPhotosIndex.contains(index) ? Colors.blueAccent.withOpacity(0.5) : null,),
                                        Text(trashPhotosName[index], style: TextStyle(color: Colors.white),)
                                      ],
                                    ),
                                  ),
                                  ),
                                  onTap: (){
                                    // TO-DO
                                    if (selectedTrashPhotosIndex.length > 0 ){
                                      addToRestoreList(trashPhotos[index], trashPhotosName[index]);
                                      addToRestoreListIndex(index);
                                    }
                                  },

                                  onLongPress: (){
                                    addToRestoreList(trashPhotos[index], trashPhotosName[index]);
                                    addToRestoreListIndex(index);
                                  },
                                )
                              ],
                            ),
                          );
                    }
                    );
                  }
                ),
                  )
                ),

              if (esReciente && currentRecentsPhotos.length == 0)
                Expanded(
                  child:  Align(
                    child:  Column(
                    children: [
                      Image.asset("assets/images/images.png"),
                      Text("Empieza tomando una foto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                ]
                  )
                  )
                ),

              if (esCategorias && categories.length == 0)
                Expanded(
                  child:  Align(
                    child:  Column(
                    children: [
                      Image.asset("assets/images/folder.png"),
                      Align(
                          alignment : Alignment.center,
                          child : Text("Crea una categoría", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)),
                    ],
                  ),
                  )
                ),

              if (esPapelera && trashPhotosName.length == 0)
                Expanded(
                child : Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Image.asset("assets/images/trash.png", width: 200, height: 200, ),
                      Text("No hay nada, esta vacía", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                    ],
                  ),
                ),
              ),

              if (esReciente)
              CameraButton(context),

              if (esCategorias)
                CategoryButton(context),

              if (esPapelera && selectedTrashPhotosIndex.length >= 1)
                // Only show button if there's a selected photo
                trasButtonContainer(context),
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
              color: Colors.white, size: 40,),
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

  int currentIndex = 0;

  // This is the home screen button
  // Pressing the button will open the camera preview context
  return Container(
    color: Colors.transparent,
      child : ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),

          child: InkWell(
          child: NavigationBar(
            backgroundColor: Colors.blueAccent,
              destinations: [
                NavigationDestination(
                    icon:  TextButton.icon(icon :  Icon(Icons.photo_camera_rounded, color: Colors.white, size: 40,), label: Text(""),
                      onPressed: (){
                        Navigator.pop(context);
                      },),
                    label: "")
              ],
              ),
              onTap : (){
                Navigator.pop(context);
              }

        ),


    )
  );
}

