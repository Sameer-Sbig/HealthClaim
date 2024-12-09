import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:secure_app/Encryption-Decryption/crypto-utils.dart';
import 'package:secure_app/customProvider.dart';
import 'package:secure_app/dioSingleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = DioSingleton.dio;
  bool isValidating = false;
  Map profile = {"username": "", "email": "", "phoneNumber": ""};
  @override
  void initState() {
    super.initState();
    getProfileDetails();
  }

  getProfileDetails() async {
    setState(() {
      isValidating = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.get(
          'https://uatcld.sbigeneral.in/SecureApp/user/profile',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          isValidating = false;
        });
        String decryptedData = aesGcmDecryptJson(response.data);
        print(decryptedData);
        var data = jsonDecode(decryptedData);
        // final data = jsonDecode(response.data);
        setState(() {
          profile = data;
        });
      }
    } catch (error) {
      setState(() {
        isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(13, 154, 189, 1),
              titleTextStyle: const TextStyle(color: Colors.white),
            ),
            body: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(13, 154, 189, 0.15),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.14,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        // height: MediaQuery.of(context).size.height * 0.53,
                        // margin: const EdgeInsets.only(left: 15, right: 15),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(15, 5, 158, 0.4),
                                blurRadius: 5.0, // soften the shadow
                                spreadRadius: 2.0, //extend the shadow
                                offset: Offset(
                                  3.0, // Move to right 5  horizontally
                                  3.0, // Move to bottom 5 Vertically
                                ),
                              ),
                            ]),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                      ),
                                      _details('Name:  ${profile['username']}',
                                          Icons.person),
                                      _details('Email:  ${profile['email']}',
                                          Icons.mail),
                                      _details(
                                          'Contact:  ${profile['phoneNumber']}',
                                          Icons.call),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                      )
                                    ]),
                                Positioned(
                                  top: -45,
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        // borderRadius: BorderRadius.circular(12),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Color.fromRGBO(15, 5, 158, 0.4),
                                            blurRadius:
                                                5.0, // soften the shadow
                                            spreadRadius:
                                                2.0, //extend the shadow
                                            offset: Offset(
                                              3.0, // Move to right 5  horizontally
                                              3.0, // Move to bottom 5 Vertically
                                            ),
                                          ),
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: Center(
                                        child: Container(
                                            child: const Icon(
                                          Icons.person_2_outlined,
                                          size: 50,
                                          color: Color.fromRGBO(15, 5, 158, 1),
                                        )),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ],
                ))),
        isValidating
            ? Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        const Text('Please Wait...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(15, 5, 158, 1),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        LoadingAnimationWidget.threeArchedCircle(
                          color: const Color.fromRGBO(15, 5, 158, 1),
                          size: 50,
                        ),
                      ])),
                ),
              )
            : Container()
      ],
    );
  }

  _details(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.1,
          bottom: MediaQuery.of(context).size.height * 0.03),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Icon(
            icon,
            color: const Color.fromRGBO(15, 5, 158, 1),
            size: 20,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            label,
            style: const TextStyle(
                color: Color.fromRGBO(15, 5, 158, 1),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
