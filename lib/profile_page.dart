import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:aplikasipemungutansuara/memilih_page.dart';
import 'package:aplikasipemungutansuara/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'suara_page.dart';

class Pemilihdata {
  String pemilihId;
  String pemilihNama;
  String pemilihNik;
  String pemilihKk;
  String pemilihStatus;

  Pemilihdata({
    required this.pemilihId,
    required this.pemilihNama,
    required this.pemilihNik,
    required this.pemilihKk,
    required this.pemilihStatus,
  });

  factory Pemilihdata.fromJson(Map<String, dynamic> json) {
    return Pemilihdata(
        pemilihId: json['id_pemilih'].toString(),
        pemilihNama: json['nama_pemilih'],
        pemilihNik: json['noNik_pemilih'].toString(),
        pemilihKk: json['noKK_pemilih'].toString(),
        pemilihStatus: json['statusMemilih_pemilih']);
  }
}

class ProfilePage extends StatelessWidget {
  static String tag = 'profile-page';

  Future<List<Pemilihdata>> fetchPemilih() async {
    final session = await SharedPreferences.getInstance();
    final data = session.getString('token') ?? '';
    final response = await http.post(
        Uri.parse(
            "https://e-voting-dashboard.000webhostapp.com/api/getPemilih.php"),
        body: {"nik": data});

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<Pemilihdata> pemilihList = items.map<Pemilihdata>((json) {
        return Pemilihdata.fromJson(json);
      }).toList();

      return pemilihList;
    } else {
      throw Exception('Failed to load data from Server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircleAvatar(
          radius: 72.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/man.png'),
        ),
      ),
    );

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(13, 30, 13, 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent,
        ]),
      ),
      child: FutureBuilder<List<Pemilihdata>>(
        future: fetchPemilih(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                String status;
                if (snapshot.data![index].pemilihStatus == "0") {
                  status = "Belum Memilih";
                } else {
                  status = "Telah Memilih";
                }

                Future keluar() async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  SharedPreferences session =
                      await SharedPreferences.getInstance();
                  session.clear();
                  prefs.clear();
                }

                return Container(
                  padding: EdgeInsets.all(15),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text('Data Diri',
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center),
                      icon,
                      SizedBox(height: 40),
                      Container(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              children: [
                                TextSpan(text: 'Nama'),
                                TextSpan(
                                    text: '    : ' +
                                        snapshot.data![index].pemilihNama),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              children: [
                                TextSpan(text: 'NIK'),
                                TextSpan(
                                    text: '        : ' +
                                        snapshot.data![index].pemilihNik),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              children: [
                                TextSpan(text: 'KK'),
                                TextSpan(
                                    text: '         : ' +
                                        snapshot.data![index].pemilihKk),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              children: [
                                TextSpan(text: 'Status'),
                                TextSpan(text: '   : ' + status),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 80),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: RaisedButton(
                          color: Colors.lightBlueAccent,
                          shape: border,
                          onPressed: () async {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text('Keluar ?'),
                                content: Text('Anda yakin ingin keluar ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Tidak'),
                                    child: const Text('Tidak'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      keluar();
                                      Navigator.of(context)
                                          .pushNamed(LoginPage.tag);
                                    },
                                    child: const Text('Iya'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            'Keluar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );

    void onTabTapped(int index) {
      if (index == 0) {
        Navigator.of(context).pushNamed(HomePage.tag);
      } else if (index == 1) {
        Navigator.of(context).pushNamed(MemilihPage.tag);
      } else if (index == 2) {
        Navigator.of(context).pushNamed(SuaraPage.tag);
      } else if (index == 3) {}
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamed(HomePage.tag);
        return true;
      },
      child: Scaffold(
        body: body,
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
          currentIndex: 3,
          onTap: onTabTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
