import 'package:for_kish/helpers/types.dart';

Future<bool> requestVerificationCode(String mobile) async {
  await Future.delayed(Duration(milliseconds: 200));
  return true;
}

Future<Passenger> verifyCode(String mobile, String code) async {
  await Future.delayed(Duration(milliseconds: 200));
  if(code == '1234'){
    return Passenger(
      firstName: '',
      lastName: '',
      mobile: '09121161998',
    );
  }
  return null;
}