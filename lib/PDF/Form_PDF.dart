import 'package:flutter/material.dart'; // Import the function
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Future<void> createFillablePdf() async {
  // CREATE THE INSTANCE MAKE SURE OF THIS
  PdfDocument document = PdfDocument();
  PdfPage page = document.pages.add();

  // Define the font in PDF
  PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 16); // Updated font for better readability

  double yPosition = 50.0; // Initial Y position for form fields

  // Draw title for the form
  page.graphics.drawString(
    'User Information Form',
    PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(150, yPosition, 400, 30),
  );

  yPosition += 40;

  // Create the text field for Name
  PdfTextBoxField nameField = PdfTextBoxField(
    page,
    'Name',
    Rect.fromLTWH(50, yPosition, 400, 20),
  );
  nameField.tooltip = 'Enter your name';
  nameField.font = font;
  document.form.fields.add(nameField);

  yPosition += 40;

  // Create the text field for Email
  PdfTextBoxField emailField = PdfTextBoxField(
    page,
    'Email',
    Rect.fromLTWH(50, yPosition, 400, 20),
  );
  emailField.tooltip = 'Enter your Email';
  emailField.font = font;
  document.form.fields.add(emailField);

  yPosition += 40; // Fixed missing increment

  // Create the text field for Phone
  PdfTextBoxField phoneField = PdfTextBoxField(
    page,
    'Phone',
    Rect.fromLTWH(50, yPosition, 400, 20),
  );
  phoneField.tooltip = 'Enter your Phone Number';
  phoneField.font = font; // Fixed font assignment
  document.form.fields.add(phoneField);

  yPosition += 40;

  // Create a checkbox for "Agree to Terms"
  PdfCheckBoxField agreeCheckBox = PdfCheckBoxField(
    page,
    'Agree',
    Rect.fromLTWH(50, yPosition, 20, 20), // Adjusted width for checkbox
  );
  agreeCheckBox.tooltip = 'Agree to terms';
  document.form.fields.add(agreeCheckBox);

  // Add label next to checkbox
  page.graphics.drawString(
    'Agree to Terms',
    font,
    bounds: Rect.fromLTWH(80, yPosition, 400, 20),
  );

  yPosition += 40;

  // Create a dropdown field for Gender
  PdfComboBoxField genderField = PdfComboBoxField(
    page,
    'Gender',
    Rect.fromLTWH(50, yPosition, 400, 20),
  );
  genderField.tooltip = 'Select your Gender';
  genderField.items.add(PdfListFieldItem('Male', 'Male'));
  genderField.items.add(PdfListFieldItem('Female', 'Female'));
  genderField.items.add(PdfListFieldItem('Other', 'Other'));

  genderField.selectedIndex = 0;
  document.form.fields.add(genderField);

  // Save the PDF with form fields
  await savepdf(document);
}

// Function for filling the PDF form
Future<void> fillpdfform(
    String name, String email, String phone, bool agree, String gender) async {
  Directory directory = await getApplicationDocumentsDirectory();
  String path = '${directory.path}/fillable_form.pdf';
  File file = File(path);

  if (!await file.exists()) {
    print("❌ ERROR: Fillable PDF NOT FOUND! Call 'createFillablePdf()' first.");
    return;
  }

  List<int> byte = await file.readAsBytes();
  PdfDocument document = PdfDocument(inputBytes: byte);

  // Fill text fields
  (document.form.fields[0] as PdfTextBoxField).text = name;
  (document.form.fields[1] as PdfTextBoxField).text = email;
  (document.form.fields[2] as PdfTextBoxField).text = phone;

  // Fill checkbox (true = checked, false = unchecked)
  (document.form.fields[3] as PdfCheckBoxField).isChecked = agree;

  // Fill dropdown
  PdfComboBoxField genderField = document.form.fields[4] as PdfComboBoxField;
  for (int i = 0; i < genderField.items.count; i++) {
    if (genderField.items[i].value == gender) {
      genderField.selectedIndex = i;
      break;
    }
  }

  // Save the filled form as a new PDF
  await savepdf(document);
}

// Function to save the PDF
final storage = GetStorage();
const String pdfListKey = "pdf_list"; // Key for storing PDF paths

Future<void> savepdf(PdfDocument document) async {
  List<int> bytes = await document.save();
  document.dispose();

  Directory directory = Directory('/storage/emulated/0/Download');
  if (!await directory.exists()) {
    directory = await getApplicationDocumentsDirectory();
  }

  String path = '${directory.path}/fillable_form.pdf';
  File file = File(path);
  await file.writeAsBytes(bytes);


  //Retrieve Already insterested PDF FROM  GetxStorage

  List<String>list_of_pdf=storage.read<List>("pdf_list")?.cast<String>()??[];

  //Add new pdf file in
  list_of_pdf.add(file.path);

  //Insert the List in Getx Storage
  storage.write(pdfListKey, list_of_pdf).then((value){
    print("\n Storage of PDF is Done Successfully ");
  });
  //This code is Responsible for the Deletion in the Code make sure of this

  print('✅ PDF saved at: $path');
}

// UI for filling the form
class FillPdfScreen extends StatefulWidget {
  const FillPdfScreen({super.key});

  @override
  _FillPdfScreenState createState() => _FillPdfScreenState();
}

class _FillPdfScreenState extends State<FillPdfScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool agreeToTerms = false;
  String selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fill PDF Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align left
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  const Text("Agree to Terms"),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Select Gender"),
              DropdownButton<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                items: ["Male", "Female", "Other"]
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  fillpdfform(
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                    agreeToTerms,
                    selectedGender,
                  );
                },
                child: const Text("Fill & Save PDF"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await createFillablePdf();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FillPdfScreen(),
  ));
}
