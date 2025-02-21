import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import'package:riverpod/riverpod.dart';



//This is the State Notifier Responsible for managing the state of pageview and bottom Navigation bar also
class indexnotifier extends StateNotifier<int>{
  indexnotifier():super(0);
  void index_value(int index){
   state=index;
  }
  //for showing the State will work properly and see the state value in console
  void showindex(){
    print(state);
  }

}

final indexget=StateNotifierProvider<indexnotifier,int>((ref){
  return indexnotifier();
});




//This is the State Notifier Responsible for the Manging and clear the textfield controller

class text_field_controller extends StateNotifier<TextEditingController>{
  text_field_controller():super(TextEditingController());

  void clearfields(TextEditingController
      controler,BuildContext context){

    if(controler.text.toString().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This Field already Empty")));
    }

    else{
      controler.clear();
      state=controler;
    }
  }
}


final text_field_Manage=StateNotifierProvider<text_field_controller,TextEditingController>((ref){
  return text_field_controller();
});





//Now I am setting the Future Provider with GetXstorage

  final pdf_view=FutureProvider<List<String>>((ref)async{
  final storage=GetStorage();
  const String pdfListKey = "pdf_list";
  await Future.delayed(Duration(seconds: 5));
  List<dynamic>?storedata=storage.read(pdfListKey);
  List<String>data_pdf=storedata?.map((e)=>e.toString()).toList()??[];
return data_pdf;

});







//This is the State Management for setting the title font size using the State Notifier in River Pod SM


class font_size_of_title extends StateNotifier<double>{
  font_size_of_title():super(10);
  void set_font_size(int value ){
    state=value.toDouble();
  }
  int show_font_size(){
    print(state);
    return 	state.toInt();
  }
}
final set_fontsize_of_title=StateNotifierProvider<font_size_of_title,double>((ref){
  return font_size_of_title();
});




//This is the state notifier for the subtitle font size
class font_size_of_subtitle extends StateNotifier<double>{
  font_size_of_subtitle():super(10);
  void set_font_size(int value ){
    state=value.toDouble();
  }
  int show_font_size(){
    print(state);
    return 	state.toInt();
  }
}

final set_fontsize_of_subtitle=StateNotifierProvider<font_size_of_subtitle,double>((ref){
 return  font_size_of_subtitle();
});










//This is the state notifier for the description font size
class font_size_of_description extends StateNotifier<double>{
  font_size_of_description():super(10);
  void set_font_size(int value ){
    state=value.toDouble();
  }
  int show_font_size(){
    print(state);
    return 	state.toInt();
  }
}

final set_fontsize_of_description=StateNotifierProvider<font_size_of_description,double>((ref){
  return  font_size_of_description();
});






// State Notifier for Font Weight Management
class FontWeightNotifier extends StateNotifier<int> {
  FontWeightNotifier() : super(3); // Default font weight index (w400)

  // Method to set font weight based on slider value
  void setFontWeight(int value) {
    state = value;
  }

  // Method to return the current state (index)
  int getFontWeightIndex() {
    return state;
  }
}

// Riverpod Provider
final fontWeightProvider = StateNotifierProvider<FontWeightNotifier, int>((ref) {
  return FontWeightNotifier();
});

// FontWeight List for Mapping
final List<FontWeight> fontWeights = [
  FontWeight.w100,
  FontWeight.w200,
  FontWeight.w300,
  FontWeight.w400, // Default
  FontWeight.w500,
  FontWeight.w600,
  FontWeight.w700,
  FontWeight.w800,
  FontWeight.w900,
];





//This is the state notifier for the managing the state for the StateNotifier Provider getting the image and set to the pdf make sure of this

class Imagefile extends StateNotifier<File?>{
  Imagefile():super(null);

  final image_picker=ImagePicker();
  //Set the Image by the Camera
  Future<void> setimagebycamera()async{
    final XFile? pickedfile=await image_picker.pickImage(source: ImageSource.camera);
    if(pickedfile!=null){
      state=File(pickedfile.path);
    }
  }
  //Set the Image by the Gallery
  Future<void> setimagebygallery()async{
    final XFile? pickedfile=await image_picker.pickImage(source: ImageSource.gallery);
    if(pickedfile!=null){
      state=File(pickedfile.path);
    }
  }

}

final setimage=StateNotifierProvider<Imagefile,File?>((ref){
  return Imagefile();
});


//set the width and height of the Image Using Riverpod State Management
final sliderProviderwidth = StateProvider<double>((ref) => 0.5); // Default value: 0.5

//set the width and height of the Image Using Riverpod State Management
final sliderProviderheight = StateProvider<double>((ref) => 0.5); // Default value: 0.5


