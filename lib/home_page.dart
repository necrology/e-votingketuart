import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aplikasipemungutansuara/memilih_page.dart';
import 'package:aplikasipemungutansuara/profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

import 'suara_page.dart';

class PengumumanData {
  int pengumumanId;
  String pengumumanJudul;
  String pengumumanIsi;

  PengumumanData(
      {required this.pengumumanId,
      required this.pengumumanJudul,
      required this.pengumumanIsi});

  factory PengumumanData.fromJson(Map<String, dynamic> json) {
    return PengumumanData(
        pengumumanId: json['pengumuman_id'],
        pengumumanJudul: json['pengumuman_judul'],
        pengumumanIsi: json['pengumuman_isi']);
  }
}

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

  final String apiURL =
      'https://e-voting-dashboard.000webhostapp.com/api/getPengumuman.php';

  Future<List<PengumumanData>> fetchPengumuman() async {
    var response = await http.get(Uri.parse(apiURL));

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<PengumumanData> pengumumanList = items.map<PengumumanData>((json) {
        return PengumumanData.fromJson(json);
      }).toList();

      return pengumumanList;
    } else {
      throw Exception('Failed to load data from Server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    );

    final body = Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(13.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.blue,
            Colors.lightBlueAccent,
          ]),
        ),
        child: FutureBuilder<List<PengumumanData>>(
          future: fetchPengumuman(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    shape: border,
                    child: ListTile(
                      onTap: () {},
                      title: Text(snapshot.data![index].pengumumanJudul,
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      subtitle: Html(data: snapshot.data![index].pengumumanIsi),
                    ),
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ));

    void onTabTapped(int index) {
      if (index == 0) {
      } else if (index == 1) {
        Navigator.of(context).pushNamed(MemilihPage.tag);
      } else if (index == 2) {
        Navigator.of(context).pushNamed(SuaraPage.tag);
      } else if (index == 3) {
        Navigator.of(context).pushNamed(ProfilePage.tag);
      } else {}
    }

    return WillPopScope(
      onWillPop: () async {
        exit(0);
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
          currentIndex: 0,
          onTap: onTabTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
