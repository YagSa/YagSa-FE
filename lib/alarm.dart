import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alarm/alarm.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'schedule_provider.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({this.alarmSettings, super.key}); // nullable로 변경
  final AlarmSettings? alarmSettings; // alarmSettings를 nullable로 변경

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  bool _isUploading = false;
  final _authentication = FirebaseAuth.instance;

  String _title = ''; // 입력한 제목 저장
  String _detail = ''; // 입력한 상세 정보 저장

  // 이미지 선택 및 업로드
  Future<void> getImageAndUpload(
      ImageSource imageSource, String title, String detail) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _isUploading = true;
      });

      try {
        // Firebase Storage에 업로드
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef =
            FirebaseStorage.instance.ref().child('medication_photos/$fileName');

        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          _isUploading = false;
        });

        final user = FirebaseAuth.instance.currentUser;
        final collection = FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .collection('Calendar_medication_list');

        Timestamp currentTimestamp = Timestamp.now();
        DateTime dateTime = currentTimestamp.toDate();
        String onlyDate =
            '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

        final docRef = await collection.doc(onlyDate);
        final subcollection = docRef.collection('Medication');
        await subcollection.add({
          'detail': detail,
          'name': title,
          'img_path': downloadUrl,
          'hour': dateTime.hour,
          'minute': dateTime.minute,
        }).then((value) {
          print('서브컬렉션에 데이터가 추가되었습니다.');
        }).catchError((e) {
          print('에러 발생: $e');
        });

        if (widget.alarmSettings != null) {
          _stopAlarm(widget.alarmSettings!.id);
        }

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } catch (e) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _stopAlarm(int id) async {
    await Alarm.stop(id);
    print('Alarm deleted: $id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF688F7E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: _isUploading ? 70 : 120),
            Image.asset(
              'assets/images/alarm.png',
              width: _isUploading ? 100 : 290,
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        widget.alarmSettings != null
                            ? Text(
                                widget
                                    .alarmSettings!.notificationSettings.title,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                width: 270,
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _title = value;
                                    });
                                  },
                                  style: TextStyle(color: Color(0xFF243642)),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFEEEEEE),
                                    labelText: '약물 이름',
                                    labelStyle:
                                        TextStyle(color: Color(0xFF243642)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Color(0xFFEEEEEE)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0xFFEEEEEE),
                                        width: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: 20),
                        widget.alarmSettings != null
                            ? Text(
                                '복용 시간입니다.',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ) // 알람이 있을 때는 입력 필드 생략
                            : Container(
                                width: 270,
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _detail = value;
                                    });
                                  },
                                  style: TextStyle(color: Color(0xFF243642)),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFEEEEEE),
                                    labelText: '추가 정보',
                                    labelStyle:
                                        TextStyle(color: Color(0xFF243642)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Color(0xFFEEEEEE)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color(0xFFEEEEEE),
                                        width: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: 120),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.alarmSettings == null &&
                                    (_title == "" || _detail == "")
                                ? TextButton(
                                    key: Key('info_button'),
                                    onPressed: () {},
                                    child: Text(
                                      '정보를 모두 입력해주세요',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white54,
                                      ),
                                    ))
                                : TextButton(
                                    key: Key('capture_button'),
                                    onPressed: () {
                                      getImageAndUpload(
                                          ImageSource.camera,
                                          widget.alarmSettings == null
                                              ? _title
                                              : widget.alarmSettings!
                                                  .notificationSettings.title,
                                          widget.alarmSettings == null
                                              ? _detail
                                              : widget.alarmSettings!
                                                  .notificationSettings.body);
                                    },
                                    child: Text(
                                      '촬영하기',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                            Text(
                              '|',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (widget.alarmSettings != null) {
                                  _stopAlarm(widget.alarmSettings!.id);
                                }
                                await Provider.of<ScheduleProvider>(context,
                                        listen: false)
                                    .loadAllSchedulesFromFirebase();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()));
                              },
                              child: Text(
                                '돌아가기',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ])
            // alarmSettings가 null일 경우 Input으로 대체
          ],
        ),
      ),
    );
  }
}
