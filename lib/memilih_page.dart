import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aplikasipemungutansuara/home_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'profile_page.dart';
import 'suara_page.dart';

class Calondata {
  String calonId;
  String calonNama;
  String calonNik;
  String calonKk;
  String calonJenkel;
  String calonTmpLahir;
  String calonTglLahir;
  String calonUmur;
  String calonAgama;
  String calonUrut;
  String calonVisi;
  String calonMisi;
  String calonRt;
  String calonGambar;
  String calonSuara;

  Calondata(
      {required this.calonId,
      required this.calonNama,
      required this.calonNik,
      required this.calonKk,
      required this.calonJenkel,
      required this.calonTmpLahir,
      required this.calonTglLahir,
      required this.calonUmur,
      required this.calonAgama,
      required this.calonUrut,
      required this.calonVisi,
      required this.calonMisi,
      required this.calonRt,
      required this.calonSuara,
      required this.calonGambar});

  factory Calondata.fromJson(Map<String, dynamic> json) {
    return Calondata(
      calonId: json['id_calon'].toString(),
      calonNama: json['nama_calon'],
      calonNik: json['noNik_calon'].toString(),
      calonKk: json['noKK_calon'].toString(),
      calonJenkel: json['jenisKelamin_calon'],
      calonTmpLahir: json['tempatLahir_calon'],
      calonTglLahir: json['tglLahir_calon'],
      calonUmur: json['umur_calon'].toString(),
      calonAgama: json['agama_calon'],
      calonUrut: json['calonNo_urut'],
      calonVisi: json['visi_calon'],
      calonMisi: json['misi_calon'],
      calonRt: json['rt'].toString(),
      calonSuara: json['perolehanSuara_calon'].toString(),
      calonGambar:
          "https://e-voting-dashboard.000webhostapp.com/assets/images/" +
              json['photo_calon'],
    );
  }
}

class MemilihPage extends StatelessWidget {
  static String tag = 'memilih-page';

  final String apiURL =
      'https://e-voting-dashboard.000webhostapp.com/api/getCalon2.php';

