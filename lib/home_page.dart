import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStep = 0;
  Map<String, dynamic>? apiData;
  String? mobileNumber, family_id, member_id, district, pincode, name;
  String? gender, fathername, mothername, dob, fulladdress, dist_id;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankBranchAddressController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();



  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadApiResponse();
    allRecordForThisUser();
  }

  Future<void> _loadApiResponse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? responseJson = prefs.getString('api_response');
    final String? mobile = prefs.getString('mobile_number');

    if (responseJson != null) {
      Map<String, dynamic> responseData = jsonDecode(responseJson);
      if (mounted) {
        setState(() {
          mobileNumber = mobile ?? 'N/A';
          family_id = responseData['familyID'] ?? 'N/A';
          member_id = responseData['memberID'] ?? 'N/A';
          district = responseData['districtName'] ?? 'N/A';
          pincode = responseData['pinCode'] ?? 'N/A';
          name = responseData['firstName'] ?? 'N/A';
          emailController.text = responseData['email'] ?? 'N/A';
          gender = responseData['gender'] ?? 'N/A';
          fathername = responseData['fatherFirstName'] ?? 'N/A';
          mothername = responseData['motherFirstName'] ?? 'N/A';
          dob = responseData['dob'] ?? 'N/A';
          fulladdress = responseData['houseNo'] ?? 'N/A';
          apiData = responseData;
        });
      }
      _storeFirstStep();
    }
  }

  Future<void> _storeFirstStep() async {
    var url = Uri.http('127.0.0.1:8000', '/api/store/first/step');
    var parameters = {
      'mobileNumber': mobileNumber ?? '',
      'family_id': family_id ?? '',
      'member_id': member_id ?? '',
      'district': district ?? '',
      'pincode': pincode ?? '',
      'name': name ?? '',
      'gender': gender ?? '',
      'fathername': fathername ?? '',
      'mothername': mothername ?? '',
      'dob': dob ?? '',
      'fulladdress': fulladdress ?? '',
    };
    try {
      var response = await http.post(url, body: parameters);
      if (response.statusCode == 200) {
        print("✅ Record Saved Successfully");
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Future<void> _saveThirdStep() async {
     
  //   print("Sach Me");
  //   var url = Uri.http('127.0.0.1:8000', '/api/save/third/step');

  //   var parameters = {
  //     'accountNumber': accountNumberController.text ?? '',
  //     'confirmaccountnumber' : confirmAccountNumberController.text ?? '',
  //     'pincode' : pinCodeController.text ?? '',
  //     'bankname' : bankNameController.text ?? '',
  //     'bankbranchaddress' : bankBranchAddressController.text ?? '',
  //     'ifsccode' : ifscCodeController.text ?? '',
  //   };


  //     var response = await http.post(url, body: parameters);
  //     if (response.statusCode == 200) {
  //       print("✅ Record Saved Successfully");
  //     } 
  // }

  Future<void> _saveThirdStep() async {
    print("Saving Third Step...");

    String accountNumber = accountNumberController.text;
    String confirmAccountNumber = confirmAccountNumberController.text;
    String pincode = pinCodeController.text;
    String bankName = bankNameController.text;
    String bankBranchAddress = bankBranchAddressController.text;
    String ifscCode = ifscCodeController.text;

    print(accountNumber);
    
    if (accountNumber.isEmpty || confirmAccountNumber.isEmpty || pincode.isEmpty || bankName.isEmpty || bankBranchAddress.isEmpty || ifscCode.isEmpty) {
      print("❌ Please fill all the fields");
      return;
    }

    var url = Uri.http('127.0.0.1:8000', '/api/save/third/step');

    var parameters = {
      'accountNumber': '1212121',
      'confirmaccountnumber': '242424ww',
      'pincode': 'sdsdsdsdsd',
      'bankname': 'bddhhdhdh',
      'bankbranchaddress': 'snjsbbdjsds',
      'ifsccode': 'sjdshggh',
    };

    try {
      var response = await http.post(url, body: parameters);

      if (response.statusCode == 200) {
        print("✅ Third Step Record Saved Successfully");
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }


  Future<void> saveSecondStep() async {
    var url = Uri.http('127.0.0.1:8000', '/api/store/second/step');
    var parameters = {
      'email': emailController.text,
      'member_id': member_id,
    };

    try {
      var response = await http.post(url, body: parameters);
      if (response.statusCode == 200) {
        print("✅ Record Saved Successfully");
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  Future<void> allRecordForThisUser() async {
    var url = Uri.http('127.0.0.1:8000', '/api/user/all/record');
    var parameters = {
      'member_id': 'CMTZ7551',
    };

    var response = await http.post(url, body: parameters);
    var jsonResponse = jsonDecode(response.body);
    String fetchedEmail = jsonResponse['data']['email'];

    setState(() {
      // Auto-fill the email field with the fetched email
      emailController.text = fetchedEmail;
    });

    print("Response Body: ${response.body}");
  }

  Widget _buildTextField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: value is TextEditingController ? value : null,
        initialValue: value is String ? value : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: value is String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi-Step Form')),
      body: Stepper(
        currentStep: _currentStep,
        // onStepContinue: () {
        //   if (_currentStep == 0) {
        //     saveSecondStep();
        //     setState(() => _currentStep += 1);
        //   } else if{
        //     _saveThirdStep();
        //   }else{

        //   }
        // },
        onStepContinue: () {
          if (_currentStep == 0) {
            saveSecondStep();
            setState(() => _currentStep += 1);
          } else if (_currentStep == 1) {
            print(_currentStep);
            _saveThirdStep();
          } else {
            
          }
        },

        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: Text("Step 1: User Details"),
            content: apiData == null
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      _buildTextField("District", district),
                      _buildTextField("PINCODE", pincode),
                      _buildTextField("Name", name),
                      _buildTextField("Email", emailController),
                      _buildTextField("Gender", gender),
                      _buildTextField("Mobile", mobileNumber),
                      _buildTextField("Family ID", family_id),
                      _buildTextField("Father's Name", fathername),
                      _buildTextField("Mother's Name", mothername),
                      _buildTextField("Date of Birth", dob),
                      _buildTextField("Full Address", fulladdress),
                    ],
                  ),
            isActive: _currentStep >= 0,
          ),
          
          Step(
            title: Text("Step 2: Bank Details"),
            content: Column(
              children: [
                _buildTextField("Account Number", accountNumberController),
                _buildTextField("Confirm Account Number", confirmAccountNumberController),
                _buildTextField("PIN Code", pinCodeController),
                _buildTextField("Bank Name", bankNameController),
                _buildTextField("Bank Branch Address", bankBranchAddressController),
                _buildTextField("IFSC Code", ifscCodeController),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: HomePage()));
}
