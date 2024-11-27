import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  String _medicineName = '테이레놀';
  bool _isUploading = false;
  final _authentication = FirebaseAuth.instance;

  // 이미지 선택 및 업로드
  Future<void> getImageAndUpload(ImageSource imageSource) async {
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
        final collection = FirebaseFirestore.instance.collection('Calendar_medication_list');

        Timestamp currentTimestamp = Timestamp.now();
        DateTime dateTime = currentTimestamp.toDate();
        String onlyDate = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

        final docRef = await collection.doc(onlyDate);
        final subcollection = docRef.collection('Medication');

        await subcollection.add({
          'datail': "식후 복용",
          'name': "강민규약",
          'img_path': downloadUrl,
          'hour': dateTime.hour,
          'minute': dateTime.minute,
        }).then((value) {
          print('서브컬렉션에 데이터가 추가되었습니다.');
        }).catchError((e) {
          print('에러 발생: $e');
        });


        //ScaffoldMessenger.of(context).showSnackBar(
        //  SnackBar(content: Text('사진이 업로드되었습니다! URL: $downloadUrl')),
        //);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF688F7E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 140),
            Image.asset(
              'assets/images/alarm.png',
              width: 180,
            ),
            SizedBox(height: 20),
            Text(
              _medicineName,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '복용 시간입니다.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 120),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    getImageAndUpload(ImageSource.camera);
                  },
                  child: _isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    '복용 촬영',
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
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                  child: Text(
                    '알람 끄기',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
