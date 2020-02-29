import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish/helpers/number.dart';
import 'package:for_kish/models/auth.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

part 'signup.g.dart';

// RegExp mobilePattern = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
RegExp mobilePattern = RegExp(r'^09[0-9]{9}$');

class LoginData {
  String firstName = "";
  String lastName = "";
  String mobile = "";
}

@widget
Widget signup(BuildContext context) {
  final auth = Provider.of<Auth>(context);
  final formKey = useMemoized(()=>GlobalKey<FormState>());
  final data = useMemoized(() => LoginData());
  final error = useState("");

  final locale = LocalizedApp.of(context).delegate.currentLocale.languageCode;

  return Scaffold(
    body: Container(
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
                translate('signup.welcome'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                translate('signup.welcome_desc'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.firstName'),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.text,
                onChanged: (value){
                  data.firstName = value;
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.lastName'),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.text,
                onChanged: (value){
                  data.lastName = value;
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.mobile'),
                  prefixIcon: Icon(Icons.call),
                  // hintText: "+989121111111",
                  hintText: "09121234567",
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value){
                  data.mobile = mapToLatin(value ?? "");
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  if(!mobilePattern.hasMatch(mapToLatin(value))) return translate('login.mobile_does_not_match');
                  return null;
                },
              ),
              SizedBox(height: 20),
              if(error.value.length != 0)
                Text(
                  error.value,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              if(error.value.length != 0)
                SizedBox(height: 16),
              RaisedButton(
                onPressed: () async {
                  if(formKey.currentState.validate()){
                    final result = await auth.signup(
                      firstName: data.firstName,
                      lastName: data.lastName,
                      mobile: data.mobile,
                    );
                    if(result){
                      Navigator.pushNamed(context, '/');
                    }else{
                      error.value = translate('signup.failed');
                    }
                  }
                },
                child: Text(translate('signup.signup')),
              ),
              SizedBox(height: 20),
              Align(
                child: Container(
                  height: 48,
                  child: Row(
                    children: <Widget>[
                      Text(
                        translate('signup.already_a_user'),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, '/');
                        },
                        child: Text(
                          translate('signup.login_now'),
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  height: 48,
                  child: GestureDetector(
                    onTap: (){
                      if(locale!='fa'){
                        changeLocale(context, 'fa');
                      }else{
                        changeLocale(context, 'en');
                      }
                    },
                    child: Text(
                      translate(locale=='fa' ? 'languages.english': 'languages.farsi'),
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    ),
  );
}