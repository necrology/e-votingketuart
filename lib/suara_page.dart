import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aplikasipemungutansuara/memilih_page.dart';
import 'package:aplikasipemungutansuara/profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'home_page.dart';

class SuaraPage extends StatefulWidget {
  static String tag = 'suara-page';

  @override
  _SuaraPageState createState() => _SuaraPageState();
}

class _SuaraPageState extends State<SuaraPage> {
  Future<List<Hasil>> getdata() async {
    List<Hasil> list = [];
    final session = await SharedPreferences.getInstance();
    final validasi = session.getString('token') ?? '';
    final response1 = await http.post(
        Uri.parse(
            "https://e-voting-dashboard.000webhostapp.com/api/getPemilih.php"),
        body: {"nik": validasi});
    var datauser = json.decode(response1.body);

    final response = await http.post(
        Uri.parse(
            "https://e-voting-dashboard.000webhostapp.com/api/getHasil.php"),
        body: {
          "rt": datauser[0]['rt_pemilih'],
        });
    if (response.statusCode == 200) {
      list = fromJson(response.body);
    }
    return list;
  }

  List<Hasil> fromJson(String strJson) {
    final data = jsonDecode(strJson);
    return List<Hasil>.from(data.map((i) => Hasil.fromMap(i)));
  }

  static List<charts.Series<Hasil, String>> chartData(List<Hasil> data) {
    return [
      charts.Series<Hasil, String>(
          id: 'Hasil',
          domainFn: (Hasil s, _) => s.calon,
          measureFn: (Hasil s, _) => s.suara,
          data: data)
    ];
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Hasil> hasils = [];

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 2));
    Future<List<Hasil>> getdata() async {
      List<Hasil> list = [];
      final response = await http.get(Uri.parse(
          "https://e-voting-dashboard.000webhostapp.com/api/getHasil.php"));
      if (response.statusCode == 200) {
        list = fromJson(response.body);
      }
      return list;
    }

    getdata().then((value) => hasils = value);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 2));
    setState(() {
      getdata().then((value) => hasils = value);
    });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final refresh = SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(13, 50, 13, 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.blue,
            Colors.lightBlueAccent,
          ]),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text('Hasil Suara Sementara',
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 10),
            Container(
              height: 470,
              padding: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: charts.BarChart(chartData(hasils), animate: true),
            ),
          ],
        ),
      ),
    );

    void onTabTapped(int index) {
      if (index == 0) {
        Navigator.of(context).pushNamed(HomePage.tag);
      } else if (index == 1) {
        Navigator.of(context).pushNamed(MemilihPage.tag);
      } else if (index == 2) {
      } else if (index == 3) {
        Navigator.of(context).pushNamed(ProfilePage.tag);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamed(HomePage.tag);
        return true;
      },
      child: Scaffold(
        body: refresh,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Beranda'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote),
              title: Text('Memilih'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              title: Text('Suara'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profil'),
            ),
          ],
          currentIndex: 2,
          onTap: onTabTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class Hasil {
  final String calon;
  final int suara;

  Hasil({required this.calon, required this.suara});

  factory Hasil.fromMap(Map<String, dynamic> map) {
    return Hasil(
        calon: map['hasil_pemilihan_calon'],
        suara: int.parse(map['hasil_pemilihan_suara']));
  }
}
