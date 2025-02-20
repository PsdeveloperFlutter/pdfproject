import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfproject/PDF/pdf_generater.dart';
import 'package:pdfproject/Tablepdf_state_management.dart';
import 'package:printing/printing.dart';

import 'Cell_Alignment.dart';
import 'Riverpod_State_Management/State_Management.dart';


//SET THE MARGIN OF TABLE
int table_margin=2;

//set the color of font cell
Color ? cellselectcolor;

//set the color of font of header
Color ? headerselectcolor;

class table_pdf extends ConsumerStatefulWidget{
@override
ConsumerState<table_pdf> createState()=>table_State();
}

//Selected alignment for the pdf font alignment selection
int ? selected_alignment;


class table_State extends ConsumerState<table_pdf> {
  // Your state management code goes here
  final TextEditingController _rowsController = TextEditingController();
  final TextEditingController _columnsController = TextEditingController();

   //save the Row and column make sure of this save user input
  int? rows;
  int? columns;

TextEditingController setdatacontroller=TextEditingController();

  Widget build(BuildContext context){
    return Scaffold(
     body:  Padding(
       padding: const EdgeInsets.all(16.0),
       child: SingleChildScrollView(
         child: Column(
           children: [
             Text("Create Table Pdf",style: GoogleFonts.aBeeZee(fontSize: 18),),
             SizedBox(height: 10,),
             Card(
               color: Colors.white,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Consumer(builder: (context,ref,child){
                  return
                   TextField(

                     style: GoogleFonts.aBeeZee(fontSize: 12),
                     controller: _rowsController,
                     keyboardType: TextInputType.number,
                     decoration: InputDecoration(labelText: "Enter number of Rows",
                         suffixIcon: IconButton(onPressed: (){

                           //State StateNotifierProvider
                            ref.read(rowTextFieldProvider.notifier).clearText(context,_rowsController);

                         }, icon: Icon(Icons.clear,color:Colors.green)),
                         labelStyle: GoogleFonts.aBeeZee(fontSize: 12)
                     ),
                   );
                 })
               ),
             ),
             SizedBox(height: 10),
             Card(
               color: Colors.white,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextField(
                   style: GoogleFonts.aBeeZee(fontSize: 12),
                   controller: _columnsController,
                   keyboardType: TextInputType.number,
                   decoration: InputDecoration(
                       suffixIcon: IconButton(onPressed: (){
                         //State StateNotifierProvider
                         ref.read(cellTextFieldProvider.notifier).clearText(context,_columnsController);

                       }, icon: Icon(Icons.clear,color:Colors.green)),
                       labelText: "Enter number of Columns"
                       ,labelStyle: GoogleFonts.aBeeZee(fontSize: 12)
                   ),
                 ),
               ),
             ),
             SizedBox(height: 20),

             SingleChildScrollView(
               child: Container(
                 height: 120 * tableData.length.toDouble(), // Dynamic height based on data length
                 child: Column(
                   children: [
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                       child: Column(
                         children: tableData.asMap().entries.map((rowEntry) {
                           int rowIndex = rowEntry.key; // Get row index
                           List<String> row = rowEntry.value; // Get row data

                           return Row(
                             children: row.asMap().entries.map((cellEntry) {
                               int colIndex = cellEntry.key; // Get column index
                               String cell = cellEntry.value; // Get cell value

                               return Consumer(builder: (context, ref, child) {
                                 final fontsizevalue = ref.watch(fontsize_text_table);
                                 final tablewidthvalue = ref.watch(table_border_state);

                                 return GestureDetector(
                                   onTap: () {
                                     // Capture and print the row & column index on tap
                                     print("Clicked on Row: $rowIndex, Column: $colIndex");

                                     // Example: Show an alert with the selected cell data
                                     showDialog(
                                       context: context,
                                       builder: (context) => AlertDialog(
                                         title: Text("Enter data here ",style: GoogleFonts.aboreto(fontSize: 15),),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelStyle:GoogleFonts.aboreto(fontSize: 15),
                                                label: Text( "Enter data here ")
                                              ),
                                              controller: setdatacontroller,
                                            ),
                                          ),
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                     children: [
                                       TextButton(
                                         onPressed: () => Navigator.pop(context),
                                         child: Text("Cancel",style: GoogleFonts.aboreto(fontSize: 15),),
                                       ),
                                       TextButton(
                                         onPressed: (){
                                        setState(() {

                                          tableData[rowIndex][colIndex]=setdatacontroller.text.toString();
                                        }, );
                                        Navigator.pop(context);

                                     },
                                          child: Text("Enter",style: GoogleFonts.aboreto(fontSize: 15),),
                                       )

                                     ],
                                   )
                                         ],
                                       ),
                                     );
                                   },
                                   child: Container(
                                     margin: EdgeInsets.all(2),
                                     padding: EdgeInsets.all(8),
                                     decoration: BoxDecoration(
                                       border: Border.all(color: Colors.black, width: tablewidthvalue.toDouble()),
                                     ),
                                     child: Text(
                                       cell,
                                       style: GoogleFonts.aBeeZee(fontSize: fontsizevalue.toDouble()),
                                     ),
                                   ),
                                 );
                               });
                             }).toList(),
                           );
                         }).toList(),
                       ),
                     ),
                   ],
                 ),
               ),
             ),



             SizedBox(height: 12,),
             Text("Formatting of Table ",style:GoogleFonts.aBeeZee(fontSize: 16)),
             SizedBox(height: 12,),


             //Here we Set the Margin of the Table make sure of this
             Card(
               child: Consumer(
               
                 builder: (context,ref,child){
                   final marginvalue=ref.watch(table_padding_state);
                  return
               
                    ExpansionTile(title: Text("Set Padding of table",style: GoogleFonts.aBeeZee(fontSize: 13),),
                        children: [
               
                        Slider(
                        min: 2,
                        max: 25,
                        divisions: 5,
                        thumbColor: Colors.green.shade500,
                        activeColor: Colors.blue.shade500,
                        inactiveColor: Colors.amber.shade500,
                        value: marginvalue.toDouble(), onChanged: (value){
                          ref.read(table_padding_state.notifier).change_padding(value.toInt());
                        }),
                   ],
                   );
               
                 },
               ),
             ),

             SizedBox(height:12),

             //Here we Set textfont size   of the Table make sure of this
             Card(
               child: Consumer(
               
                 builder: (context,ref,child){
                   final fontsizevalue=ref.watch(fontsize_text_table);
                   return
               
                     ExpansionTile(title: Text("Set header font size ",style: GoogleFonts.aBeeZee(fontSize: 13),),
                       children: [
               
                         Slider(
                             min: 2,
                             max: 45,
                             thumbColor: Colors.green.shade500,
                             activeColor: Colors.blue.shade500,
                             inactiveColor: Colors.amber.shade500,
                             value: fontsizevalue.toDouble(), onChanged: (value){
                               print(value);
                           ref.read(fontsize_text_table.notifier).change_fontsize(value.toInt());
                         }),
                       ],
                     );
               
                 },
               ),
             ),


             SizedBox(height: 12,),
             Card(
               child: ExpansionTile(title: Text("Set header Color ",style: GoogleFonts.aBeeZee(fontSize: 13),),
                 children: [

                   Container(
                     height: 300,
                     child: ListView.separated(itemBuilder: (context,index){
                       return
                         Card(
                           child: ListTile(
                             onTap: (){
                               headerselectcolor=colorMap.values.elementAt(index);
                             },
                             title: Text(colorMap.keys.elementAt(index),style: GoogleFonts.aBeeZee(fontSize: 12),),
                             trailing: Container(
                               width: 15,
                               height: 15,
                               color: colorMap.values.elementAt(index),
                             ),
                           ),
                         );
                     }, separatorBuilder: (context, index) => SizedBox(height: 10,),
                         itemCount: colorMap.length),
                   )
                 ],
               ),
             ),

             SizedBox(height:12),

             //Here we Set Cell textfont size   of the Table make sure of this
             Card(
               child: Consumer(

                 builder: (context,ref,child){
                   final fontsizecellvalue=ref.watch(fontsize_cell);
                   return

                     ExpansionTile(title: Text("Set Cell font size ",style: GoogleFonts.aBeeZee(fontSize: 13),),
                       children: [

                         Slider(
                             min: 2,
                             max: 45,
                             thumbColor: Colors.green.shade500,
                             activeColor: Colors.blue.shade500,
                             inactiveColor: Colors.amber.shade500,
                             value: fontsizecellvalue.toDouble(), onChanged: (value){
                           print(value);
                           ref.read(fontsize_cell.notifier).change_fontsize(value.toInt());
                         }),
                       ],
                     );

                 },
               ),
             ),

             SizedBox(height: 12,),
           Card(
             child: ExpansionTile(title: Text("Set Cell Color ",style: GoogleFonts.aBeeZee(fontSize: 13),),
               children: [
             
                 Container(
                   height: 300,
                   child: ListView.separated(itemBuilder: (context,index){
                     return
                     Card(
                       child: ListTile(
                         onTap: (){
                           cellselectcolor=colorMap.values.elementAt(index);
                         },
                         title: Text(colorMap.keys.elementAt(index),style: GoogleFonts.aBeeZee(fontSize: 12),),
                        trailing: Container(
                          width: 15,
                          height: 15,
                          color: colorMap.values.elementAt(index),
                        ),
                       ),
                     );
                   }, separatorBuilder: (context, index) => SizedBox(height: 10,),
                       itemCount: colorMap.length),
                 )
               ],
             ),
           ),



           SizedBox(height:12),

             //Here we Set table border size   of the Table make sure of this
             Card(
               child: Consumer(
               
                 builder: (context,ref,child){
                   final table_width_value=ref.watch(table_border_state);
                   return
               
                     ExpansionTile(title: Text("Set table border ",style: GoogleFonts.aBeeZee(fontSize: 13),),
                       children: [
               // This slider is Responsible for showing the value of the table Width and make sure we change with River pod Statemanagement with State Notifier provider
               
                         Slider(
                             min: 1,
                             max: 10,
                             divisions: 5,
                             thumbColor: Colors.green.shade500,
                             activeColor: Colors.blue.shade500,
                             inactiveColor: Colors.amber.shade500,
                             value:table_width_value.toDouble(),
                             onChanged: (value){
                           ref.read(table_border_state.notifier).change_border(value);
                         }),
                       ],
                     );
               
                 },
               ),
             ),
