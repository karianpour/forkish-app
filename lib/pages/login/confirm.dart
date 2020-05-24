import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish/models/auth.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

part 'confirm.g.dart';

class CodeData {
  String code = "";
}

@widget
Widget confirm(BuildContext context) {
  final auth = Provider.of<Auth>(context);
  final formKey = useMemoized(()=>GlobalKey<FormState>());
  final data = useMemoized(() => CodeData());
  final error = useState("");

  return Container(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100),
            Image.asset('assets/images/crossover.png', height: 100,),
            SizedBox(height: 30),
            Text(
              translate('login.confirm_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              translate('login.confirm_statement'),
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.8,
              ),
            ),
            SizedBox(height: 48),
            Text(
              translate('login.resend_code_after'),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Counter(time: 180),
            SizedBox(height: 24),
            // TextFormField(
            //   textDirection: TextDirection.ltr,
            //   decoration: InputDecoration(
            //     prefixIcon: Icon(Icons.lock),
            //     hintText: "1234",
            //   ),
            //   keyboardType: TextInputType.number,
            // ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                // width: 120,
                // constraints: BoxConstraints(
                //   maxWidth: 100,
                // ),
                child: PinCodeTextField(
                  length: 4,
                  autoFocus: true,
                  backgroundColor: Colors.white12,
                  textInputType: TextInputType.number,
                  obsecureText: false,
                  animationType: AnimationType.fade,
                  animationDuration: Duration(milliseconds: 50),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 40,
                    fieldWidth: 30,
                  // borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    data.code = value?.trim() ?? "";
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            if(error.value.length != 0)
              Text(
                error.value,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            if(error.value.length != 0)
              SizedBox(height: 16),
            Text(
              translate('login.mobile_alert', args: {"mobile": auth.mobile}),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Align(
              child: Container(
                height: 48,
                child: GestureDetector(
                  onTap: (){
                    auth.relogin();
                  },
                  child: Text(
                    translate('login.change_number'),
                    // textAlign: TextAlignVertical.bottom,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 0),
            RaisedButton(
              onPressed: () async{
                if(data.code.length!=4){
                  error.value = translate('login.code_should_be_4');
                }else{
                  final result = await auth.verify(data.code);
                  if(!result){
                    error.value = translate('login.failed_to_verify');
                  }
                }
              },
              child: Text(translate('login.confirm')),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    ),
  );
}

@widget
Widget counter(BuildContext context, {@required int time}) {
  final minutes = useState((time / 60).floor());
  final seconds = useState((time % 60));

  useEffect((){
    final timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      if(seconds.value == 0){
        if(minutes.value==0){
          timer.cancel();
        }else{
          minutes.value--;
          seconds.value=59;
        }
      }else{
        seconds.value--;
      }
    });
    return (){timer.cancel();};
  }, []);
  
  return Text(
    '${minutes.value}:${seconds.value}',
    textAlign: TextAlign.center,
  );
}
