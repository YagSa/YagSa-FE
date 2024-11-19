import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime(2024, 1, 1),
      lastDay: DateTime(2024, 12, 31),
      headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(
            fontSize: 15,
          ),
          leftChevronPadding: EdgeInsets.only(left: 10.0),
          rightChevronPadding: EdgeInsets.only(right: 10.0),
          headerPadding: EdgeInsets.only(top: 10.0,bottom: 10.0),
          formatButtonDecoration: BoxDecoration(
              border: const Border.fromBorderSide(BorderSide()),
              borderRadius: const BorderRadius.all(Radius.circular(11.0))
          ),
          formatButtonPadding: EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 3.0)
      ),
      // 캘린더에서 현재 선택된 날짜를 지정하는 데 사용
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      // 사용자가 캘린더에서 날짜를 선택하면 해당 날짜가 _selectedDay로 업데이트되고
      // 화면이 업데이트되어 선택한 날짜에 대한 변경 사항을 표시
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            print(_selectedDay);
          });
        }
      },
    );
  }
}
