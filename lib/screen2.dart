// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';

import './main.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

AlertDialog alert(String message) {
  return AlertDialog(
    title: Text("Alert"),
    content: Text(message),
  );
}
  Future<void> handlesignOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    // await FirebaseAuth.instance.signOut();
    // print(FirebaseAuth.instance.currentUser);
  }
class _Screen2State extends State<Screen2> {
  @override
  String? plateNo = "";
  handleSelect(String? inst) {
    setState(() {
      plateNo = inst;
    });
  }

  Future<void> handleSignIn(context) async {
    print('inside handlesing $plateNo');
    if (plateNo == "") {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert("Please Enter a valid plate number !");
          });
      return;
    }
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      String? userEmail = googleUser?.email;
      if (userEmail?.substring(userEmail.length - 7) != "tce.edu") {
        // alert('Please use Your instituation email id');
        await GoogleSignIn().signOut();
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert('Please use Your instituation email id');
            });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print(googleUser);
      fcmToken = await FirebaseMessaging.instance.getToken();
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      var response = await http.post(
          Uri.parse('https://http-nodejs-production-cee4.up.railway.app/user/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "email": googleUser?.email,
            "plate_no": plateNo,
            "fcm_token": "$fcmToken"
          }));
      var  response2 = await (jsonDecode(response.body));
      print(response2);
      ServerDetails = await jsonDecode((await http.get(Uri.parse(
          'https://http-nodejs-production-cee4.up.railway.app/user/${googleUser?.email}')))
      .body);
      // await showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return alert(
      //           'Email :${response2["email"]}\nplate_no : ${response2["plate_no"]}\nfcm_token : ${response2["fcm_token"]}');
      //     });
          
      Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>  MyHomePage(title: 'Home')),
                  (Route<dynamic> route) => false,
            );
    } catch (err) {
      print(err);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert('$err');
          });
      return;
    }
  }



  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,  
      // body: SingleChildScrollView(
        body:  Stack(
          children: [
            Container(
                // decoration: BoxDecoration(
                //   color:
                // ),
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 40),
                        child: Text(
                      'Your Info',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 40, left: 15, right: 15),
                      padding: EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          // DropdownButton(items: const[
                          //   DropdownMenuItem<String>(
                          //       value: "TCE", child: Text("TCE")),
                          //   DropdownMenuItem<String>(
                          //       value: 'NoTCE', child: Text("NoTCE"))
                          // ],
                          //  onChanged: (String? value) => handleSelect(value),
                          //  isExpanded: true,
                          //  hint: Text('select your institiuation'),
                          //  style: const TextStyle(color: Colors.orange),
                          // ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter your Lisence Plate Number',
                              ),
                              onChanged: (x) => handleSelect(x),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.all(30),
                              child: const Text(
                                '\u2022 Only those organizatinos which are registered for our software service will be listed here. \n\n\u2022 Having selected your organization, only your organization specific email ID can be used. \n\n\u2022 For further information regarding sPark, kindly visit our official page for more details.',
                                style: TextStyle(fontSize: 16),
                              )),
                          Center(
                            child: SignInButton(
                              Buttons.Google,
                              onPressed: () => handleSignIn(context),
                              padding: EdgeInsets.all(5),
                              // text:'Google'
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(30),
                      color: Colors.black12,
                      margin: EdgeInsets.only(top: 130),
                    )
                        // decoration: BoxDecoration(
                        //   b
                        // ),
                        )
                  ],
                )),
            Positioned(
              // bottom: 0,
              top: 720,
              left: 25,
              child: Image.asset(
                'assets/anime_lot_campus1.png',
                width: 350,
              ),
            )
          ],
        ),
        
      
    );
  }
}
