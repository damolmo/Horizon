import 'package:flutter/material.dart';


class sortList {

  late List<String> lista;

  @override
  sortList({
    required this.lista,
});

  int fullListSize(List<String> lista){
    // Get size of list
    return lista.length;
  }

  void sortListAscending(){
    // Sort list on alphabetical order
    this.lista.sort();
  }

  void sortListDescending(){
    // Get full list size
    int index = fullListSize(lista);

    // Sort list on descending order
    List<String> tempList = [];

    for (int i = index; i > 0; i --){
      tempList.add(lista[i - 1]);
    }

    // Save temolist into final variable
    this.lista = tempList;
  }

  List<String> getList(){
    return this.lista;
  }
}