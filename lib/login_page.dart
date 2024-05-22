import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter/material.dart';
import 'package:aplikasipemungutansuara/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_screen/overlay_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    _akun() async {
      const url = 'https://bit.ly/3F071d3';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Web tidak bisa dibuka $url';
      }
    }

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    TextEditingController nik = new TextEditingController();
    TextEditingController kk = new TextEditingController();

    Future<List> _login() async {
      try {
        EasyLoading.show();
        final response = await http.post(
            Uri.parse(
                "https://e-voting-dashboard.000webhostapp.com/api/login.php"),
            body: {
              "nik": nik.text,
              "kk": kk.text,
            });

        var datauser = json.decode(response.body);
        if (nik.text == '' && kk.text == '') {
          textfieldkosong();
          EasyLoading.dismiss();
        } else if (nik.text == '' || kk.text == '') {
          fieldkosong();
          EasyLoading.dismiss();
        } else if (datauser.length == 0) {
          setState(() {
            tampil();
            EasyLoading.dismiss();
          });
        } else {
          var date = DateTime.parse(datauser[0]['mulai']);
          var date1 = DateTime.parse(datauser[0]['selesai']);
          var datenow = DateTime.now();
          if (datenow.isBefore(date) && datenow.isBefore(date1)) {
            belum();
            EasyLoading.dismiss();
          } else if (datenow.isAfter(date) && datenow.isAfter(date1)) {
            selesai();
            EasyLoading.dismiss();
          } else if (datauser[0]['izin_pemilih'] == 'diizinkan') {
            EasyLoading.dismiss();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("isLoggedIn", true);
            SharedPreferences session = await SharedPreferences.getInstance();
            session.setString('token', nik.text);
            Navigator.of(context).pushNamed(HomePage.tag);
          } else {
            tidakdiizinkan();
            EasyLoading.dismiss();
          }
        }
      } catch (e) {
        if (e is SocketException) {
          koneksihilang();
          EasyLoading.dismiss();
        } else if (e is TimeoutException) {
          Fluttertoast.showToast(
              msg: "Timeout exception : ${e.toString()}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          EasyLoading.dismiss();
        } else {
          Fluttertoast.showToast(
              msg: "Unhandled exception : ${e.toString()}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          EasyLoading.dismiss();
        }
      }
      return Future.error("error");
    }

    final nik1 = TextFormField(
      controller: nik,
      autofocus: true,
      maxLength: 17,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Masukan Nomor NIK Disini...',
        counterText: "",
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final kk1 = TextFormField(
      autofocus: false,
      controller: kk,
      maxLength: 17,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Masukan Nomor KK Disini...',
        counterText: "",
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 39.0,
          onPressed: () {
            _login();
          },
          child: Text('Masuk', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Jika terjadi kesalahan silahkan klik disini',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: _akun,
    );

    final textnik = Text(
      'Nomor NIK',
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23),
      textAlign: TextAlign.center,
    );

    final textkk = Text(
      'Nomor KK',
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23),
      textAlign: TextAlign.center,
    );

    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(height: 48.0),
              textnik,
              nik1,
              SizedBox(height: 8.0),
              textkk,
              kk1,
              SizedBox(height: 24.0),
              loginButton,
              forgotLabel,
            ],
          ),
        ),
      ),
    );
  }
}

void tampil() {
  Fluttertoast.showToast(
      msg: "Anda Tidak Terdaftar / Jadwal Belum Tersedia",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void koneksihilang() {
  Fluttertoast.showToast(
      msg: "Tidak ada koneksi",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void tidakdiizinkan() {
  Fluttertoast.showToast(
      msg: "Anda Belum Memenuhi Syarat Memilih",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void jadwalkosong() {
  Fluttertoast.showToast(
      msg: "Jadwal Belum Ditemukan",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void textfieldkosong() {
  Fluttertoast.showToast(
      msg: "Kolom NIK dan KK kosong",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void fieldkosong() {
  Fluttertoast.showToast(
      msg: "Kolom NIK atau Kolom KK kosong",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void belum() {
  Fluttertoast.showToast(
      msg: "Pemilihan Belum Dimulai",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void selesai() {
  Fluttertoast.showToast(
      msg: "Pemilihan Telah Selesai",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
