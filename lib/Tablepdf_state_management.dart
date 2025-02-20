import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import'package:riverpod/riverpod.dart';


//This is for managing the Margin of table by the user with slider and functionality of statemanagement in Riverpod make sure of this

class table_padding extends StateNotifier<int>{
  table_padding():super(2);

  //changing the value the state of Margin using the Slider and river pod
  int change_padding(int value){
    state=value;
    return state;
  }

  //show the state of the table_margin
  int show_state_table_margin(){
    return state;
  }

}
final table_padding_state=StateNotifierProvider<table_padding,int>((ref){
  return table_padding();
});




//here I set the table border width

class table_border extends StateNotifier<int>{
table_border():super(1);
int change_border(double value){
  state=value.toInt();
  return state;
}

int show_state_table_border(){
  return state.toInt();
}
}
//here we set the variable for the table_border
final table_border_state=StateNotifierProvider<table_border,int>((ref){
  return table_border();
});






//Know we set the Fonts size of table text and make sure of this with Riverpod State Management make sure of this  with State Notifier  Provider


class fontsize_texttable extends StateNotifier<int>{
  fontsize_texttable():super(10);
  int change_fontsize(int value){
    state=value;
    return state;
  }
}
final fontsize_text_table=StateNotifierProvider<fontsize_texttable,int>((ref){
  return fontsize_texttable();
});







//This is for the Cell font Size of the Column with Riverpod State Management make sure of this .


class fontsize_celltext extends StateNotifier<int>{
  fontsize_celltext():super(10);
  int change_fontsize(int value){
    state=value;
    return state;
  }
}
final fontsize_cell=StateNotifierProvider<fontsize_celltext,int>((ref){
  return fontsize_celltext();
});





//Clear the text Field of table_Pdf
class RowTextFieldClear extends StateNotifier<TextEditingController> {
  RowTextFieldClear() : super(TextEditingController());

  // Method to clear text in the TextField
  void clearText(BuildContext context,  TextEditingController rowcontroller) {
    if(rowcontroller.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Text field already clear")));
    }
    else {
      rowcontroller.clear(); // Clears the text inside the controller
    }
  }
}

final rowTextFieldProvider=StateNotifierProvider((ref){
  return RowTextFieldClear();
});





//Clear the text Field of table_Pdf
class cellTextFieldClear extends StateNotifier<TextEditingController> {
  cellTextFieldClear() : super(TextEditingController());

  // Method to clear text in the TextField
  void clearText(BuildContext context,  TextEditingController cellcontroller) {
    if(cellcontroller.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Text field already clear")));
    }
    else {
      cellcontroller.clear(); // Clears the text inside the controller
    }
  }
}

final cellTextFieldProvider=StateNotifierProvider((ref){
  return cellTextFieldClear();
});