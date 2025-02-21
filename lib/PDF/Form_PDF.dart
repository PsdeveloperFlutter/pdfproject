import 'package:flutter/material.dart'; // Import the function
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Future<void> createFillablePdf() async {
  // CREATE THE INSTANCE MAKE SURE OF THIS
  // Create a new PDF document
  PdfDocument document = PdfDocument();

  // Add the page in document instance make sure of this
  PdfPage page = document.pages.add();

  // Define the font in PDF (Remove 'await' since it's not needed)
  PdfFont font = PdfStandardFont(PdfFontFamily.courier, 20);

  double yPosition = 50.0; // Initial Y position for form fields

  // Draw a title for the form
  page.graphics.drawString(
    'User Information Form',
    PdfStandardFont(PdfFontFamily.courier, 18, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(150, yPosition, 400, 30),
  );

  yPosition += 40;

  // Create the text field on PDF (Make sure to add it to the document)
  PdfTextBoxField nameField = PdfTextBoxField(
      page, 'Name', Rect.fromLTWH(50, yPosition, 400, 20));
  nameField.tooltip = 'Enter your name';
  nameField.font = font;
  document.form.fields.add(nameField);

  yPosition += 40;


  //Create a text Field for the Email
  PdfTextBoxField emailField = PdfTextBoxField(page, 'Email', Rect.fromLTWH(50, yPosition, 400, 20));
  emailField.tooltip='Enter your Email';
  emailField.font=font;
  document.form.fields.add(emailField);

  // Create a text field for "Phone"

  PdfTextBoxField phoneField=PdfTextBoxField(page, 'Phone', Rect.fromLTWH(50, yPosition, 400, 20));
  phoneField.tooltip='Enter your Phone Number';
  emailField.font=font;
  document.form.fields.add(phoneField);

  yPosition+=40;


  // Create a checkbox for "Agree to Terms"


  PdfCheckBoxField agreeCheckBox=PdfCheckBoxField(page, 'Agree',  Rect.fromLTWH(50, yPosition, 400, 20));
  agreeCheckBox.tooltip = 'Agree to terms';
  document.form.fields.add(agreeCheckBox);
  page.graphics.drawString('Agree to Terms', font, bounds: Rect.fromLTWH(70, yPosition, 400, 20));

  yPosition += 40;



  // Create a dropdown field for Gender


  PdfComboBoxField genderField=PdfComboBoxField(page, 'Gender',Rect.fromLTWH(50, yPosition, 400, 20));
  genderField.tooltip='Select your Gender ';
  genderField.items.add(PdfListFieldItem('0', 'Male'));
  genderField.items.add(PdfListFieldItem('1', 'Female'));
  genderField.items.add(PdfListFieldItem('2', 'Other'));

  genderField.selectedIndex = 0;
  document.form.fields.add(genderField);

  // Save the PDF with form fields
  await savepdf(document);
}


//This is the function for the filling the pdf make sure of this

Future<void>fillpdfform(String name, String email, String phone , bool agree , String gender)async{
  // Load the existing fillable PDF
  Directory directory = await getApplicationDocumentsDirectory();
  String path = '${directory.path}/fillable_form.pdf';
  File file = File(path);

  if (await file.exists()) {
    print("✅ Fillable PDF found at: $path");
  } else {
    print("❌ ERROR: Fillable PDF NOT FOUND! Check if 'createFillablePdf()' was called.");
  }

  List<int>byte=await file.readAsBytes();
  PdfDocument document=PdfDocument(inputBytes: byte);



  // Fill text fields
  (document.form.fields[0] as PdfTextBoxField).text = name;
  (document.form.fields[1] as PdfTextBoxField).text = email;
  (document.form.fields[2] as PdfTextBoxField).text = phone;



  // Fill checkbox (true = checked, false = unchecked)
  (document.form.fields[3] as PdfCheckBoxField).isChecked=agree;

   //Fill dropdown
  PdfComboBoxField genderField = document.form.fields[4] as PdfComboBoxField;
  int indexdrop=-1;//default make sure of this
  for(int i=0;i<genderField.items.count;i++){
    if(genderField.items[i].value==gender){
      indexdrop=i;
      break;
    }
  }
  if(indexdrop==-1){
    genderField.selectedIndex=indexdrop;
  }

  // Save the filled form as a new PDF
  await savepdf(document);
}



//This is the Function for the save Pdf make sure of this

final storage = GetStorage();
const String pdfListKey = "pdf_list";  // Key for storing PDF paths

Future<void> savepdf(PdfDocument document) async {
  List<int> bytes = await document.save();
  document.dispose();

  // Get the directory to save the file
  Directory directory = Directory('/storage/emulated/0/Download'); // Saving in Downloads folder
  if (!await directory.exists()) {
    directory = await getApplicationDocumentsDirectory();  // Fallback
  }

  // Define file path
  String path = '${directory.path}/fillable_form.pdf';
  File file = File(path);
  await file.writeAsBytes(bytes);

  // Read existing PDF list from GetStorage
  await Future.delayed(Duration(seconds: 5));  // Ensures data is read properly
  List<dynamic>? storedata = storage.read(pdfListKey);
  List<String> data_pdf = storedata?.map((e) => e.toString()).toList() ?? [];

  // Add the new PDF file path
  data_pdf.add(path);
  storage.write(pdfListKey, data_pdf);  // Save to GetStorage

  print('✅ PDF saved at: $path');
}




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
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
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
                  const Text("Agree to Terms")
                ],
              ),
              DropdownButton<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                items: ["Male", "Female", "Other"]
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
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


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await createFillablePdf();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FillPdfScreen (),));
}