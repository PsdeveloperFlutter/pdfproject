import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'Drawing at PDF.dart';

double xPosition=2.0;
double yPosition=2.0;
class AnnotatePDFScreen extends StatefulWidget {
  final String pdfPath;
  const AnnotatePDFScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _AnnotatePDFScreenState createState() => _AnnotatePDFScreenState();
}

class _AnnotatePDFScreenState extends State<AnnotatePDFScreen> {
  late String currentPdfPath;

  @override
  void initState() {
    super.initState();
    currentPdfPath = widget.pdfPath; // Initially, show the original PDF
  }

  // ✅ Function to add signature and reload PDF
  Future<void> addSignatureToPDF() async {
    try {
      // ✅ Load the existing PDF file
      File pdfFile = File(currentPdfPath);
      Uint8List pdfBytes = await pdfFile.readAsBytes();
      PdfDocument document = PdfDocument(inputBytes: pdfBytes);

      // ✅ Get the saved signature file
      final directory = await getApplicationDocumentsDirectory();
      String signaturePath = '${directory.path}/signature.png';
      File signatureFile = File(signaturePath);

      if (!signatureFile.existsSync()) {
        print("❌ Error: Signature file not found!");
        return;
      }

      // ✅ Load the signature image
      Uint8List signatureBytes = await signatureFile.readAsBytes();
      PdfBitmap signatureImage = PdfBitmap(signatureBytes);

      // ✅ Get the first page of the PDF
      PdfPage page = document.pages[0];

      // ✅ Define position for signature (bottom-right corner)
      double xPosition = page
          .getClientSize()
          .width - 150; // Adjust position
      double yPosition = page
          .getClientSize()
          .height - 100;

      // ✅ Draw the signature image on the PDF
      page.graphics.drawImage(
          signatureImage, Rect.fromLTWH(xPosition, yPosition, 100, 50));

      // ✅ Save the modified PDF
      String outputPdfPath = '${directory.path}/signed_document.pdf';
      await File(outputPdfPath).writeAsBytes(await document.save());

      print("✅ Signature added successfully! Saved at: $outputPdfPath");

      document.dispose();

      //After that add the file in the Getx storage
      final GetStorage storage = GetStorage();
      const String pdflistkey = "pdf_list";
      //Fetch the list from the getx storage
      List<String> listofpdf = storage.read<List>("pdf_list")?.cast<String>() ??
          [];

      int indexvalue = listofpdf.indexOf(currentPdfPath);
      if (listofpdf.indexOf(currentPdfPath) != -1) {
        listofpdf[indexvalue] = outputPdfPath;
      }
      else {
        listofpdf.add(currentPdfPath); // Add if not found (failsafe)
      }
      storage.write(pdflistkey, listofpdf).
      then((value) => print("\n✅ Storage updated with new signed PDF!"));


      // ✅ Update UI to display the modified PDF
      setState(() {
        currentPdfPath = outputPdfPath; // Reload with updated PDF
      });
    } catch (e) {
      print("❌ Error adding signature to PDF: $e");
    }
  }


  // ✅ Store comments as a list of maps
  List<Map<String, dynamic>> comments = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        title: Text("Annotate PDF", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () async {
              await addSignatureToPDF(); // ✅ Update the displayed PDF after signing
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SfPdfViewer.file(
            onTap: (details){
              _handleTap(details); //handle the User tap and get the Coordinate of the Position
            }
              ,
              File(currentPdfPath), // ✅ This will show the updated PDF
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.blue.shade500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.highlight, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement Highlight functionality
                  },
                ),


                IconButton(
                  icon: Icon(Icons.comment, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement Add Comment functionality
                    _showCommentDialog(context, xPosition, yPosition);
                 },
                ),


                IconButton(
                  icon: Icon(Icons.brush, color: Colors.white),
                  onPressed: () {
                    // ✅ Navigate to Signature Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignatureScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  //show the comment dialog box for enter the text to pdf

// Show the comment dialog box for entering text to the PDF
  void _showCommentDialog(BuildContext context, double x, double y) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Comment"),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: "Enter your comment"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_commentController.text.isNotEmpty) {
                  await addCommentToPDF(_commentController.text, x, y);
                  setState(() {}); // Refresh UI to show updated PDF
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  //Get the position from the user and set the text here this is handle the position from the pdf

  // Function to detect tap on PDF and show the comment dialog
  void _handleTap(PdfGestureDetails details) {
    setState(() {
      xPosition = details.position.dx;  // Get X position
      yPosition = details.position.dy;  // Get Y position
    });
    print("${xPosition + yPosition}");
  }



  //add the comment in pdf
// Add the comment at the tapped position in the PDF
  Future<void> addCommentToPDF(String comment, double xPosition, double yPosition) async {
    try {
      // Load the existing PDF file
      File pdfFile = File(currentPdfPath);
      Uint8List pdfBytes = await pdfFile.readAsBytes();
      PdfDocument document = PdfDocument(inputBytes: pdfBytes);

      // Get the first page of the PDF
      PdfPage page = document.pages[0];

      // Add text annotation (comment)
      PdfTextElement textElement = PdfTextElement(
        text: comment,
        font: PdfStandardFont(PdfFontFamily.helvetica, 14),
      );

      // Draw text on the PDF at the tapped position
      textElement.draw(page: page, bounds: Rect.fromLTWH(xPosition, yPosition, 300, 20));

      // Save the modified PDF
      final directory = await getApplicationDocumentsDirectory();
      String outputPdfPath = '${directory.path}/commented_document.pdf';
      await File(outputPdfPath).writeAsBytes(await document.save());

      print("✅ Comment added successfully! Saved at: $outputPdfPath");

      document.dispose();

      // Update the current displayed PDF
      setState(() {
        currentPdfPath = outputPdfPath;
      });
    } catch (e) {
      print("❌ Error adding comment to PDF: $e");
    }
  }


}