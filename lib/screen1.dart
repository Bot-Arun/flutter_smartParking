// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import './main.dart';
import './screen2.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset:false,
      // appBar: AppBar(
      //   title: const Text('hi this is my page'),
      //   toolbarHeight: ,
      // ),
      body: Stack(children: [
        Container(
          padding: EdgeInsets.only(top: 100),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.sp,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  // padding:,
                  child: Stack(
                    children: [
                      Text(
                        "An Intelligent Parking App \nThat Eases Your Daily\nRoutine.",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  child: SizedBox(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                      padding: EdgeInsets.only(top: 120),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Text(
                                    "Introducing,",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "sPark",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w700),
                                    ))
                              ]),
                          Container(
                            width: 300,
                            margin: EdgeInsets.only(top: 40),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                
                              ),
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.black,
                                )
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Screen2()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 300,
          left: 0,
          child: Image.asset(
            'assets/anime_lot_intro.png',
            width: 380,
          ),
        )
      ]),
    );
  }
}
