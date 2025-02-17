import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authentication = FirebaseAuth.instance;

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
      backgroundColor: Color(0xFFE2F1E7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text(
                '약,사',
                style: TextStyle(
                    fontFamily: 'Tenada',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243642)),
              ),
              SizedBox(
                width: 280,
                child: Divider(
                  color: Color(0xFF243642),
                  thickness: 2,
                  height: 0,
                ),
              ),
              SizedBox(height: 15),
              Text(
                '약물 관리가 힘든 당신을 위한',
                style: TextStyle(fontSize: 18, color: Color(0xFF243642)),
              ),
              Text(
                '약물 복용 일정 관리 서비스.',
                style: TextStyle(fontSize: 18, color: Color(0xFF243642)),
              ),
              SizedBox(height: 20),
              Container(
                width: 280,
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(color: Color(0xFF243642)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFE2F1E7),
                    labelText: '이메일',
                    labelStyle: TextStyle(color: Color(0xFF243642)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF243642),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 280,
                child: TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Color(0xFF243642)),
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFE2F1E7),
                    labelText: '비밀번호',
                    labelStyle: TextStyle(color: Color(0xFF243642)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF243642)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF243642),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    //print('이메일: ${_emailController.text}');
                    //print('비밀번호: ${_passwordController.text}');
                    final newUser =
                        await _authentication.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text);
                    if (newUser.user != null) {
                      _emailController.clear();
                      _passwordController.clear();
                      if (!mounted) return;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(280, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF243642),
                  side: BorderSide(
                    color: Color(0xFF243642), // 테두리 색상
                    width: 2, // 테두리 두께
                  ),
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 19),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(280, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFFE2F1E7),
                  side: BorderSide(
                    color: Color(0xFF243642), // 테두리 색상
                    width: 2, // 테두리 두께
                  ),
                ),
                child: Text(
                  '돌아가기',
                  style: TextStyle(color: Color(0xFF243642), fontSize: 19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
