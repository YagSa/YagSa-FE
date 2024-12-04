import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home.dart';
import 'calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> _medicationHistory = []; // 복용 기록 데이터를 저장할 리스트
  DateTime? _selectedDate; // 선택된 날짜

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '약, 사',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(98, 149, 132, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
          icon: const Icon(Icons.navigate_before),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(226, 241, 231, 1),
          size: 40,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 320,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Calendar(
                    onDateSelected: (selectedDate) {
                      setState(() {
                        _selectedDate = selectedDate;
                      });
                      _fetchMedicationHistory(selectedDate);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '복용 기록',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 3.0,
                ),
                Expanded(
                  child: _medicationHistory.isEmpty
                      ? const Center(child: Text('해당 날짜에 복용 기록이 없습니다.'))
                      : ListView.builder(
                      itemCount: _medicationHistory.length,
                      itemBuilder: (context, index) {
                        final medication = _medicationHistory[index];
                        return MedicationCard(
                          time: '${medication['hour'].toString().padLeft(2, '0')}:${medication['minute'].toString().padLeft(2, '0')}',
                          name: medication['name'] ?? '약 이름 없음',
                          detail: medication['detail'] ?? '정보 없음',
                          imagePath: medication['img_path'] ?? '',
                        );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Firebase에서 복용 기록 데이터를 가져오는 함수
  Future<void> _fetchMedicationHistory(DateTime selectedDate) async {
    final String formattedDate =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final currentUser = FirebaseAuth.instance.currentUser;
    print(currentUser);
    try {
      // 해당 날짜의 서브컬렉션(Medication) 데이터를 가져옵니다.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser!.uid)
          .collection('Calendar_medication_list')
          .doc(formattedDate)
          .collection('Medication')
          .get();

      setState(() {
        _medicationHistory = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      setState(() {
        _medicationHistory = [];
      });
      print('Error fetching medication history: $e');
    }
  }
}

class MedicationCard extends StatefulWidget {
  final String time; // 시간 (HH:mm)
  final String name; // 약 이름
  final String detail; // 복용 정보
  final String imagePath; // 이미지 경로

  const MedicationCard({
    Key? key,
    required this.time,
    required this.name,
    required this.detail,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  String? _imageUrl; // Storage에서 가져온 이미지 URL

  @override
  void initState() {
    super.initState();
    _initializeImage(); // 이미지 초기화
  }

  Future<void> _initializeImage() async {
    try {
      final String? url = await _fetchDownloadUrl(widget.imagePath);
      setState(() {
        _imageUrl = url;
      });
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<String?> _fetchDownloadUrl(String path) async {
    if (_isHttpUrl(path)) {
      return path;
    } else {
      return await FirebaseStorage.instance.ref(path).getDownloadURL();
    }
  }

  bool _isHttpUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      // padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 238, 238, 1), // 배경색
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 시간 표시
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.time,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.name} / ${widget.detail}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // 이미지 표시
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: _imageUrl == null
                  ? const Center(
                child: CircularProgressIndicator(), // 로딩 표시
              )
                  : Image.network(
                  _imageUrl!,
                  height: 100,
                  width: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(), // 로딩 애니메이션
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error); // 로드 실패 시 대체 아이콘
                  },
              ),
            ),
          ),
        ],
      ),
    );
  }
}