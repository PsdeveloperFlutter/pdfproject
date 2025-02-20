import 'dart:ffi';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import'package:pdf/pdf.dart';
import'package:pdf/widgets.dart' as pw;

import 'Riverpod_State_Management/State_Management.dart';
dynamic fileofpdf;
class pdf_gen{

  static pw.FontWeight convertFlutterFontWeightToPdf(int index) {
    if (index <= 1) return pw.FontWeight.normal; // Approximate w100, w200
    if (index <= 4) return pw.FontWeight.normal; // Approximate w300, w400, w500
    return pw.FontWeight.bold; // Approximate w600, w700, w800, w900
  }

 static Future<void>pdfgen(
String title,
String Subtitle,
String description,
BuildContext context,
String fontname,
Color selectcolor,
int font_size_title,
int font_size_subtitle,
int font_size_description,
int  set_title_fontweight,
Uint8List? imageBytes,
)async{
  try{


    // Convert font weight index to pdf FontWeight
    pw.FontWeight pdfFontWeight = convertFlutterFontWeightToPdf(set_title_fontweight);

    // Format DateTime before passing it
    String formattedDate = "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}";

    //This is
    final pdf=pw.Document();
    final font = await rootBundle.load("assets/fonts/$fontname");
    final ttf=pw.Font.ttf(font);
    // Convert Flutter Color to PdfColor
    final pdfColor = PdfColor(selectcolor.red / 255, selectcolor.green / 255, selectcolor.blue / 255);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(32), // Add margin for a better layout
        build: (_) {
          // 🛠️ Check if imageBytes is null before proceeding
          if (imageBytes == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please select an image first!")),
            ); // 🚀 Prevents further execution
          }

          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2), // Border for styling
              borderRadius: pw.BorderRadius.circular(10),
              color: PdfColor(1.0,1.0,1.0) // Light background color
            ),
            padding: pw.EdgeInsets.all(20), // Padding inside container
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header (Logo or Title)
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: pw.EdgeInsets.only(bottom: 12),
                  child: pw.Text(
                    "Title: $title",
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: font_size_title.toDouble(),
                      fontWeight: pdfFontWeight,
                      color: pdfColor,
                    ),
                  ),
                ),

                pw.Divider(thickness: 2, color: PdfColors.grey), // Divider line

                pw.SizedBox(height: 10),

                // Subtitle Section
                pw.Text(
                  "SubTitle: $Subtitle",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: font_size_subtitle.toDouble(),
                    fontWeight: pw.FontWeight.bold,
                    color: pdfColor,
                  ),
                ),

                pw.SizedBox(height: 8),

                // Description Section
                pw.Text(
                  "Description: $description",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: font_size_description.toDouble(),
                    fontWeight: pw.FontWeight.normal,
                    color: PdfColors.black, // Default black color for readability
                  ),
                ),

                pw.SizedBox(height: 20),

                // Footer
                pw.Divider(thickness: 2, color: PdfColors.grey),

                // 🛠️ Only add image if `imageBytes` is NOT null
                if (imageBytes != null)
                  pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(imageBytes),
                      fit: pw.BoxFit.cover,
                      width: 400,
                      height: 400,
                    ),
                  ),


                pw.Divider(thickness: 2, color: PdfColors.grey),
                pw.SizedBox(height: 15),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Generated on ${formattedDate}",
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 20,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );



    //Save the PDF File
    final output=await getExternalStorageDirectory();
    fileofpdf = File("${output!.path}/$title.pdf");
    await fileofpdf.writeAsBytes(await pdf.save());





    //Store in Getx Storage
    final GetStorage storage=GetStorage();
     const String pdfListKey="pdf_list";

    //Retrieve Already insterested PDF FROM  GetxStorage

    List<String>list_of_pdf=storage.read<List>("pdf_list")?.cast<String>()??[];

    //Add new pdf file in
    list_of_pdf.add(fileofpdf.path);

    //Insert the List in Getx Storage
    storage.write(pdfListKey, list_of_pdf).then((value){
      print("\n Storage of PDF is Done Successfully ");
    });
    //This code is Responsible for the Deletion in the Code make sure of this




    showAwesomeSnackbarforSuccess(context);


  }
  catch(e){
   print("Error Occur $e");

  }

  finally{
    print("Code Run Here Properly in PDF Generater file ");
  }


}


//for deleting purpose
static void delete_specific_pdf(int index , BuildContext context){
   try{
     final GetStorage storage=GetStorage();
     const String pdfListKey="pdf_list";
     //Retrieve Already insterested PDF FROM STORAGE
     List<String>list_of_pdf=storage.read("pdf_list")?.cast<String>()??[];
     //Remove the pdf from the list
     list_of_pdf.removeAt(index);

     storage.write(pdfListKey, list_of_pdf).then((value)=>print(""
         "Deletion in PDF will be done Successfully "));
     // Refresh the UI
     Get.snackbar(
       "Success",
       "PDF deleted successfully",
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.green,
       colorText: Colors.white,
     );

   }
   catch(e){
     print("Deletion is not Done of pdf  :-  \n $e");
   }

 }



}

//This is For Showing Positive FeedBack
void showAwesomeSnackbarforSuccess(BuildContext context) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Success!',
      message: 'Your Pdf Generate Successfully .',
      contentType: ContentType.success, // success, warning, help, failure
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}