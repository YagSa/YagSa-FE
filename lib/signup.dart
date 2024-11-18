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
      backgroundColor: Color(0xFF629584),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 10),
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
                onPressed: () async {
                  try{
                    //print('이메일: ${_emailController.text}');
                    //print('비밀번호: ${_passwordController.text}');
                    final newUser = await _authentication.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                    if (newUser.user != null){
                      _emailController.clear();
                      _passwordController.clear();
                      if(!mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    }
                  }
                  catch(e){
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF243642),
                ),
                child: Text(
                  '회원가입',
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
