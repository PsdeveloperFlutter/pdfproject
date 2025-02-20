import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ExtractAndEditPDFScreen extends StatefulWidget {
  final String pdfPath;
  ExtractAndEditPDFScreen({required this.pdfPath});

  @override
  _ExtractAndEditPDFScreenState createState() => _ExtractAndEditPDFScreenState();
}

class _ExtractAndEditPDFScreenState extends State<ExtractAndEditPDFScreen> {
  late TextEditingController _textController;
  bool _isLoading = true;
  String extractedText = "";
  File? updatedPdfFile;

  @override
  void initState() {
    super.initState();
    _extractText();
  }

  /// Extract text from PDF
  Future<void> _extractText() async {
    try {
      File file = File(widget.pdfPath);
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      setState(() {
        _textController = TextEditingController(text: extractedText);
        _isLoading = false;
      });
    } catch (e) {
      print("Error extracting text: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Save the modified text as a new PDF and reload the viewer
  Future<void> _saveUpdatedPDF() async {
    try {
      setState(() => _isLoading = true);

      // Create a new PDF document
      final PdfDocument document = PdfDocument();
      document.pages.add().graphics.drawString(
        _textController.text,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
      );

      // Get the file path
      final Directory dir = await getApplicationDocumentsDirectory();
      final String newPath = '${dir.path}/updated_pdf.pdf';
      final File file = File(newPath);

      // Save new PDF
      await file.writeAsBytes(await document.save());
      document.dispose();

      setState(() {
        updatedPdfFile = file;
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF Updated Successfully!")));
    } catch (e) {
      print("Error saving PDF: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View & Edit PDF")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading while extracting
          : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PDF Viewer
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: SfPdfViewer.file(updatedPdfFile ?? File(widget.pdfPath)), // ✅ Refreshes after saving
            ),
          ),
          SizedBox(height: 10),

          // Editable Extracted Text
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Edit Extracted Text",
                ),
              ),
            ),
          ),

          SizedBox(height: 10),
          Text("Style Pdf Text", style: GoogleFonts.aboreto(fontSize: 15)),

          // Save Button
          ElevatedButton(
            onPressed: () async {
              await _saveUpdatedPDF();
              setState(() {}); // ✅ Refresh UI after saving
            },
            child: Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}