SizedBox(height: 12,),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ElevatedButton(
                    onPressed:(){
                      validate();
                      try{
                        generatetable();
                      }
                      catch(e){
                        print("Error Occur $e");
                      }


                    },
                    child: Text("Generate Table",style: GoogleFonts.aBeeZee(fontSize: 12),),
                  ),
                  SizedBox(width: 12,),
                  ElevatedButton(onPressed: (){
                    validate();
                    try{
                      generatePdf(context);
                    }
                    catch(e){
                      print("Error Occur $e");
                    }

                  }, child: Text("Generate Pdf",style: GoogleFonts.aBeeZee(fontSize: 12),)),


                ],
              ),
            )
           ],
         ),
       ),
     ),
    );
  }





  //create Table pdf file and set the path to save in Getx Storage make sure of this
  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final GetStorage storage = GetStorage();
    const String pdfListKey = "pdf_list";

    final paddingValue = ref.watch(table_padding_state); // Directly watch the state
    final tablewidthvalue=ref.watch(table_border_state);
    final fontsizevalue=ref.watch(fontsize_text_table); //This is for setting the font Size in Pdf
    final fontsizecellvalue=ref.watch(fontsize_cell);



    // Convert selected color to PdfColor_cell
    final pdfColor_cell = PdfColor(
        cellselectcolor!.red / 255,
        cellselectcolor!.green / 255,
        cellselectcolor!.blue / 255
    );




    // Convert selected color to PdfColor_cell
    final pdfColor_header = PdfColor(
        headerselectcolor!.red / 255,
        headerselectcolor!.green / 255,
        headerselectcolor!.blue / 255
    );
    // Create PDF Table
    pdf.addPage(


      pw.Page(

        build: (pw.Context context) {
          return pw.Center(
            child:  pw.Table.fromTextArray(
              data: [


                List.generate(columns!, (index) => "Column ${index + 1}"), // Header Row
                ...tableData.map((row) => row.map((cell) => cell.toString()).toList()), // Convert each row to List<String>
              ],

             
              cellStyle: pw.TextStyle(
                fontSize:fontsizecellvalue.toDouble(),
              color:pdfColor_cell
              ),

              cellPadding: pw.EdgeInsets.symmetric(
                  vertical: paddingValue.toDouble(), horizontal: paddingValue.toDouble() /2),//set the padding

              headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: pdfColor_header,
              fontSize:fontsizevalue.toDouble(),
              ),

              rowDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              border: pw.TableBorder.all(width: tablewidthvalue.toDouble()),//set the table border
            ),
          );
        },
      ),
    );


    // Save PDF to Temporary Directory
    final output = await getTemporaryDirectory();
    final File fileofpdf = File("${output.path}/table_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await fileofpdf.writeAsBytes(await pdf.save());

    // Retrieve Already Stored PDFs from GetX Storage
    List<String> list_of_pdf = storage.read<List>(pdfListKey)?.cast<String>() ?? [];

    // Add New PDF File Path to Storage
    list_of_pdf.add(fileofpdf.path);
    storage.write(pdfListKey, list_of_pdf).then((value) {
      print("\n ✅ Storage of PDF is Done Successfully ");
      showAwesomeSnackbarforSuccess(context);
    })..then((value){
      return  ref.refresh(pdf_view);
    });

    // Open the PDF Preview
   // await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // check validation of rows and columns

validate(){
  final int? enteredRows = int.tryParse(_rowsController.text);
  final int? enteredColumns = int.tryParse(_columnsController.text);

  if(enteredColumns == null || enteredRows == null || enteredColumns <=0 || enteredRows <=0){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter valid row and column numbers!")),
    );
    return;
  }
  else{
    rows=enteredRows;
    columns=enteredColumns;
  }
}



//Create PDF of Table Logic Behind creating the PDF TABLE

List<List<String>>  tableData=[];
void generatetable(){
    setState(() {
      tableData = create_table(rows!, columns!);
    });
}

//This is Work on 2D table make sure of this
List<List<String>> create_table(int rows, int columns){
    List<List<String>> table=[];
    for(int i=0;i<rows;i++){
      List<String> row = [];
      for(int j=0;j<columns;j++){
        row.add("Row ${i + 1}, Col ${j + 1}");
      }
      table.add(row);
    }
    return table;
  }


}