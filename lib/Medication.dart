import 'package:flutter/material.dart';

class MedicationHistory extends StatelessWidget {
  final String hour;
  final String minute;
  final String name;
  final String? detail;
  final String img_path;

  const MedicationHistory({
    super.key,
    required this.hour,
    required this.minute,
    required this.name,
    this.detail,
    required this.img_path
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Color.fromRGBO(238, 238, 238, 1),
          ),
          height: 97,
          width: 320,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 복용 시간 및 약명 기록
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${hour}:${minute}',style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                    ),
                    ),
                    Text('${name}/${detail}',style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                    )
                  ],
                ),
              ),
              // 이미지 삽입
              Image.asset(
                  img_path,
                  height: 97,
                  width: 154,
                  fit: BoxFit.cover),
            ],
          ),
        )
    );
  }
}