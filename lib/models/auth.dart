import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:for_kish/api/taxi.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:for_kish/api/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

const String _authKey = "__auth__";

class Auth with ChangeNotifier {
  bool loaded = false;
  bool loggedin = false;
  bool waitingForCode = false;
  String mobile;
  Passenger passenger;
  String token;

  Auth(){
    load();
  }

  void login(String mobile) async{
    this.mobile = mobile;
    try{
      waitingForCode = await requestVerificationCode(mobile);
    }catch(err){
      print(err);
      waitingForCode = false;
    }
    notifyListeners();
    save();
  }

  void relogin() {
    this.loggedin = false;
    this.mobile = "";
    waitingForCode = false;
    notifyListeners();
    save();
  }

  Future<bool> verify(String code) async{
    try{
      VerificationResponse response = await verifyCode(this.mobile, code);
      if(response != null){
        this.passenger = response.passenger;
        this.token = response.token;
        setWebSocketToken(this.token);
        this.waitingForCode = true;
        this.loggedin = true;
        notifyListeners();
        save();
        return true;
      }else{
        return false;
      }
    }catch(err){
      print(err);
      return false;
    }
  }

  Future<bool> signup({
    @required String firstname,
    @required String lastname,
    @required String mobile,
  }) async{
    this.mobile = mobile;
    try{
      final result = await requestSigup(uuid.v4(), firstname, lastname, mobile);
      if(result){
        waitingForCode = true;
        notifyListeners();
        save();
        return true;
      }else{
        return false;
      }
    }catch(err){
      print(err);
      return false;
    }
  }

  Future<void> load() async {
    try{
      final preferences = await SharedPreferences.getInstance();

      if(preferences.containsKey(_authKey)) {
        var map = jsonDecode(preferences.getString(_authKey));

        this.loggedin = map['loggedin'];
        this.waitingForCode = map['waitingForCode'];
        this.mobile = map['mobile'];
        this.passenger = map['passenger']==null ? null : Passenger.fromJson(map['passenger']);
        this.token = map['token'];
      }
    }catch(err){
      print(err);
      this.loggedin = false;
      this.waitingForCode = false;
      this.mobile = null;
      this.passenger = null;
      this.token = null;
    }
    this.loaded = true;
    setWebSocketToken(this.token);
    notifyListeners();
  }

  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_authKey, jsonEncode(this));
  }

  Map<String, dynamic> toJson() =>
    {
      'loggedin': loggedin,
      'waitingForCode': waitingForCode,
      'mobile': mobile,
      'passenger': passenger?.toJson(),
      'token': token,
    };
}