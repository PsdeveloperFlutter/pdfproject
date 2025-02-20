import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:pdfproject/PDF/Table_Pdf.dart';
import 'package:pdfproject/PDF/pdf_generater.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:pdfproject/PDF/pdftoimage.dart';
import 'Edit pdf .dart';
import 'Extract data from pdf .dart';
import 'PDF to Image .dart';
import 'Riverpod_State_Management/State_Management.dart';
import 'package:share_plus/share_plus.dart';

TextEditingController title=TextEditingController();
TextEditingController subtitle=TextEditingController();
TextEditingController description=TextEditingController();



void main() async{

  //This is for the Managing GetStorage
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();  // Initialize GetStorage
  runApp(
      ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      home: PdfMain(),
    );
  }
}

class PdfMain extends ConsumerWidget {




  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentIndex = ref.watch(indexget);

    //This is the PageController for controlling the Page In PAGEVIEW
    PageController page_controller=PageController();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        title: Text("PDF Create App",style: GoogleFonts.aBeeZee(fontSize: 18,color:Colors.white),),
      ),
      body: PageView(
        controller: page_controller,
        //This is Manage the PageView Controller make sure of this When user press on bottom Navigation so it Works Properly

        onPageChanged: (index){
          ref.read(indexget.notifier).index_value(index);
           ref.read(indexget.notifier).showindex();
          },


        children: [

          //Show Pdf from Getx Storage
           RefreshIndicator(
             elevation: 5,
             color: Colors.green.shade700,
          onRefresh: () async {
           ref.refresh(pdf_view); // ✅ Pull-to-refresh
            },


               //This is first page make sure of this

          child:Consumer(
            builder: (context,ref, child){

              final pdf_async_data=ref.watch(pdf_view);
              return

                pdf_async_data.when(data: (dataofpdf){
                if(dataofpdf.isEmpty)
                  {
                    return Center(child: Text("No PDF Found"));
                  }
                  return dataofpdf.isEmpty
                      ? Center(child: Text("No PDFs found")) // ✅ Handle empty list
                      : ListView.builder(
                    itemCount:  dataofpdf.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Card(
                          elevation: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 450,  // Set a height for proper display
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2), // Optional border
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: PDFView(
                                  filePath: dataofpdf[index],
                                  enableSwipe: true,
                                  swipeHorizontal: false,
                                  autoSpacing: false,
                                  pageSnap:true,
                                  fitPolicy: FitPolicy.BOTH,
                                ),

                              ),
                              Card(
                                elevation: 5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(onPressed: (){
                                      pdf_gen.delete_specific_pdf(index,context);
                                      ref.refresh(pdf_view);
                                    }, icon: Icon(Icons.delete,color: Colors.red,)),

                                    IconButton(onPressed: ()async{
                                      convertpfttoimage(dataofpdf[index],1,context);
                                    }, icon: Icon(Icons.image,color: Colors.green,)),


                                    IconButton(
                                      onPressed: () {

                                        print("PDF Path: ${dataofpdf[index]}");

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AnnotatePDFScreen(pdfPath: dataofpdf[index]),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                    ),

                                //     IconButton(onPressed: (){
                                //       Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                // ExtractAndEditPDFScreen( pdfPath:dataofpdf[index])));
                                //     }, icon: Icon(Icons.dataset,color: Colors.green.shade500,)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );


              }, error: (error,stack){

                print("Error Occur ");
                return CircularProgressIndicator();
                }, loading:()=>Center(child: CircularProgressIndicator(color: Colors.blue.shade700,)));
            },
          )),

          //This is the Second Page in PageView for Showing Create Option for Creating Pdf
         seconddpage( context,ref),

          //This is the Third Page in Pageview for showing table create pdf option
          table_pdf(),
        ],
        scrollDirection: Axis.horizontal,

      ),


      bottomNavigationBar:Consumer(builder: (context,ref,child){
        return
          BottomNavigationBar(
            backgroundColor: Colors.blue.shade700,
            currentIndex: currentIndex, // Set the current index
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.white,
            onTap: (index) {
              ref.read(indexget.notifier).index_value(index);
              ref.read(indexget.notifier).showindex();
              page_controller.animateToPage(index, duration: Duration(milliseconds: 1000),curve: Curves.linear);
            },


            items:  [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Create',
              ),
            ],
          );
      })
    );
  }


  //This is Method for the Second Page UI make sure of this .
  Widget seconddpage(BuildContext context,ref  ) {

    //this is for selecting the image make sure of this by the Riverpod StateManagement

    XFile ? image;

    //set fontWeight of Title in PDF
    int ? set_title_fontweight;

    //Select font and pass to the pdf_generate function
    String ? selectfont=" ";

    //Select color and pass to the pdf_generate function
   Color ? selectcolor;
   
   //default size of title font and make sure user work with this with slider with Riverpod state Management 
   int font_size_title=10;

    //default size of subtitle font and make sure user work with this with slider with Riverpod state Management
    int font_size_subtitle=10;


    //default size of description font and make sure user work with this with slider with Riverpod state Management
    int font_size_description=10;

    //It is the Font map for using the font and User select the font in through this map
    Map<String, String> fontMap = {
    "Roboto": "Roboto-Black.ttf",
    "Oswald": "Oswald-Light.ttf",
    "Poppins": "Poppins-Black.ttf",
    "Outfit": "Outfit-Light.ttf",
    };



    // It is the Color map for selecting the color for user for pdf formatting
    Map<String, Color> colorMap = {
      "Red": Colors.red,
      "Blue": Colors.blue,
      "Green": Colors.green,
      "Yellow": Colors.yellow,
      "Orange": Colors.orange,
      "Purple": Colors.purple,
      "Pink": Colors.pink,
      "Brown": Colors.brown,
      "Black": Colors.black,
      "White": Colors.white,
      "Grey": Colors.grey,
      "Cyan": Colors.cyan,
      "Teal": Colors.teal,
      "Lime": Colors.lime,
      "Amber": Colors.amber,
      "Indigo": Colors.indigo,
    };

    final imageFile = ref.watch(setimage); // Listen to image changes
    final imageNotifier = ref.read(setimage.notifier); // Get notifier to modify state

    //It is the Slider value make sure of this set the width and height of the image select by  User
    double sliderValuewidth=10.0;
    double sliderValueheight=10.0;

    return
      SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12,),
              Text("Create Simple Pdf ",style: GoogleFonts.aBeeZee(fontSize: 20,fontWeight:FontWeight.w600),),
              SizedBox(height: 12,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                      elevation: 5,
                      child: Consumer(builder: (context,ref,child){
                        return TextField(
                          style: GoogleFonts.aBeeZee(fontSize: 13,fontWeight: FontWeight.normal),
                          controller: title,
                          decoration: InputDecoration(
                            hintStyle: GoogleFonts.aBeeZee(fontSize: 14,fontWeight: FontWeight.normal),
                            labelStyle: GoogleFonts.aBeeZee(fontSize: 14,fontWeight: FontWeight.normal),
                            labelText: 'Enter your pdf Title here ', // Placeholder text
                            hintText: 'Enter your pdf Title here ', // Hint text
                            border: OutlineInputBorder(), // A nice, solid border
                            prefixIcon: Icon(Icons.picture_as_pdf,color: Colors.green,), // Little icon at the beginning
                            suffixIcon: IconButton( // Icon at the end, can be interactive
                              icon: Icon(Icons.clear,color: Colors.green),
                              onPressed: () {




                                // Clear the text field, see?
                                //Managing the State of TextField With RiverPod with StateNotifier Provider
                                //Using thier own TextEditingController
                                ref.read(text_field_Manage.notifier).clearfields(title,context);


                              },
                            ),
                            filled: true, // Fills the background with color
                            fillColor: Colors.white, // Subtle background color
                            contentPadding: EdgeInsets.all(16.0), // Padding inside the field
                            enabledBorder: OutlineInputBorder( // Border when enabled
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder( // Border when focused
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        );
                      })
                  ),
                ),
              ),
              SizedBox(height:12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Card(
                    elevation: 5,
                    child: TextField(
                      controller: subtitle,
                      style: GoogleFonts.aBeeZee(fontSize: 13,fontWeight: FontWeight.normal),
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.aBeeZee(fontSize: 14,fontWeight: FontWeight.normal),
                        labelStyle: GoogleFonts.aBeeZee(fontSize: 14,fontWeight: FontWeight.normal),
                        labelText: 'Enter your pdf SubTitle here ', // Placeholder text
                        hintText: 'Enter your pdf SubTitle here ', // Hint text
                        border: OutlineInputBorder(), // A nice, solid border
                        prefixIcon: Icon(Icons.subtitles,color: Colors.green), // Little icon at the beginning
                        suffixIcon: IconButton( // Icon at the end, can be interactive
                          icon: Icon(Icons.clear,color: Colors.green),
                          onPressed: () {
                            // Clear the text field, see?
                            //Managing the State of TextField With RiverPod with StateNotifier Provider

                            ref.read(text_field_Manage.notifier).clearfields(subtitle,context);

                          },
                        ),
                        filled: true, // Fills the background with color
                        fillColor: Colors.white, // Subtle background color
                        contentPadding: EdgeInsets.all(16.0), // Padding inside the field
                        enabledBorder: OutlineInputBorder( // Border when enabled
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder( // Border when focused
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height:12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    elevation: 5,
                    child: TextField(
                      controller: description,
                      style: GoogleFonts.aBeeZee(fontSize: 13,fontWeight: FontWeight.normal),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.aBeeZee(fontSize: 14,fontWeight: FontWeight.normal),
                        labelStyle: GoogleFonts.aBeeZee(fontSize: 14,fontWeight: FontWeight.normal),
                        labelText: 'Enter your pdf Description', // Placeholder text
                        hintText: 'Enter your pdf Description ', // Hint text
                        border: OutlineInputBorder(), // A nice, solid border
                        prefixIcon: Icon(Icons.description,color: Colors.green), // Little icon at the beginning
                        suffixIcon: IconButton( // Icon at the end, can be interactive
                          icon: Icon(Icons.clear,color: Colors.green),
                          onPressed: () {
                            // Clear the text field, see?
                            //Managing the State of TextField With RiverPod with StateNotifier Provider
                            ref.read(text_field_Manage.notifier).clearfields(description,context);

                          },
                        ),
                        filled: true, // Fills the background with color
                        fillColor: Colors.white, // Subtle background color
                        contentPadding: EdgeInsets.all(16.0), // Padding inside the field
                        enabledBorder: OutlineInputBorder( // Border when enabled
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder( // Border when focused
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height:10),



              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text("Formatting of Pdf",style: GoogleFonts.aBeeZee(fontSize:16,fontWeight: FontWeight.bold ),)),
                  SizedBox(height: 10,),
                 Card(
                   child: ExpansionTile(title: Text("Select font ",style: GoogleFonts.aBeeZee(fontSize:16,fontWeight: FontWeight.w500 ),),
                    children: [
                      Container(
                        height: 200,
                        width: 300,
                        child: ListView.builder(itemBuilder: (context,index){
                          return Card(
                            child: ListTile(
                              onTap: (){
                                selectfont=fontMap[fontMap.keys.elementAt(index)];
                                print(selectfont);
                              },
                              title: Text(fontMap.keys.elementAt(index).toString()+" font",style: GoogleFonts.aBeeZee(fontSize:12,fontWeight: FontWeight.w500 )),
                            ),
                          );
                        },itemCount: fontMap.length,),
                      )
                    ],
                    ),
                 ),
                  SizedBox(height: 10,),
                  Card(
                    child: ExpansionTile(title: Text("Select color of text ",style: GoogleFonts.aBeeZee(fontSize:16,fontWeight: FontWeight.w500 ),),
                      children: [
                        Container(
                          height: 200,
                          width: 300,
                          child: ListView.builder(itemBuilder: (context,index){
                            return Card(
                              child: ListTile(
                                onTap: (){
                                  selectcolor=colorMap[colorMap.keys.elementAt(index)];
                                  print(colorMap.keys.elementAt(index).toString());
                                },
                                title: Text(colorMap.keys.elementAt(index).toString()+" Color",style: GoogleFonts.aBeeZee(fontSize:12,fontWeight: FontWeight.w500 )),
                             trailing: Container(
                               width: 15,
                               height: 15,
                               color: Color(colorMap.values.elementAt(index).value),
                             ),
                              ),
                            );
                          },itemCount: colorMap.length,),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 10,),
                  Card(

                    child: ExpansionTile(title:Text( "Set font size",style:GoogleFonts.aBeeZee(fontSize:16,fontWeight: FontWeight.w500,)),
                    children: [
                    Text("Set font Size of title in PDF"),
                    SizedBox(height: 12,),
                    Consumer(builder: (context,ref,child){
                      return   Slider(value: ref.watch(set_fontsize_of_title) ,
                          min: 10,
                          max: 65,
                          inactiveColor: Colors.green.shade500,
                          activeColor: Colors.blue.shade500,
                          thumbColor: Colors.amber.shade500,
                          label: "Set font size of title in PDF",

                          onChanged:(value){
                           font_size_title=value.toInt();
                           print(font_size_title);
                          ref.read(set_fontsize_of_title.notifier).set_font_size(value.toInt());
                          });
                    }),
                      Consumer(builder: (context, ref, child) {
                        return Text("Title font size  :- "+ref.watch(set_fontsize_of_title).toInt().toString(),style:GoogleFonts.aBeeZee(fontSize: 12));
                      }),



                      SizedBox(height: 12,),

                      Text("Set font Size of Subtitle in PDF",style:GoogleFonts.aBeeZee(fontSize: 12)),
                      SizedBox(height: 12,),
                      Consumer(builder: (context,ref,child){
                        return   Slider(value: ref.watch(set_fontsize_of_subtitle) ,
                            inactiveColor: Colors.green.shade500,
                            activeColor: Colors.blue.shade500,
                            thumbColor: Colors.amber.shade500,
                            min: 10,
                            max: 65,
                            label: "Set font size of title in PDF",

                            onChanged:(value){
                              font_size_subtitle=value.toInt();
                              print(font_size_subtitle);
                              ref.read(set_fontsize_of_subtitle.notifier).set_font_size(value.toInt());
                            });
                      }),
                      Consumer(builder: (context, ref, child) {
                        return Text("Subtitle font size  :- "+ref.watch(set_fontsize_of_subtitle).toInt().toString(),style:GoogleFonts.aBeeZee(fontSize: 12));
                      }),




                      SizedBox(height: 12,),

                      Text("Set font Size of description  in PDF",style:GoogleFonts.aBeeZee(fontSize: 12)),
                      SizedBox(height: 12,),
                      Consumer(builder: (context,ref,child){
                        return   Slider(
                            inactiveColor: Colors.green.shade500,
                            activeColor: Colors.blue.shade500,
                            thumbColor: Colors.amber.shade500,

                            value: ref.watch(set_fontsize_of_description) ,
                            min: 10,
                            max: 65,
                            label: "Set font size of title in PDF",

                            onChanged:(value){
                              font_size_description=value.toInt();
                              print(font_size_description);
                              ref.read(set_fontsize_of_description.notifier).set_font_size(value.toInt());
                            });
                      }),
                      Consumer(builder: (context, ref, child) {
                        return Text("description font size  :- "+ref.watch(set_fontsize_of_description).toInt().toString(),style:GoogleFonts.aBeeZee(fontSize: 12));
                      }),
                    ],
                    ),
                  )


                  ,
                  SizedBox(height: 12,),

                  //This is Responsible for setting the Font Weight in PDF
                  Card(

                    child: ExpansionTile(
                      title: Text("Set font Weight ",style: GoogleFonts.aBeeZee(fontSize: 15),),
                      children: [
                        	Text("Set font Weight of title in Pdf"),
                          SizedBox(height: 8,),
                              // Slider wrapped inside Consumer
                        Consumer(
                          builder: (context, ref, child) {
                            final fontWeightIndex = ref.watch(fontWeightProvider);

                            return Slider(
                              thumbColor: Colors.amber.shade500,
                              inactiveColor: Colors.green.shade500,
                              activeColor: Colors.blue.shade500,
                              min: 0,
                              max: 8, // Since we have 9 font weights (index 0 to 8)
                              divisions: 8, // Steps of 1 (mapped to 100–900)
                              value: fontWeightIndex.toDouble(),
                              onChanged: (newValue) {
                                ref.read(fontWeightProvider.notifier).setFontWeight(newValue.toInt());
                                print("Slider Value: ${newValue.toInt()}");
                                print("Stored Index: ${ref.watch(fontWeightProvider)}");
                                set_title_fontweight=newValue.toInt();
                              },
                            );
                          },
                        ),

                        SizedBox(height: 8),

                    // ✅ Wrap Text widget in Consumer
                        Consumer(
                          builder: (context, ref, child) {
                            final fontWeightIndex = ref.watch(fontWeightProvider);
                            return Text(
                              "Font Weight: w${fontWeights[fontWeightIndex].value}",
                              style: TextStyle(fontSize: 12),
                            );
                          },
                        ),

                      ],
                    ),
                  )


                  ,
                  SizedBox(height:15),
                  Center(child: Text("Set Image here ",style:GoogleFonts.aboreto(fontWeight:FontWeight.bold,fontSize: 15))),

                  SizedBox(height: 15,),

                  //here We select the image by the camera and by Gallery
                  Center(
                    child: imageFile == null
                        ? Text(
                      "No Image Selected",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                        : Card(
                      elevation: 5, // ✅ Slightly stronger elevation for a shadow effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // ✅ Matches border radius
                      ),
                      child: Consumer(
                        builder:(Context,ref , child){
                          return Container(
                            height: ref.watch(sliderProviderheight),
                            width: ref.watch(sliderProviderwidth),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 2), // ✅ Improved border thickness
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2), // ✅ Soft shadow effect
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                imageFile!,
                                fit: BoxFit.cover, // ✅ Ensures full coverage of the container
                              ),
                            ),
                          );
                        }
                      )
                    ),
                  )
                  ,
                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: ()=>imageNotifier.setimagebycamera(), child: Text("Camera",style: GoogleFonts.aboreto(fontSize: 15),),),
                      SizedBox(width: 12,),
                      ElevatedButton(onPressed: () =>imageNotifier.setimagebygallery(), child: Text("Gallery",style: GoogleFonts.aboreto(fontSize: 15)),),

                    ],
                  ),

                ],
              ),



              SizedBox(height:10),
              ExpansionTile(
               title: Text("Set Width of Image ",style:GoogleFonts.aboreto(fontSize: 15)),
                children: [
                Consumer(builder: (context,ref,child){
                  final sliderValue = ref.watch(sliderProviderwidth); // Watch for changes
                  return                   Slider(
                    value: ref.watch(sliderProviderwidth),
                    inactiveColor: Colors.blue.shade500,
                    activeColor: Colors.green.shade500,
                    thumbColor: Colors.yellow.shade500,
                    min: 0,
                    max: 300,
                    onChanged: (newValue) {
                      ref.read(sliderProviderwidth.notifier).update((state)=>newValue); // Update state
                    },
                  );
                })
                ],
              ),

              SizedBox(height:10),
              ExpansionTile(
                title: Text("Set Height of Image ",style:GoogleFonts.aboreto(fontSize: 15)),
                children: [
                  Consumer(builder: (context,ref,child){
                    final sliderValue = ref.watch(sliderProviderheight); // Watch for changes
                    return                   Slider(
                      value: ref.watch(sliderProviderheight),
                      min: 0,
                      max: 300,
                      inactiveColor: Colors.blue.shade500,
                      activeColor: Colors.green.shade500,
                      thumbColor: Colors.yellow.shade500,
                      onChanged: (newValue) {
                        ref.read(sliderProviderheight.notifier).update((state)=>newValue); // Update state
                      },
                    );
                  })
                ],
              ),


              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Step 1: Check if an image is selected
                      if (imageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select an image first!")),
                        );
                        return; // 🚀 Prevents further execution
                      }

                      Uint8List? imageBytes;

                      try {
                        // Step 2: Safely read the image file
                        imageBytes = await imageFile!.readAsBytes();
                      } catch (e) {
                        print("Error reading image file: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error reading image file.")),
                        );
                        return; // 🚀 Prevents further execution
                      }

                      // Step 3: Check if all text fields are filled
                      if (title.text.isNotEmpty &&
                          subtitle.text.isNotEmpty &&
                          description.text.isNotEmpty) {

                        // Step 4: Call PDF Generation Function
                        await pdf_gen.pdfgen(
                            title.text.trim(),
                            subtitle.text.trim(),
                            description.text.trim(),
                            context,
                            selectfont ?? "Roboto-Black.ttf",  // Default font
                            selectcolor ?? Colors.black,       // Default color
                            font_size_title,
                            font_size_subtitle,
                            font_size_description,
                            set_title_fontweight ?? 4,         // Default font weight
                            imageBytes
                        ).then((value) {
                          ref.refresh(pdf_view);
                        });

                      } else {
                        // Show Snackbar for missing details
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Failure!',
                            message: 'Please Fill all details.',
                            contentType: ContentType.failure, // success, warning, help, failure
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Text("Generate PDF"),
                  ),

                ],
              )
            ],
          ),
        ),
      );

  }





}