  Future<List<Calondata>> fetchCalon() async {
    final session = await SharedPreferences.getInstance();
    final data = session.getString('token') ?? '';
    final response1 = await http.post(
        Uri.parse(
            "https://e-voting-dashboard.000webhostapp.com/api/getPemilih.php"),
        body: {"nik": data});

    var datauser = json.decode(response1.body);

    var response = await http.post(Uri.parse(apiURL), body: {
      "nik": datauser[0]['noNik_pemilih'],
      "rt": datauser[0]['rt_pemilih'],
    });

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<Calondata> calonList = items.map<Calondata>((json) {
        return Calondata.fromJson(json);
      }).toList();

      return calonList;
    } else {
      throw Exception('Failed to load data from Server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
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
      child: FutureBuilder<List<Calondata>>(
        future: fetchCalon(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 1,
              children: List.generate(
                snapshot.data!.length,
                (index) {
                  final urut = TextEditingController(
                      text: snapshot.data![index].calonUrut.toString());
                  final nik = TextEditingController(
                      text: snapshot.data![index].calonNik);
                  final rt = TextEditingController(
                      text: snapshot.data![index].calonRt);
                  final nama = TextEditingController(
                      text: snapshot.data![index].calonNama);
                  final tempatlahir = TextEditingController(
                      text: snapshot.data![index].calonTmpLahir);
                  final tanggallahir = TextEditingController(
                      text: snapshot.data![index].calonTglLahir);
                  final visi = TextEditingController(
                      text: snapshot.data![index].calonVisi);
                  final misi = TextEditingController(
                      text: snapshot.data![index].calonMisi);

                  Future editPegawai1() async {
                    final session = await SharedPreferences.getInstance();
                    final validasi = session.getString('token') ?? '';
                    final response1 = await http.post(
                        Uri.parse(
                            "https://e-voting-dashboard.000webhostapp.com/api/getPemilih.php"),
                        body: {"nik": validasi});
                    var datauser = json.decode(response1.body);

                    return await http.post(
                        Uri.parse(
                            "https://e-voting-dashboard.000webhostapp.com/api/update.php"),
                        body: {
                          "nik_pemilih": datauser[0]['noNik_pemilih'],
                          "nik": nik.text,
                          "rt": rt.text,
                        });
                  }

                  Future editPegawai() async {
                    final session = await SharedPreferences.getInstance();
                    final validasi = session.getString('token') ?? '';
                    final response1 = await http.post(
                        Uri.parse(
                            "https://e-voting-dashboard.000webhostapp.com/api/getPemilih.php"),
                        body: {"nik": validasi});
                    var datauser = json.decode(response1.body);

                    if (datauser[0]['statusMemilih_pemilih'] == "0") {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Memilih Nomor Urut : ' + urut.text),
                          content: Text(
                              'Apakah anda yakin akan memilih calon nomor Urut : ' +
                                  urut.text +
                                  ' ' +
                                  nama.text),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Tidak'),
                              child: const Text('Tidak'),
                            ),
                            TextButton(
                              onPressed: () {
                                editPegawai1();
                                Navigator.pop(context, 'Iya');
                                berhasilmemilih();
                              },
                              child: const Text('Iya'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      sudah();
                    }

                    return Future.error("error");
                  }

                  return Container(
                    padding: EdgeInsets.all(15.0),
                    child: Card(
                      shape: border,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Calon Ketua RT',
                              style: Theme.of(context).textTheme.headline5,
                            ),

                            Image.network(
                              snapshot.data![index].calonGambar,
                              width: 100,
                              height: 100,
                            ),

                            Text(
                              'Data Diri',
                              style: Theme.of(context).textTheme.headline5,
                            ),

                            SizedBox(height: 10), //space
                            SizedBox(height: 10),
                            SizedBox(height: 10),

                            Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 2,
                                  enabled: false,
                                  controller: urut,
                                  textAlign: TextAlign.justify,
                                  decoration: InputDecoration(
                                    labelText: "NO URUT :",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            Visibility(
                              child: TextFormField(
                                controller: nik,
                                textAlign: TextAlign.justify,
                                decoration: InputDecoration(
                                  labelText: "NIK",
                                  labelStyle: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              visible: false,
                            ),

                            Visibility(
                              child: TextFormField(
                                controller: rt,
                                textAlign: TextAlign.justify,
                                decoration: InputDecoration(
                                  labelText: "RT",
                                  labelStyle: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              visible: false,
                            ),

                            Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 2,
                                  enabled: false,
                                  controller: nama,
                                  textAlign: TextAlign.justify,
                                  decoration: InputDecoration(
                                    labelText: "NAMA :",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),
                            Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 2,
                                  enabled: false,
                                  controller: tempatlahir,
                                  textAlign: TextAlign.justify,
                                  decoration: InputDecoration(
                                    labelText: "TEMPAT LAHIR :",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),
                            Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 2,
                                  enabled: false,
                                  controller: tanggallahir,
                                  textAlign: TextAlign.justify,
                                  decoration: InputDecoration(
                                    labelText: "TANGGAL LAHIR :",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),
                            Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 50,
                                  enabled: false,
                                  controller: visi,
                                  textAlign: TextAlign.justify,
                                  decoration: InputDecoration(
                                    labelText: "VISI :",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),
                            Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 50,
                                  enabled: false,
                                  controller: misi,
                                  textAlign: TextAlign.justify,
                                  decoration: InputDecoration(
                                    labelText: "MISI :",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: RaisedButton(
                                color: Colors.lightBlueAccent,
                                shape: border,
                                onPressed: () {
                                  editPegawai();
                                },
                                child: Text(
                                  'Pilih',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
          // throw Exception('Failed to load data from Server.');
        },
      ),
    );

    void onTabTapped(int index) {
      if (index == 0) {
        Navigator.of(context).pushNamed(HomePage.tag);
      } else if (index == 1) {
      } else if (index == 2) {
        Navigator.of(context).pushNamed(SuaraPage.tag);
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
          currentIndex: 1,
          onTap: onTabTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

void belum() {
  Fluttertoast.showToast(
      msg: "Anda Boleh Memilih",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void berhasilmemilih() {
  Fluttertoast.showToast(
      msg: "Anda berhasil memilih",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

void sudah() {
  Fluttertoast.showToast(
      msg: "Anda sudah memilih calon ketua RT",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
