import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:for_kish/helpers/types.dart';

var baseUrl = 'http://192.168.1.52:4080';

Future<bool> requestVerificationCode(String mobile) async {
  // await Future.delayed(Duration(milliseconds: 200));
  // return true;
  var url ='$baseUrl/passenger/send_activation';

  Map data = {
    'mobile': mobile,
  };
  var body = jsonEncode(data);

  var response = await http.post(url,
    headers: {"Content-Type": "application/json"},
    body: body
  );
  print("${response.statusCode}");
  print("${response.body}");
  if(response.statusCode==200){
    var responseJson = jsonDecode(response.body);
    var succeed = responseJson['succeed'];
    if(succeed != null && succeed is bool && succeed){
      return true;
    }
  }
  return false;
}

class VerificationResponse {
  Passenger passenger;
  String token;

  VerificationResponse({this.passenger, this.token});
}

Future<VerificationResponse> verifyCode(String mobile, String code) async {
  // await Future.delayed(Duration(milliseconds: 200));
  // if(code == '1234'){
  //   return Passenger(
  //     id: '1234-5678',
  //     firstname: 'کیوان',
  //     lastname: 'آرین‌پور',
  //     mobile: '09121161998',
  //   );
  // }
  // return null;

  var url ='$baseUrl/passenger/verify_activation';

  Map data = {
    'mobile': mobile,
    'code': code,
  };
  var body = jsonEncode(data);

  var response = await http.post(url,
    headers: {"Content-Type": "application/json"},
    body: body
  );
  print("${response.statusCode}");
  print("${response.body}");
  if(response.statusCode==200){
    var responseJson = jsonDecode(response.body);
    if(responseJson != null){
      var passenger = Passenger.fromJson(responseJson);
      var token = responseJson['token'];
      return VerificationResponse(passenger: passenger, token: token);
    }
  }
  return null;
}

Future<bool> requestSigup(
  String id,
  String firstname,
  String lastname,
  String mobile,
) async {
  await Future.delayed(Duration(milliseconds: 200));
  return false;
}
