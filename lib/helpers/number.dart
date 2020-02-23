import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';

NumberFormat _formatter;

String formatNumber(BuildContext context, dynamic number){
  final local = LocalizedApp.of(context).delegate.currentLocale.languageCode;
  if(_formatter==null || _formatter.locale!=local){
    _formatter = NumberFormat.decimalPattern(local);
  }
  var formatted = _formatter.format(number);
  // if(local=='fa'){
  //   return mapToFarsi(formatted);
  // }
  return formatted;
}

String mapNumber(BuildContext context, String text){
  final local = LocalizedApp.of(context).delegate.currentLocale.languageCode;
  if(local=='fa'){
    return mapToFarsi(text);
  }
  return text;
}

String mapToFarsi(String str){
  return str.replaceAllMapped(RegExp(r"\d"), 
    (Match m) {
      return convertDigitFarsi(m[0]);
    }
  );
}

String convertDigitFarsi(String m) {
  switch(m){
    case "1":
      return "۱";
    case "2":
      return "۲";
    case "3":
      return "۳";
    case "4":
      return "۴";
    case "5":
      return "۵";
    case "6":
      return "۶";
    case "7":
      return "۷";
    case "8":
      return "۸";
    case "9":
      return "۹";
    case "0":
      return "۰";

  }
  return m;
}

String mapToLatin(String str){
  return str.replaceAllMapped(RegExp(r"[۰-۹٠-٩]"), 
    (Match m) {
      return convertDigitToLatin(m[0]);
    }
  );
}

String convertDigitToLatin(String m) {
  switch(m){
    case "۱":
    case "١":
      return "1";
    case "۲":
    case "٢":
      return "2";
    case "۳":
    case "٣":
      return "3";
    case "۴":
    case "٤":
      return "4";
    case "۵":
    case "٥":
      return "5";
    case "۶":
    case "٦":
      return "6";
    case "۷":
    case "٧":
      return "7";
    case "۸":
    case "٨":
      return "8";
    case "۹":
    case "٩":
      return "9";
    case "۰":
    case "٠":
      return "0";

  }
  return m;
}
