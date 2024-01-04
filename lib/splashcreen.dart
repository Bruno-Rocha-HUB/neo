import 'dart:async';
import 'package:flutter/material.dart';
import 'login/loginpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Adicione um temporizador para aguardar alguns segundos antes de navegar para a página de login
    Timer(
      const Duration(seconds: 5),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/Logo.gif', height: 120, width: 120),
      ),
    );
  }
}

