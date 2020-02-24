import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish/helpers/number.dart';
import 'package:for_kish/models/auth.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

part 'profile.g.dart';

class LoginData {
  String firstName = "";
  String lastName = "";
  String mobile = "";
}

@widget
Widget profile(BuildContext context) {
  final auth = Provider.of<Auth>(context);
  final formKey = useMemoized(()=>GlobalKey<FormState>());
  final data = useMemoized(() {
    var data = LoginData();
    data.firstName = auth.passenger.firstName;
    data.lastName = auth.passenger.lastName;
    data.mobile = auth.passenger.mobile;
    return data;
  });
  final error = useState("");

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0x11000000),
      textTheme: TextTheme(
        title: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      elevation: 0,
      title: Text(translate('menu.profile')),
      actionsIconTheme: IconThemeData(
        color: Colors.black
      ),
    ),
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.firstName'),
                  prefixIcon: Icon(Icons.person),
                ),
                initialValue: data.firstName,
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
                initialValue: data.lastName,
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
                ),
                readOnly: true,
                initialValue: mapNumber(context, data.mobile),
              ),
              SizedBox(height: 48),
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
                    // final result = await auth.signup(
                    //   firstName: data.firstName,
                    //   lastName: data.lastName,
                    //   mobile: data.mobile,
                    // );
                    // if(result){
                    //   Navigator.pushNamed(context, '/');
                    // }else{
                    //   error.value = translate('signup.failed');
                    // }
                  }
                },
                child: Text(translate('signup.save')),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
