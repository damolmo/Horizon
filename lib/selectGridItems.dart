import 'package:flutter/material.dart';

/**
 * This is an open-source impl on flutter grid items selection by "daviiid99
 * If you want to use it on an open source product don't remove the credits header
 */

class selectGridItems{

  List<String> selectedItems = [];

addGridItems (String value) {
  // This method receive the imput from other class
  if (!selectedItems.contains(value)){
    // New item
    selectedItems.add(value);
  } else {
    // Remove existing item
    selectedItems.remove(value);
  }

}

getGridArray(){
  return selectedItems;
}

getGridItems(){
  return selectedItems.length;
}

}


