import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController familyIdController = TextEditingController();
  TextEditingController getOtpController = TextEditingController();

  String? selectedOption;
  bool isLoading = false;
  List<Map<String, dynamic>> members = [];
  bool showMember = false;
  bool showOtpField = false;
  String txn = '';
  String memberIdNumber = '';
  String mobile = '';

  var responseData; 

  Future<void> getMemberDetails() async {
    setState(() {
      isLoading = true;
    });

    String familyId = familyIdController.text.trim();

    if (familyId.isEmpty) {
      Flushbar(
        message: "Please Enter The Family ID",
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      )..show(context);
      setState(() {
        isLoading = false;
      });
      return;
    }

    var url = Uri.http('164.100.137.245', '/PPPapi/api/Account/GetMemberbasicdetailsfromFIDUID');
    var parameters = {
      'DeptCode': 'NIC',
      'Servicecode': 'TestCred',
      'DeptKey': 'o2etc739ut',
      'UIDFID': familyId,
    };

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetching details...')),
      );

      var response = await http.post(url, body: parameters, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      });
      var res = jsonDecode(response.body);

      if (response.statusCode == 200 && res["status"] == 'Successfull') {
        if (res.containsKey('result') && res['result'].containsKey('dropdown')) {
          List<dynamic> dropdownList = res['result']['dropdown'];

          setState(() {
            showMember = true;
            members = dropdownList.map((item) => {'value': item['value'], 'text': item['text']}).toList();
            if (members.isNotEmpty) {
              selectedOption = members.first['value'];
            }
          });
        }
      } else {
        setState(() {
          members.clear();
          showMember = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please check your connection.')),
      );
      setState(() {
        members.clear();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getOtp() async {
    String memberid = selectedOption?.trim() ?? '';
    setState((){
          memberIdNumber = memberid;
    });

    if (memberid.isEmpty) {
      // print("Error: Member ID is empty!");
      return;
    }

    var url = Uri.http('164.100.137.245', '/PPPapi/api/Account/OTPRequestforMEMID');

    var parameters = {
      'DeptCode': 'NIC',
      'Servicecode': 'TestCred',
      'DeptKey': 'o2etc739ut',
      'MemberID': memberid,
    };

    var response = await http.post(url, body: parameters, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    });

    var result = jsonDecode(response.body);
    // print(result);
    String statusValue = result['result']['status'];
    
   String txnNumber = result['result']['txn'];



// print("Transaction ID: $txn");
   setState((){
     txn = txnNumber;
   });



    if (statusValue == 'Successfull') {
      setState(() {
        showOtpField = true;
      });
    }
  }

  Future<void> verifyOtp() async {
    String otp = getOtpController.text.trim();
    if (otp == '111111'){
  
    var url = Uri.http('164.100.137.245', '/PPPapi/api/Account/VerifyOTPRequestforMEMID');


    // print("Member ID: $memberIdNumber");
    // print("Transaction ID: $txn");
    

    var parameters = {
      'DeptCode': 'NIC',
      'Servicecode': 'TestCred',
      'DeptKey': 'o2etc739ut',
      'MemberID': memberIdNumber.trim(),
      'Txn': txn.trim(),
      'OTP': '111111',
    };

    try {
      var response = await http.post(
        url,
        body: parameters,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      );

      // print("Response Status: ${response.statusCode}");
      // print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var r = jsonDecode(response.body);
        responseData = r['result'];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_response', jsonEncode(responseData));
        String? mobileNumber = responseData['mobileNo'];
        await prefs.setString('mobile_number', mobileNumber ?? '');
        // print(mobileNumber);

      } else {
        // print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // print("Request Failed: $e");
    }


    





      Flushbar(
        message: "Otp Verified",
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      )..show(context);

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    } else {
      Flushbar(
        message: "Otp Not Verified",
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      )..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Page',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Application for Cash Award',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Applications invited for achievements on or after 01-04-2024',
                      style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter Family ID *',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Enter Family ID',
                            ),
                            controller: familyIdController,
                          ),
                          const SizedBox(height: 15),

                          if (!showMember)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: getMemberDetails,
                                child: const Text(
                                  'Get Member Details',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),

                          if (showMember) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Select Member *',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedOption,
                              items: members.map((member) {
                                return DropdownMenuItem<String>(
                                  value: member['value'],
                                  child: Text(member['text'] ?? "Unknown"),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOption = newValue!;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (!showOtpField)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: getOtp,
                                  child: const Text('Get OTP'),
                                ),
                              ),
                          ],

                          if (showOtpField) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'Enter OTP *',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: getOtpController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: 'Enter OTP',
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: verifyOtp,
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
