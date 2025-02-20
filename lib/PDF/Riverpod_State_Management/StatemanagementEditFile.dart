import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import'package:riverpod/riverpod.dart';



class setcolour extends StateNotifier<Color>{
  setcolour():super(Colors.black);
   updatecolour(Color  color){
    state=color;

  }
}


// ✅ Create a provider for SetColour
final colorProvider = StateNotifierProvider<setcolour, Color>((ref) {
  return setcolour();
});



//This is for the Stroke Slider make sure of this that how I can adjust this functionality make sure of this

class setstrokeWidth extends StateNotifier<double>{
  setstrokeWidth() : super(2.0);

  //for the updating the state value make sure of this
  void updatestrokewidth(double value){
    state=value;
  }
  //watch the state make sure of that
  double showstrokewidtvalue(){
    return state;
  }
}


//State Notifier make sure of that
final strokewidthvalue = StateNotifierProvider<setstrokeWidth,double>((ref){
  return setstrokeWidth();
});