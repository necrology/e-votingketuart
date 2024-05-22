import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'memilih_page.dart';
import 'profile_page.dart';
import 'suara_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getBool('isLoggedIn') ?? false;
  print(status);

  final routes = <String, WidgetBuilder>{
    SuaraPage.tag: (context) => SuaraPage(),
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    MemilihPage.tag: (context) => MemilihPage(),
    ProfilePage.tag: (context) => ProfilePage(),
  };

  runApp(
    MaterialApp(
        title: 'E-Voting Ketua RT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          fontFamily: 'Nunito',
        ),
        home: status == true ? HomePage() : LoginPage(),
        routes: routes,
        builder: EasyLoading.init()),
  );
}
