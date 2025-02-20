import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfHighlightScreen extends StatefulWidget {
  final String pdfPath;
  PdfHighlightScreen({required this.pdfPath});

  @override
  _PdfHighlightScreenState createState() => _PdfHighlightScreenState();
}

class _PdfHighlightScreenState extends State<PdfHighlightScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfTextSelectionChangedDetails? selectedTextDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Highlighter"),
        actions: [
          IconButton(
            icon: Icon(Icons.highlight, color: Colors.white),
            onPressed: () async {
              if (selectedTextDetails != null && selectedTextDetails!.selectedText!.isNotEmpty) {
                await _highlightSelectedText();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No text selected!")),
                );
              }
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(widget.pdfPath),
        key: _pdfViewerKey,
        onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
          setState(() {
            selectedTextDetails = details;
          });
        },
      ),
    );
  }

  Future<void> _highlightSelectedText() async {
    try {
      File pdfFile = File(widget.pdfPath);
      List<int> bytes = await pdfFile.readAsBytes();
      PdfDocument document = PdfDocument(inputBytes: bytes);

      // Apply highlight annotation
      PdfPage page = document.pages[0]; // Assume highlight is on the first page

      PdfTextMarkupAnnotation highlightAnnotation = PdfTextMarkupAnnotation(
        Rect.fromLTWH(100, 100, 200, 20), // Dummy position (Needs mapping from selection)
        PdfTextMarkupAnnotationType.highlight.toString()
      );
      highlightAnnotation.text = selectedTextDetails!.selectedText!;
      highlightAnnotation.color = PdfColor(1, 1, 0); // Yellow highlight
      page.annotations.add(highlightAnnotation);

      // Save the updated PDF
      Directory directory = await getApplicationDocumentsDirectory();
      String newPdfPath = "${directory.path}/Highlighted_Document.pdf";
      File newFile = File(newPdfPath);
      await newFile.writeAsBytes(await document.save());

      document.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Highlighted text saved! Open the new PDF.")),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to highlight text.")),
      );
    }
  }
}
