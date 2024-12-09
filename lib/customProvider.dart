import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:secure_app/Encryption-Decryption/crypto-utils.dart';
import 'package:secure_app/dioSingleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = DioSingleton.dio;
  var _mobileNumber;
  var _employeeNo;
  int _otp = 0;
  var _userId;
  String _name = '';
  var _proposalId;
  var _email;
  String _accessToken = '';
  int _employee_code = 0;
  var _imdCode = null;

  int get otp => _otp;
  get employeeNo => _employeeNo;
  get employee_code => _employee_code;
  get imdCode => _imdCode;
  get userId => _userId;
  get mobileNumber => _mobileNumber;
  get proposalId => _proposalId;
  get name => _name;
  get email => _email;
  get accessToken => _accessToken;

  void updateVariables(
      {mobileNumber,
      employeeNo,
      userId,
      otp,
      email,
      name,
      proposalId,
      employee_code,
      imdCode}) {
    if (mobileNumber != null) {
      _mobileNumber = mobileNumber;
    }
    if (employeeNo != null) {
      _employeeNo = employeeNo;
    }
    if (employee_code != null) {
      _employee_code = employee_code;
    }
    if (imdCode != null) {
      _imdCode = imdCode;
    }
    if (userId != null) {
      _userId = userId;
    }
    if (otp != null) {
      _otp = otp;
      ;
    }
    if (email != null) {
      _email = email;
    }
    if (name != null) {
      _name = name;
    }
    if (proposalId != null) {
      _proposalId = proposalId;
    }
    notifyListeners();
  }

  Future<void> createToken() async {
    // SharedPreferences prefs = await _prefs;

    // var employeeNo = prefs.getString('employeeNo') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
    };
    try {
      final response = await dio.get(
          'https://ansappsuat.sbigen.in/SecureApp/check-user/1',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.data);

        _accessToken = data['token'];
        print(_accessToken);
      } else {
        throw Exception('Failed to create token');
      }
    } catch (e) {
      print(e);
    }
  }
}
