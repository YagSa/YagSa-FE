import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final Function(DateTime) onDateSelected; // 날짜 선택 시 호출될 콜백 함수

  const Calendar({super.key, required this.onDateSelected});

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
        titleTextStyle: const TextStyle(fontSize: 15),
        leftChevronPadding: const EdgeInsets.only(left: 10.0),
        rightChevronPadding: const EdgeInsets.only(right: 10.0),
        headerPadding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        formatButtonDecoration: BoxDecoration(
          border: const Border.fromBorderSide(BorderSide()),
          borderRadius: const BorderRadius.all(Radius.circular(11.0)),
        ),
        formatButtonPadding: const EdgeInsets.fromLTRB(6.0, 3.0, 6.0, 3.0),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDateSelected(selectedDay); // 선택된 날짜를 부모 위젯에 전달
        }
      },
    );
  }
}