import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
@override
\_HomePageState createState() => \_HomePageState();
}

class \_HomePageState extends State<HomePage> {
int \_currentStep = 0;
Map<String, dynamic>? apiData;
String? mobileNumber;
String? family_id;
String? member_id;
File? \_image;
final ImagePicker \_picker = ImagePicker();

@override
void initState() {
super.initState();
\_loadApiResponse();
}

Future<void> \_loadApiResponse() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
final String? responseJson = prefs.getString('api_response');
print(responseJson);
final String? mobile = prefs.getString('mobile_number');

    if (responseJson != null) {
      Map<String, dynamic> responseData = jsonDecode(responseJson);
      if (mounted) {
        setState(() {
          mobileNumber = mobile;
          family_id = responseData['familyID'] ?? 'N/A';
          member_id = responseData['memberID'] ?? 'N/A';
          apiData = responseData;
        });
      }
      _storeFirstStep();
    }

}

Future<void> \_storeFirstStep() async {
var url = Uri.http('127.0.0.1:8000', '/api/store/first/step');
var parameters = {
'mobileNumber': mobileNumber ?? '',
'family_id': family_id ?? '',
'member_id': member_id ?? '',
};
try {
var response = await http.post(url, body: parameters);
if (response.statusCode == 200) {
print("✅ Record Saved Successfully");
} else {
print("API Error: ${response.statusCode}");
}
} catch (e) {
print("Exception: $e");
}
}

Future<void> \_pickImage() async {
final pickedFile = await \_picker.pickImage(source: ImageSource.gallery);
if (pickedFile != null) {
setState(() {
\_image = File(pickedFile.path);
});
}
}

Future<void> \_handleSubmit() async {
if (\_image == null) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
return;
}

    var url = Uri.http('127.0.0.1:8000', '/api/submit/step');
    var request = http.MultipartRequest('POST', url)
      ..fields['mobileNumber'] = mobileNumber ?? ''
      ..fields['family_id'] = family_id ?? ''
      ..fields['member_id'] = member_id ?? ''
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Data Submitted Successfully");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Form Submitted Successfully!')));
    } else {
      print("API Error: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed!')));
    }

}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('Multi-Step Form')),
body: Stepper(
currentStep: \_currentStep,
onStepContinue: () {
if (\_currentStep < 1) {
setState(() => \_currentStep += 1);
} else {
\_handleSubmit();
}
},
onStepCancel: () {
if (\_currentStep > 0) {
setState(() => \_currentStep -= 1);
}
},
steps: [
Step(
title: Text("Step 1: User Details"),
content: apiData == null
? CircularProgressIndicator()
: Column(
children: [
\_buildTextField("District", apiData!['district']),
\_buildTextField("PINCODE", apiData!['pincode']),
\_buildTextField("Name", apiData!['name']),
\_buildTextField("Email", apiData!['email']),
\_buildTextField("Gender", apiData!['gender']),
\_buildTextField("Mobile", apiData!['mobile']),
\_buildTextField("Family ID", apiData!['familyID']),
\_buildTextField("Father's Name", apiData!['fatherName']),
\_buildTextField("Mother's Name", apiData!['motherName']),
\_buildTextField("Date of Birth", apiData!['dob']),
\_buildTextField("Full Address", apiData!['address']),
],
),
isActive: \_currentStep >= 0,
),
Step(
title: Text("Step 2: Upload Image"),
content: Column(
children: [
_image == null
? Text("No image selected")
: Image.file(_image!, height: 150),
ElevatedButton(
onPressed: _pickImage,
child: Text("Select Image"),
),
],
),
isActive: \_currentStep >= 1,
),
],
),
);
}

Widget \_buildTextField(String label, String? value) {
return Padding(
padding: const EdgeInsets.only(bottom: 8.0),
child: TextFormField(
initialValue: value,
decoration: InputDecoration(
labelText: label,
border: OutlineInputBorder(),
),
readOnly: true,
),
);
}
}

void main() {
runApp(MaterialApp(home: HomePage()));
}
