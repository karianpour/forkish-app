import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish/helpers/number.dart';
import 'package:for_kish/models/auth.dart';
import 'package:for_kish/models/taxi.dart';
import 'package:for_kish/pages/login/confirm.dart';
import 'package:for_kish/pages/login/login.dart';
import 'package:for_kish/pages/login/signup.dart';
import 'package:for_kish/pages/profile/profile.dart';
import 'package:for_kish/pages/taxi_query/test.dart';
import 'package:for_kish/translate_preferences.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import 'pages/taxi_query/taxi_query.dart';

part 'main.g.dart';

class App{
  static Router router = Router();
}

void defineRoutes(Router router) {
  // router.define("/single_news/:newsId", handler: singleNewsHandler);
}

void main() async {
  defineRoutes(App.router);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'fa',
    supportedLocales: ['en', 'fa'],
    preferences: TranslatePreferences(),
  );

  runApp(LocalizedApp(delegate, MyApp()));
}

@widget
Widget myApp(BuildContext context) {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final localizationDelegate = LocalizedApp.of(context).delegate;
  
  return LocalizationProvider(
    state: LocalizationProvider.of(context).state,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Taxi>(
          create: (_) => Taxi(),
          update: (_, auth, taxi) {
            print('updated');
            if(auth.passenger?.id != null){
              taxi.load(auth.passenger.id);
            }
            return taxi;
          },
        ),
      ],
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        // theme: ThemeData.dark(),
        theme: ThemeData(
          fontFamily: 'Nika',
          // primarySwatch: Colors.blue,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          localizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        initialRoute: '/',
        routes: forKishRoutes,
        onGenerateRoute: App.router.generator,
        home: Consumer<Auth>(
          builder: (context, auth, _) {
            if(!auth.loaded){
              return Scaffold(body: Container());
            }else if(!auth.loggedin){
              if(!auth.waitingForCode){
                return Scaffold(body: Login());
              }else{
                return Scaffold(body: Confirm());
              }
            }else{
              return TaxiScaffold(body: TaxiQuery());
            }
          },
        ),
      ),
    ),
  );
}

@widget
Widget taxiScaffold(BuildContext context, { @required Widget body }) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    drawer: AppDrawer(),
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
      title: Text(translate('app.title')),
      actions: <Widget>[
        RawMaterialButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(0),
          onPressed: (){}, 
          child: Icon(Icons.notifications, size: 20),
        ),
      ],
      actionsIconTheme: IconThemeData(
        color: Colors.black
      ),
    ),
    body: body,
  );
}

final Map<String, WidgetBuilder> forKishRoutes = {
  '/signup': (context) => Signup(),
  '/profile': (context) => Profile(),
};

@widget
Widget appDrawer(BuildContext context) {
  final auth = Provider.of<Auth>(context);
  final locale = LocalizedApp.of(context).delegate.currentLocale.languageCode;

  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${auth.passenger?.firstname ?? ''} ${auth.passenger?.lastname ?? ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${mapNumber(context, auth.passenger?.mobile ?? '')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          title: Text(translate('menu.profile')),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/profile');
          },
        ),
        ListTile(
          title: Text(translate('menu.logout')),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/');
            auth.relogin();
          },
        ),
        if(locale != 'fa') ListTile(
          title: Text(translate('languages.farsi')),
          onTap: () {
            Navigator.pop(context);
            changeLocale(context, 'fa');
          },
        ),
        if(locale != 'en') ListTile(
          title: Text(translate('languages.english')),
          onTap: () {
            Navigator.pop(context);
            changeLocale(context, 'en');
          },
        ),
      ],
    ),
  );
}
