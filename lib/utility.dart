import 'package:intl/intl.dart';

String formatTime(String time) {
  try {
    DateFormat inputFormat = DateFormat("h:mm a");
    DateFormat outputFormat = DateFormat("HH:mm");
    DateTime parsedTime = inputFormat.parse(time);
    return outputFormat.format(parsedTime);
  } catch (e) {
    return time;
  }
}


String formatDisplayTime(String time) {
  DateFormat inputFormat = DateFormat("HH:mm");
  DateFormat outputFormat = DateFormat("h:mm a");
  DateTime parsedTime = inputFormat.parse(time);
  return outputFormat.format(parsedTime);
}
