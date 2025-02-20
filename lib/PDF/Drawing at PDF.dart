import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'Riverpod_State_Management/StatemanagementEditFile.dart';

List<List<Offset>> strokes = [];  // List to store strokes
List<Offset> currentStroke = [];   // List to store current stroke


// ✅ Default signature color
Color selectedColor = Colors.black;


class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

  Future<String?> saveSignature() async {
    try {
      // ✅ Capture the signature as an image
      final ui.Image? image = await signaturePadKey.currentState?.toImage();
      if (image == null) {
        print("❌ Error: Signature image is null.");
        return null;
      }

      // ✅ Convert the image to byte data in PNG format
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print("❌ Error: Failed to convert image to byteData.");
        return null;
      }

      // ✅ Convert ByteData to Uint8List
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // ✅ Save the image as a file
      final directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/signature.png';
      File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      print("✅ Signature successfully saved at: $filePath");
      return filePath; // Return saved file path
    } catch (e) {
      print("❌ Error capturing signature: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Draw on PDF")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Signature Pad Widget
            Consumer(builder: (context,ref,child){return
              Container(
                height: 500,
                color: Colors.white,
                child: SfSignaturePad(
                  key: signaturePadKey,
                  strokeColor:  ref.watch(colorProvider),
                  backgroundColor: Colors.white,
                  maximumStrokeWidth: ref.watch(strokewidthvalue),
                  minimumStrokeWidth: ref.watch(strokewidthvalue),

                ),
              );
            }),
            SizedBox(height: 15),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.save,color: Colors.deepPurple,),
                      TextButton(
                        onPressed: () async {
                          String? savedPath = await saveSignature();
                          if (savedPath != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Signature saved successfully!")),
                            );
                          }
                        },
                        child: Text("Save",
                            style: GoogleFonts.aboreto(
                                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(onPressed: (){
                        // Show the color picker dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ColorPickerDialog();
                          },
                        );
                      }, icon: Icon(Icons.color_lens,color: Colors.deepPurple,)),
                      Text("Set Colour ",style: GoogleFonts.cabinCondensed(fontSize: 15),)
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.delete,color: Colors.deepPurple,),
                      TextButton(
                        onPressed: () {
                          signaturePadKey.currentState!.clear();
                        },
                        child: Text("Clear",
                            style: GoogleFonts.aboreto(
                                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 12,),

            SizedBox(height: 12,),

           Column(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Text("Set stroke Width",style: GoogleFonts.aboreto(fontSize: 15),),
               SizedBox(height: 12,),
               Consumer(builder: (context,ref,child){
                 return  Slider(
                   thumbColor: Colors.green.shade500,
                   inactiveColor: Colors.blue.shade500,
                   activeColor: Colors.purple.shade500,
                   value: ref.watch(strokewidthvalue),
                   min: 1.0, // Minimum value for stroke width
                   max: 10.0, // Maximum value for stroke width
                   divisions: 9, // Optional: Makes the slider snap to integer values
                   onChanged: (double newValue) {
                    ref.read(strokewidthvalue.notifier).updatestrokewidth(newValue);
                    print(ref.watch(strokewidthvalue.notifier).showstrokewidtvalue());
                   },
                 );
               }),
             ],
           )


          ],
        ),
      ),
    );
  }
}
//This code End here make sure of this










//This is for the Selection of the Colour picker
Widget colorOption(Color color, BuildContext context, WidgetRef ref) {
  return GestureDetector(
    onTap: () {
      // Directly update the color state using Riverpod (using ref.read)
      ref.read(colorProvider.notifier).updatecolour(color);

      // Optionally, close the dialog after selecting a color (if it's in a dialog)
      Navigator.pop(context);
    },
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
      ),
    ),
  );
}







//This is the Class for the Colour picker make sure of this
class ColorPickerDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text("Pick Signature Color",style: GoogleFonts.aboreto(fontSize: 15),),
      content: Wrap(
        spacing: 15,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          colorOption(Colors.black, context, ref),
          colorOption(Colors.blue, context, ref),
          colorOption(Colors.red, context, ref),
          colorOption(Colors.green, context, ref),
          colorOption(Colors.purple, context, ref),
          colorOption(Colors.orange, context, ref),
        ],
      ),
    );
  }
}
