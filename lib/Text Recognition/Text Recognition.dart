import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
class TextRecognition extends StatefulWidget {
  const TextRecognition({Key? key}) : super(key: key);

  @override
  State<TextRecognition> createState() => _TextRecognitionState();
}

class _TextRecognitionState extends State<TextRecognition> {
  XFile? image;

  // 📌 Pick Image from Camera
  Future pickImageCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile; // ✅ Update UI
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Selected from Camera")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Image Selected")),
      );
    }
  }

  // 📌 Pick Image from Gallery
  Future pickImageGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile; // ✅ Update UI
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Selected from Gallery")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Image Selected")),
      );
    }
  }

  // 📌 Fetch Text from Image through Google ML kit

  Future<void>process_text_from_image(File imagefile)async{

    //convert the image file to input Image
    final inputImage=InputImage.fromFile(imagefile);

    //set text Recognition Instance
    final textRecognizer = GoogleMlKit.vision.textRecognizer();


    //Recognize text
    final RecognizedText recognizedText=await textRecognizer.processImage(inputImage);

    //print the TEXT TO CONSOLE
    print(recognizedText.text.toString());

    setState(() {
      extractedText=recognizedText.text.toString();
    });
    textRecognizer.close(); //Close here

  }
  final FlutterTts flutterTts = FlutterTts(); // ✅ Initialize TTS


  String extractedText = "Extracted text will appear here"; // ✅ Add state variable




  //Speak Text functionality
  Future<void> speakText() async {
    if (extractedText.isNotEmpty && extractedText != "Extracted text will appear here") {
      await flutterTts.speak(extractedText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("No text to speak!", style: GoogleFonts.aBeeZee())),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Recognition')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼️ Image Display
            Card(
              elevation: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.white,
                  child: image == null
                      ?  Center(child: Text("No Image Selected",style: GoogleFonts.aBeeZee(fontSize: 15),))
                      : Image.file(File(image!.path), fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📷 Image Selection Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child:  Text('Camera',style: GoogleFonts.aBeeZee(fontSize: 15),),
                  onPressed: pickImageCamera,
                ),
                ElevatedButton(
                  child: Text('Gallery',style: GoogleFonts.aBeeZee(fontSize: 15),),
                  onPressed: pickImageGallery,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📝 Placeholder for Fetch Text Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                GestureDetector(
                  onTap: (){
                    if(image==null){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Select Image First",style: GoogleFonts.aboreto(fontSize: 15),)));
                    }
                    else {

                      process_text_from_image(File(image!.path));
                    }
                  },
                  child: Text(
                    "Fetch Text",
                    style: GoogleFonts.aBeeZee(fontSize: 15),
                  ),
                ),

                GestureDetector(
                    onTap: ()async{
                      await flutterTts.setLanguage("en-US");
                      await flutterTts.setPitch(1.0);
                      await flutterTts.setSpeechRate(0.5);
                      speakText();
                      },
                    child: Text("Listen Text",style: GoogleFonts.aboreto(fontSize: 15),))
              ],
            ),
            SizedBox(height: 12,),



            // 🔹 Display Extracted Text
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  extractedText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.aBeeZee(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



}

void main() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TextRecognition()));
}
