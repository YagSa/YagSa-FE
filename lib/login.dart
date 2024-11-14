import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2F1E7),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '약,사',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color(0xFF629584)),
            ),
            SizedBox(
              width: 250,
              child: Divider(
                color: Color(0xFF629584),
                thickness: 3,
                height: 0,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '약물 관리가 힘든 당신을 위한',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '약물 복용 일정 관리 서비스.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/images/splash.png',
              width: 250,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF629584),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '약,사',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
              ),
              SizedBox(
                width: 250,
                child: Divider(
                  color: Color(0xFFEEEEEE),
                  thickness: 3,
                  height: 0,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(color: Color(0xFF243642)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    labelText: '이메일',
                    labelStyle: TextStyle(color: Color(0xFF243642)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Color(0xFF243642)),
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    labelText: '비밀번호',
                    labelStyle: TextStyle(color: Color(0xFF243642)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('이메일: ${_emailController.text}');
                  print('비밀번호: ${_passwordController.text}');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF243642),
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
