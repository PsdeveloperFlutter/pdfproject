import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:path_provider/path_provider.dart';

Future<File>convertpfttoimage(String pdfpath,int pagenumber,BuildContext context)async{
  final doc=await PdfDocument.openFile(pdfpath);
  final page=await doc.getPage(pagenumber);

  //This is for the setting of the Image
  final image=await page.render(
    width: 300,
    height: 300,
  );
  if(image ==null || image.pixels.isEmpty){
    print("Error Occur in Pixels solve it ");
  }

  final Uint8List imagebytes=image.pixels;

  final appdirectory  = await getApplicationDocumentsDirectory();
  // Create the 'Imagepdfapp' folder if it doesn't exist
  final  folderpath='${appdirectory.path}/Imagepdfapp';
  final folder=Directory(folderpath);
  if(!await folder.exists()){
    // If the folder doesn't exist, create it
    await folder.create(recursive: true);
  }
  final imagepath='$folderpath/imagesave.png';
   final imagefile=File(imagepath);
   await imagefile.writeAsBytes(imagebytes).then((value){
     return
         ScaffoldMessenger(child: ScaffoldMessenger(child: ScaffoldMessenger(child: SnackBar(content: Text("Pdf Successfully convert to Image ")))));
   }
   );
   return imagefile;

}