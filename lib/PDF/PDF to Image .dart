import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> convertPdfToImage(String pdfPath, int pageNumber) async {
  final doc = await PdfDocument.openFile(pdfPath);
  final page = await doc.getPage(pageNumber);

  final image = await page.render(
    width:200,
    height:200,

  );

  if (image == null || image.pixels.isEmpty) {
    print("Error: Image rendering failed.");
    return null;
  }

  final Uint8List imageBytes = image.pixels; // Corrected: Use `pixels` instead of `bytes`

  final appDocDir = await getApplicationDocumentsDirectory();

  // Create the 'Imagepdfapp' folder if it doesn't exist
  final folderPath = '${appDocDir.path}/Imagepdfapp';
  final folder = Directory(folderPath);
  if (!await folder.exists()) {
    // If the folder doesn't exist, create it
    await folder.create(recursive: true);
  }

  // Define the image file path inside the folder
  final imagePath = '$folderPath/pdf_page_$pageNumber.png';
  final imageFile = File(imagePath);

  // Write the image bytes to the file
  await imageFile.writeAsBytes(imageBytes);

  print("Image saved at: $imagePath");
  print("Saved PDF page as image: $imagePath");
  return imageFile;
}
