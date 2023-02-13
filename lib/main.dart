// import 'dart:html';
// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:io';
import 'dart:convert';

import 'package:first_app/screen2.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'screen1.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(notification.hashCode,
        notification.title, notification.body, NotificationDetails());
  }
}

AlertDialog alert(String message) {
  return AlertDialog(
    title: Center(child: Text("Alert")),
    content: Text(message),
  );
}

// FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   print('Got a message whilst in the foreground!');
//   print('Message data: ${message.data}');

//   if (message.notification != null) {
//     print('Message also contained a notification: ${message.notification}');
//   }

// });

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

String? fcmToken;
dynamic ServerDetails;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set the background messaging handler early on, as a named top-level function
  if (FirebaseAuth.instance.currentUser != null) {
    ServerDetails = jsonDecode((await http.get(Uri.parse(
            'https://http-nodejs-production-cee4.up.railway.app/user/${FirebaseAuth.instance.currentUser?.email}')))
        .body);
    print(ServerDetails["find"]["plate_no"]);
    print(ServerDetails["find"]["destination"]);
    print(list[int.parse(ServerDetails["find"]["destination"][1]) - 1]);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Widget Navigate() {
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return const MyHomePage(
      title: 'Home',
    );
  } else {
    return const Screen1();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Navigate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const List<String> list = <String>[
  'Main Canteen',
  'Open Auditorium',
  'IT Department',
  'CSE Department'
];
const Map<String, String> map = {
  'Main Canteen': "B1",
  'Open Auditorium': "B2",
  'IT Department': "B3",
  'CSE Department': "B4"
};

class _MyHomePageState extends State<MyHomePage> {
  bool dynamicAllot = ServerDetails["find"]["dynamicAllot"];
  String dropdownValue =
      list[int.parse(ServerDetails["find"]["destination"][1]) - 1];
  String slot = ServerDetails["find"]["slot"];
  int state = ServerDetails["state"];
  String latitude = "9.882797369314929" ;
  String longitude = "78.0808379430062";
  String parking = (ServerDetails["find"]["slot"] == "__")
      ? "__"
      : (ServerDetails["state"] == 1 ? "Yet to Park" : "Parked");
  // String text = '';
  
  dynamic user = FirebaseAuth.instance.currentUser;
  late dynamic userDetails = ServerDetails;
  void switchAllot() {
    setState(() {
      dynamicAllot = !dynamicAllot;
    });
  }

  void handleDynamicChange(bool state) async {
    if (dynamicAllot == state) {
      return;
    } else {
      try {
        var response = await http.post(
            Uri.parse(
                'https://http-nodejs-production-cee4.up.railway.app/user/put'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "email": user.email,
              "dynamicAllot": state,
            }));
        setState(() {
          if (response.statusCode == 200)
            dynamicAllot = state;
          else
            throw Error();
        });
      } catch (err) {
        print(err);
        alert("unable to update state");
      }
    }
  }

  void handleDestinationChange(String? str) async {
    if (dropdownValue == str) {
      return;
    } else {
      try {
        print(map[str]);
        var response = await http.post(
            Uri.parse(
                'https://http-nodejs-production-cee4.up.railway.app/user/put'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "email": user.email,
              "destination": map[str],
            }));
        print(response.body);
        setState(() {
          if (response.statusCode == 200)
            dropdownValue = str ?? "null";
          else
            throw Error();
        });
      } catch (err) {
        print(err);
        alert("unable to update state");
      }
    }
  }

  refreshFunction() async {
    // if (FirebaseAuth.instance.currentUser != null) {
    ServerDetails = jsonDecode((await http.get(Uri.parse(
            'https://http-nodejs-production-cee4.up.railway.app/user/${FirebaseAuth.instance.currentUser?.email}')))
        .body);
    setState(() {
      dynamicAllot = ServerDetails["find"]["dynamicAllot"];
      dropdownValue =
          list[int.parse(ServerDetails["find"]["destination"][1]) - 1];
      slot = ServerDetails["find"]["slot"];
      state = ServerDetails["state"];
      parking = (ServerDetails["find"]["slot"] == "__")
          ? "__"
          : (ServerDetails["state"] == 1 ? "Yet to Park" : "Parked");
    });
  }
  Future<void> _launchUrl() async {
  if (!await launchUrl( Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude') )) {
    throw 'Could not launch url';
  }
  }
  void signoutAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Center(child: Text("Alert")),
            content: Container(
              height: 270,
              child: Column(
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider('${user.photoURL}'),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      '${user.displayName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      'Plate No : ${userDetails["find"]["plate_no"]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.only(top:20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Screen1()),
                          (Route<dynamic> route) => false,
                        );
                        handlesignOut();
                      },
                      child: Text('Sign Out'),
                      style: ButtonStyle(
                          // backgroundColor:MaterialStateProperty<Color>(Colors.red);
                          ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage rm) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${rm.notification?.title}"),
              content: Text("${rm.notification?.body}"),
            );
          },
        );
      },
    );
    //  useEffect
    return Scaffold(
      // backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   actions: const [Icon(Icons.settings)],
      // ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color.fromARGB(255, 139, 139, 139)])),
        child: Stack(
          // fit: StackFit.expand,
          children: [
            Positioned(
              top: 280,
              left: 0,
              child: Image.asset(
                'assets/anime_lot_intro.png',
                width: 400,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: RefreshIndicator(
                onRefresh: () async {
                  await refreshFunction();
                },
                child: Center(
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => signoutAlert(context),
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              '${user.photoURL}'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Home',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                height: 10,
                                width: 50,
                                // margin: Ed,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: slot != "__"
                                      ? Color.fromARGB(255, 66, 255, 72)
                                      : Color.fromARGB(255, 252, 17, 17),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Container(
                          margin: EdgeInsets.only(left: 16, right: 16, top: 120),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(219, 255, 255, 255),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Your Destination',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '$dropdownValue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Parking Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        // height: 40,
                                      ),
                                    ),
                                    Text(
                                      '$parking',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 26,
                                          color: (slot == "__")
                                              ? Colors.black
                                              : (state == 1
                                                  ? Colors.amber
                                                  : Color.fromARGB(
                                                      255, 66, 255, 72))),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Your Allotment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '$slot',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 28,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                margin: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(
                                    height: 0,
                                    color: Colors.black,
                                  ),
                                  onChanged: (String? value) {
                                    // This is called when the user selects an item.
                                    handleDestinationChange(value);
                                  },
                                  items: list.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    right: 10, left: 20, top: 7, bottom: 7),
                                margin: EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromARGB(231, 255, 255, 255),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Dynamic Allotment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      // margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.grey.shade400,
                                      ),
                                      // padding: EdgeInsets.,
                                      child: Row(
                                        children: [
                                          Container(
                                            // padding: EdgeInsets.all(5),

                                            height: 45,
                                            child: TextButton(
                                                onPressed: () =>
                                                    handleDynamicChange(false),
                                                child: const Text('off'),
                                                style: ButtonStyle(
                                                  //  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(10)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Color.fromARGB(
                                                              dynamicAllot
                                                                  ? 0
                                                                  : 255,
                                                              244,
                                                              18,
                                                              18)),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.black),

                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100))),
                                                )),
                                          ),
                                          Container(
                                            // padding: EdgeInsets.all(5),
                                            height: 45,
                                            child: TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    handleDynamicChange(true);
                                                  });
                                                },
                                                child: const Text('on'),
                                                style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsetsGeometry>(
                                                          EdgeInsets.all(10)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Color.fromARGB(
                                                              dynamicAllot
                                                                  ? 255
                                                                  : 0,
                                                              66,
                                                              255,
                                                              72)),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.black),
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100))),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton.extended(
          onPressed: () {_launchUrl();},
          // shape: ,
          // backgroundColor: Colors.white,
          label: const Text('Navigate'),
          icon: const Icon(Icons.explore_outlined),
          backgroundColor: Colors.white,
          // child: Icon(Icons.explore,
          //   size: 40,
          //   color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
